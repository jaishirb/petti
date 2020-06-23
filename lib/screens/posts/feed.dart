import 'dart:io';
import 'dart:async';
import 'package:Petti/screens/cards/ui/detail/dialog.dart';

import 'location.dart';
import 'image_post.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:Petti/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:Petti/services/feed.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Petti/services/upload_page.dart';
import 'package:compressimage/compressimage.dart';
import 'package:Petti/screens/posts/upload_page.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';

class Feed extends StatefulWidget {
  final String title;
  Feed({this.title});
  _Feed createState() => _Feed(title: title);
}

class _Feed extends State<Feed> with AutomaticKeepAliveClientMixin<Feed> {
  final String title;
  _Feed({this.title});
  List<ImagePost> feedData;
  String next;
  bool first = true;
  ScrollController _scrollController = new ScrollController();
  PageView pageView;
  File file;
  Address address;
  String section;
  bool uploading = false;
  bool guess = true;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  @override
  void initState() {
    SharedPreferencesHelper.setSection(title);
    super.initState();
    feedData = null;
    this._loadFeed(false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent / 2) {
        this._loadFeed(true);
      }
    });
    SharedPreferencesHelper.getGuess().then((value) {
      setState(() {
        guess = value;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  buildFeed() {
    if (feedData != null) {
      return ListView.builder(
          padding: EdgeInsets.only(bottom: 70),
          itemBuilder: (c, i) => feedData[i],
          controller: _scrollController,
          itemCount: feedData.length);
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  initPlatformState() async {
    Address first = await getUserLocation();
    try {
      setState(() {
        address = first;
      });
    } catch (e) {
      print(e);
    }
    SharedPreferencesHelper.getSection().then((value) {
      setState(() {
        section = value;
      });
    });
  }

  void clearImage() {
    setState(() {
      file = null;
    });
  }

  void postImage() {
    setState(() {
      uploading = true;
    });
    uploadImage(file).then((int data) {
      postToFireStore(
          mediaUrl: data,
          description: descriptionController.text,
          location: locationController.text);
    }).then((_) {
      setState(() {
        file = null;
        uploading = false;
      });
    });
  }

  Future<int> uploadImage(var imageFile) async {
    print("FILE SIZE BEFORE: " + imageFile.lengthSync().toString());
    await CompressImage.compress(
        imageSrc: imageFile.path,
        desiredQuality: 75); //desiredQuality ranges from 0 to 100
    print("FILE SIZE  AFTER: " + imageFile.lengthSync().toString());
    final id = await uploadImageService(imageFile);
    return id;
  }

  Future<int> postToFireStore(
      {int mediaUrl, String location, String description}) async {
    String _section = await SharedPreferencesHelper.getSection();
    final statusCode = await postToFireStoreService(
        mediaUrl: mediaUrl,
        location: location,
        description: description,
        section: _section);
    return statusCode;
  }

  buildLocationButton(String locationName) {
    if (locationName != null ?? locationName.isNotEmpty) {
      return InkWell(
        onTap: () {
          locationController.text = locationName;
        },
        child: Center(
          child: Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            margin: EdgeInsets.only(right: 3.0, left: 3.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                locationName,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again
    return file == null
        ? Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                if(guess){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDialog(
                      title:'No autorizado',
                      description:'Debes iniciar sesión para poder realizar esta acción.',
                      buttonText: "Okay",
                    ),
                  );
                }else{
                  return showDialog<Null>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return SimpleDialog(
                            title: const Text('Crear una publicación'),
                            children: <Widget>[
                              SimpleDialogOption(
                                  child: const Text('Tomar foto'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    File imageFile = await ImagePicker.pickImage(
                                        source: ImageSource.camera,
                                        maxWidth: 1920,
                                        maxHeight: 1200,
                                        imageQuality: 80);
                                    setState(() {
                                      file = imageFile;
                                    });
                                  }),
                              SimpleDialogOption(
                                  child: const Text('Escoger en galería'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    File imageFile = await ImagePicker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 1920,
                                        maxHeight: 1200,
                                        imageQuality: 80);
                                    setState(() {
                                      file = imageFile;
                                    });
                                  }),
                              SimpleDialogOption(
                                  child: const Text("Cancelar"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  })
                            ]);
                      });
                }
                return null;
              },
              icon: Icon(Icons.camera_alt, color: Colors.white),
              label: Text('Publicar'),
            ),
            appBar: AppBar(
              title: Text('$title',
                  style: const TextStyle(
                      fontFamily: "Billabong",
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      fontSize: 35.0)),
              centerTitle: true,
              backgroundColor: Colors.white,
            ),
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: buildFeed(),
            ))
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Colors.white70,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: clearImage),
              title: const Text(
                'Nueva publicación',
                style: const TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: postImage,
                    child: Text(
                      "Publicar",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ))
              ],
            ),
            body: ListView(
              children: <Widget>[
                PostForm(
                  imageFile: file,
                  descriptionController: descriptionController,
                  locationController: locationController,
                  loading: uploading,
                ),
                Divider(), //scroll view where we will show location to users
                (address == null)
                    ? Container()
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(right: 5.0, left: 5.0),
                        child: Row(
                          children: <Widget>[
                            buildLocationButton(address.featureName),
                            buildLocationButton(address.subLocality),
                            buildLocationButton(address.locality),
                            buildLocationButton(address.subAdminArea),
                            buildLocationButton(address.adminArea),
                            buildLocationButton(address.countryName),
                          ],
                        ),
                      ),
                (address == null) ? Container() : Divider(),
              ],
            ));
  }

  Future<Null> _refresh() async {
    //feedData = new List<ImagePost>();
    feedData = null;
    await _getFeed(false);
    setState(() {});
    return;
  }

  _loadFeed(bool flag) async {
    _getFeed(flag);
  }

  _getFeed(bool flag) async {
    List<ImagePost> listOfPosts;
    String _action;
    switch (title) {
      case 'Adopción y perdidos':
        _action = 'adopcion';
        break;
      case 'Compra y venta':
        _action = 'compraventa';
        break;
      case 'Coupet':
        _action = 'parejas';
        break;
    }
    String url;
    if (!flag) {
      url = 'http://$DOMAIN/api/v1/mascotas/publicaciones/?action=$_action';
    } else {
      //print('loading next');
      url = next;
    }
    if (url != null) {
      print(url);
      Map<String, dynamic> data = await getDataFeedService(title, url);
      List<dynamic> results = data['results'];
      listOfPosts = _generateFeed(results);
      if (!flag) {
        feedData = new List<ImagePost>();
      }
      setState(() {
        feedData.addAll(listOfPosts);
      });
      next = data['next'];
    }
  }

  List<ImagePost> _generateFeed(List<dynamic> feedData) {
    List<ImagePost> listOfPosts = [];
    for (var postData in feedData) {
      print(postData);
      listOfPosts.add(ImagePost.fromJSON(postData));
    }
    return listOfPosts;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}
