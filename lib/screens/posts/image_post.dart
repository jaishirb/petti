import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';

class ImagePost extends StatefulWidget {
  const ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.id,
      this.owner});


  factory ImagePost.fromJSON(Map data) {
    return ImagePost(
      username: data['username'],
      location: data['location'],
      mediaUrl: data['media_url_read'],
      likes: data['likes'],
      description: data['description'],
      owner: data['owner'].toString(),
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
        owner: this.owner,
        id: this.id,
      );
}

class _ImagePost extends State<ImagePost> {
  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  Map likes;
  int likeCount;
  final String id;
  bool liked;
  final String owner;

  bool showHeart = false;

  TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );


  _ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.id,
      this.likeCount,
      this.owner});

  GestureDetector buildLikeIcon() {
    Color color;
    IconData icon;

    if (liked) {
      color = Colors.pink;
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

  buildPostHeader({String owner}) {
    if (owner == null) {
      return Text("owner error");
    }

    return FutureBuilder(

        builder: (context, snapshot) {

          if (snapshot.data != null) {
            return ListTile(
              leading: CircleAvatar(
                //backgroundImage: CachedNetworkImageProvider(snapshot.data.data['photoUrl']),
                backgroundColor: Colors.grey,
              ),
              title: GestureDetector(
                child: Text('Usuario', style: boldStyle),
                onTap: () {
                  //openProfile(context, owner);
                },
              ),
              subtitle: Text(this.location),
              trailing: const Icon(Icons.more_vert),
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
    liked = (likes[googleSignIn.currentUser.id.toString()] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(owner: owner),
        buildLikeableImage(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
            buildLikeIcon(),
            Padding(padding: const EdgeInsets.only(right: 20.0)),
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
                margin: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Usuario ",
                  style: boldStyle,
                )),
            Expanded(child: Text(description)),
          ],
        )
      ],
    );
  }

  void _likePost(String id2) async{
    var userId = googleSignIn.currentUser.id;
    bool _liked = likes[userId] == true;
    var dio = Dio();
    if (_liked) {
      print('removing like');
      try{
        final formData = {
          '$userId': false
      };
      final response = await dio.post(
        'http://75.2.0.131/petti/api/v1/mascotas/publicaciones/$id/update_likes/', data: formData);
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
        likes[userId] = false;
      });

    }

    if (!_liked) {
      print('liking');
      try{
        final formData = {
          '$userId': true
      };
      final response = await dio.post(
        'http://75.2.0.131/petti/api/v1/mascotas/publicaciones/$id/update_likes/', data: formData);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.data}");
      }catch(exception){
        print('exception was: $exception');
      }
      //reference.document(id).updateData({'likes.$userId': true});
      


      setState(() {
        likeCount = likeCount + 1;
        liked = true;
        likes[userId] = true;
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

  const ImagePostFromId({this.id});

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
