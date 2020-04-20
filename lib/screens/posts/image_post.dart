import 'dart:convert';

import 'package:Petti/screens/cards/ui/detail/dialog.dart';
import 'package:Petti/services/feed.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/utils.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class ImagePost extends StatefulWidget {
  ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.id,
      this.owner,
        this.image_profile,
      });


  factory ImagePost.fromJSON(Map data) {
    return ImagePost(
      username: data['username'],
      location: data['location'],
      mediaUrl: data['media_url_read'],
      likes: data['likes'],
      description: data['description'],
      owner: data['telefono'],
      image_profile: data['image_profile'],
      id: data['id'].toString(),
    );
  }

  int getLikeCount(var likes) {
    if (likes == null) {
      return 0;
    }
// issue is below
    var vals = likes.values;
    int count = 0;
    for (var val in vals) {
      if (val == true) {
        count = count + 1;
      }
    }

    return count;
  }


  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  final String image_profile;
  final likes;
  final String id;
  final String owner;

  _ImagePost createState() => _ImagePost(
        mediaUrl: this.mediaUrl,
        username: this.username,
        location: this.location,
        description: this.description,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        image_profile: this.image_profile,
        owner: this.owner,
        id: this.id,
      );
}

class _ImagePost extends State<ImagePost> {
  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  final String image_profile;

  Map likes;
  String name = '';
  int likeCount;
  final String id;
  bool liked = false;
  final String owner;

  bool showHeart = false;

  TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );


  @override
  void initState(){
    super.initState();
    SharedPreferencesHelper.getName().then((_name){
      setState(() {
        this.name = _name.trim().replaceAll(' ', '').toLowerCase();
      });
    });
  }
  _ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.id,
      this.likeCount,
        this.image_profile,
      this.owner});

  GestureDetector buildLikeIcon() {
    Color color;
    IconData icon;

    if (liked) {
      color = Color.fromRGBO(21, 157, 99, 1.0);
      icon = FontAwesomeIcons.solidHeart;
    } else {
      icon = FontAwesomeIcons.heart;
    }

    return GestureDetector(
        child: Icon(
          icon,
          size: 25.0,
          color: color,
        ),
        onTap: () {
          _likePost(id);
        });
  }

  GestureDetector buildLikeableImage() {
    return GestureDetector(
      onDoubleTap: () => _likePost(id),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => loadingPlaceHolder,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          showHeart
              ? Positioned(
                  child: Container(
                    width: 100,
                    height: 100,
                    child:  Opacity(
                        opacity: 0.85,
                        child: FlareActor("assets/flare/Like.flr",
                          animation: "Like",
                        )),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Future<int> eliminarPost(int id) async{
    var statusCode = await eliminarPostService(id);
    return statusCode;
  }

Future<ConfirmAction> _asyncConfirmDialog(BuildContext context, int id) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('¿Quieres eliminar esta publicación?'),
        content: const Text(
            'Recuerda que esto eliminará tu publicación y nadie podrá contactarte.'),
        actions: <Widget>[
          FlatButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: const Text('Aceptar'),
            onPressed: () {
              eliminarPost(id).then((value){
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
                if(value == 204){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDialog(
                      title: 'Éxito',
                      description: '¡Este post ha sio eliminado!\nctualiza tu feed.',
                      buttonText: "Okay",
                    ),
                  );
                }else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDialog(
                      title: 'Hubo un problema',
                      description: 'Hubo un problema al eliminar este post,\nintentalo más tarde.',
                      buttonText: "Okay",
                    ),
                  );
                }
              });

            },
          )
        ],
      );
    },
  );
}
  buildPostHeader({String owner}) {
    if (this.username == null) {
      return Text("owner error");
    }

    return FutureBuilder (

        builder: (context, snapshot) {
          if (this.username != null) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                    (image_profile!=null)?image_profile:
                    "https://pettiapp.s3.us-east-2.amazonaws.com/images/LOGO1.png"),
                //backgroundColor: Color.fromRGBO(28, 96, 97, 1.0),
              ),
              title: GestureDetector(
                child: Text(this.username, style: boldStyle),
                onTap: () {
                  //openProfile(context, owner);
                },
              ),
              subtitle: Text(this.location),
              trailing: IconButton(
                icon: Icon(Icons.more_vert),
                tooltip: 'Eliminar post',
                onPressed: () {
                  print('eliminando');
                  SharedPreferencesHelper.getName().then((_name){
                    if(_name == this.username){
                      _asyncConfirmDialog(context, int.parse(this.id));
                    }else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => CustomDialog(
                          title: '¡Alto!',
                          description: '¡Este post no te pertenece!\nno puedes eliminarlo ;)',
                          buttonText: "Okay",
                        ),
                      );
                    }
                  });

                },
              ),
            );
          }


          // snapshot data is null here
          return Container();
        });
  }

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: Center(child: CircularProgressIndicator()),
  );


  @override
  Widget build(BuildContext context) {
    SharedPreferencesHelper.getEmailAsync().then((_email){
      liked = (likes[_email] == true);
    });


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(owner: username),
        buildLikeableImage(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
            buildLikeIcon(),
            Padding(padding: const EdgeInsets.only(right: 20.0)),
            GestureDetector(
                child: const Icon(
                  FontAwesomeIcons.phone,
                  size: 25.0,
                ),
                onTap: () {
                  if(this.owner != null){
                    FlutterOpenWhatsapp.sendSingleMessage('57'+this.owner, "Hello");
                  }else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => CustomDialog(
                        title: 'Tenemos problemas',
                        description: 'El usuario que intentas contactar aún no tiene registrado su número...',
                        buttonText: "Okay",
                      ),
                    );
                  }
                }),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: boldStyle,
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(left: 20.0, right: 2.0),
                child: Text(
                  this.username,
                  style: boldStyle,
                )),
            Expanded(child: Text(description)),
          ],
        )
      ],
    );
  }

  void _likePost(String id2) async{
    var email = await SharedPreferencesHelper.getEmailAsync();
    bool _liked = likes[email] == true;
    var dio = Dio();
    final headers = await getHeaders();
    if (_liked) {
      try{
        final formData = {
          '$email': false,
      };
      final response = await dio.post(
        'http://$DOMAIN/api/v1/mascotas/publicaciones/$id/update_likes/',
          data: formData,
          options: Options(
              headers: headers
          )
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.data}");
      }catch(exception){
        print('exception was: $exception');
      }
      //reference.document(id).updateData({
        //'likes.$userId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      //});

      setState(() {
        likeCount = likeCount - 1;
        liked = false;
        likes[email] = false;
      });

    }

    if (!_liked) {
      print('liking');
      try{
        final formData = {
          '$email': true
      };
      final response = await dio.post(
        'http://$DOMAIN/api/v1/mascotas/publicaciones/$id/update_likes/',
          data: formData,
          options: Options(
              headers: headers
          )
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.data}");
      }catch(exception){
        print('exception was: $exception');
      }
      //reference.document(id).updateData({'likes.$userId': true});
      


      setState(() {
        likeCount = likeCount + 1;
        liked = true;
        likes[email] = true;
        showHeart = true;
      });
      Timer(const Duration(milliseconds: 2000), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

}

class ImagePostFromId extends StatelessWidget {
  final String id;

  ImagePostFromId({this.id});

  getImagePost() async {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getImagePost(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator());
          return snapshot.data;
        });
  }
}

