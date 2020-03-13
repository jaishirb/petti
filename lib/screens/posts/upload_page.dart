import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import '../../utils/utils.dart';
import 'main.dart';
import 'dart:io';
import 'location.dart';
import 'package:geocoder/geocoder.dart';

class Uploader extends StatefulWidget {
  _Uploader createState() => _Uploader();
}

class _Uploader extends State<Uploader> {
  File file;
  //Strings required to save address
  Address address;

  Map<String, double> currentLocation = Map();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool uploading = false;

  @override
  initState() {
    //variables with location assigned as 0.0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    initPlatformState(); //method to call location
    super.initState();
  }

  //method to get Location and save into variables
  initPlatformState() async {
    Address first = await getUserLocation();
    setState(() {
      address = first;
    });
  }

  Widget build(BuildContext context) {
    return file == null
        ? IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => {_selectImage(context)})
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Colors.white70,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: clearImage),
              title: const Text(
                'Post to',
                style: const TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: postImage,
                    child: Text(
                      "Post",
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

  //method to build buttons with location.
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

  _selectImage(BuildContext parentContext) async {
    return showDialog<Null>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1200, imageQuality: 80);
                  setState(() {
                    file = imageFile;
                  });
                }),
            SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1200, imageQuality: 80);
                  setState(() {
                    file = imageFile;
                  });
                }),
            SimpleDialogOption(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
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
      print('image uploaded!!!!!!!!');
      postToFireStore(
          mediaUrl: data,
          description: descriptionController.text,
          location: locationController.text);
    }).then((_) {
      print('post created!!!!!!!!!!!!!!!!!!1');
      setState(() {
        file = null;
        uploading = false;
      });
    });
  }
}

class PostForm extends StatelessWidget {
  final imageFile;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final bool loading;
  PostForm(
      {this.imageFile,
      this.descriptionController,
      this.loading,
      this.locationController});

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        loading
            ? LinearProgressIndicator()
            : Padding(padding: EdgeInsets.only(top: 0.0)),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CircleAvatar(
              //backgroundImage: NetworkImage(currentUserModel.photoUrl),
            ),
            Container(
              width: 250.0,
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    hintText: "Write a caption...", border: InputBorder.none),
              ),
            ),
            Container(
              height: 45.0,
              width: 45.0,
              child: AspectRatio(
                aspectRatio: 487 / 451,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.fill,
                    alignment: FractionalOffset.topCenter,
                    image: FileImage(imageFile),
                  )),
                ),
              ),
            ),
          ],
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.pin_drop),
          title: Container(
            width: 250.0,
            child: TextField(
              controller: locationController,
              decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }
}

Future<int> uploadImage(var imageFile) async {
  /**
   * var uuid = Uuid().v1();
  StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
  StorageUploadTask uploadTask = ref.putFile(imageFile);

  String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
  return downloadUrl;
   */
  var dio = Dio();
  String fileName = imageFile.path.split('/').last;
  FormData formData = FormData.fromMap({
      "photo": await MultipartFile.fromFile(imageFile.path, filename:fileName),
      "title": "test"
  });
  final response = await dio.post(
    'http://$DOMAIN/api/v1/mascotas/imagenes/', data: formData);
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.data}");
  final id = response.data['id'];
  return id;
  /**
   * final response = await http.post('http://18.216.178.5/petti/api/v1/mascotas/imagenes/', 
      headers: {
            "Content-type": "multipart/form-data",
      }, 
      body: {
            "photo": imageFile,
            "title": 'test',
      });
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      final url = jsonDecode(response.body)['photo'];
      return url;
   */
  
}

void postToFireStore(
    {int mediaUrl, String location, String description}) async {
  /** 
   * var reference = Firestore.instance.collection('insta_posts');

  reference.add({
    "username": currentUserModel.username,
    "location": location,
    "likes": {},
    "media_url": mediaUrl,
    "description": description,
    "owner": googleSignIn.currentUser.id,
    "timestamp": DateTime.now(),
  }).then((DocumentReference doc) {
    String docId = doc.documentID;
    reference.document(docId).updateData({"id": docId});
  });
  */
  var dio = Dio();
  FormData formData = FormData.fromMap({
      "location": location,
      "media_url": mediaUrl,
      "description": description,
  });
  final response = await dio.post(
    'http://$DOMAIN/api/v1/mascotas/publicaciones/', data: formData);
  print("Response status: ${response.statusCode}");
  print("Response body: ${response.data}");
}
