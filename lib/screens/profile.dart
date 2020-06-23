import 'dart:convert';
import 'dart:io';

import 'package:Petti/services/profile.dart';
import 'package:Petti/services/upload_page.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:compressimage/compressimage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import 'cards/ui/detail/dialog.dart';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  Map profile;
  String image;
  TextEditingController _nombreController = new TextEditingController();
  TextEditingController _numeroController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _ciudadController = new TextEditingController();
  TextEditingController _direccionController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getDataProfileService().then((value){
      profile = value;
      print('*****');
      print(profile);
      setState(() {
        _nombreController.text = profile['username'];
        _numeroController.text = profile['telefono'];
        _emailController.text = profile['email'];
        _ciudadController.text = profile['ciudad'];
        _direccionController.text = profile['direccion'];
        image = profile['photo_read'];
      });
      _nombreController.addListener(detector);
      _numeroController.addListener(detector);
      _emailController.addListener(detector);
      _ciudadController.addListener(detector);
      _direccionController.addListener(detector);
    });
  }

  void detector(){
    profile['username'] = _nombreController.text;
    profile['telefono'] = _numeroController.text;
    profile['email'] = _emailController.text;
    profile['ciudad'] = _ciudadController.text;
    profile['direccion'] = _direccionController.text;
  }

  Future<int> uploadImage(var imageFile) async {
    print("FILE SIZE BEFORE: " + imageFile.lengthSync().toString());
    await CompressImage.compress(imageSrc: imageFile.path, desiredQuality: 75); //desiredQuality ranges from 0 to 100
    print("FILE SIZE  AFTER: " + imageFile.lengthSync().toString());
    final id = await uploadImageService(imageFile);
    return id;
  }

  selectImage() async{
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1200, imageQuality: 80);
    int id = await uploadImage(imageFile);
    setState(() {
      profile['photo'] = id;
      print('--------------');
      print(id);
      actualizarProfileService(jsonEncode(profile), profile['id']).then((code){
        if(code == 200){
          getDataProfileService().then((_prof){
            setState(() {
              profile = _prof;
              image = _prof['photo_read'];
            });
          });
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              title:'Éxito!',
              description:'Datos actualizados correctamente!',
              buttonText: "Okay",
            ),
          );
        }else{
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              title:'Error',
              description:'Por favor, intenta más tarde.',
              buttonText: "Okay",
            ),
          );
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
          color: Colors.white,
          child: new ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  new Container(
                    height: 250.0,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(left: 10.0, top: 10.0),
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new IconButton(
                                  icon: Icon(Icons.arrow_back_ios,),
                                  color: Colors.black,
                                  onPressed: () {
                                    Navigator.pop(context,true);
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0, top: 12.0),
                                  child: new Text('Perfil',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                          fontFamily: 'sans-serif-light',
                                          color: Colors.black)),
                                )
                              ],
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: new Stack(fit: StackFit.loose, children: <Widget>[
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                    width: 140.0,
                                    height: 140.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        image: (image != null)?CachedNetworkImageProvider(
                                          image
                                        ):new ExactAssetImage(
                                            'assets/images/user.png',),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 90.0, right: 100.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FlatButton(
                                      onPressed: () => {
                                        selectImage()
                                      },
                                      child: Row(
                                        children: <Widget>[
                                      new CircleAvatar(
                                      backgroundColor: Colors.green,
                                        radius: 25.0,
                                        child: new Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        )),
                                        ],
                                      )
                                    )
                                    /**
                                    new CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 25.0,
                                      child: new Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                    )**/
                                  ],
                                )),
                          ]),
                        )
                      ],
                    ),
                  ),
                  new Container(
                    color: Color(0xffFFFFFF),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 25.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Información personal',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      _status ? _getEditIcon() : new Container(),
                                    ],
                                  )
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Usuario',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: _nombreController,
                                      decoration: const InputDecoration(
                                        hintText: "Escribe tu usuario",
                                      ),
                                      enabled: !_status,
                                      autofocus: !_status,

                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Correo electrónico',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextField(
                                      keyboardType: TextInputType.emailAddress,
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                          hintText: "Escribe tu correo"),
                                      enabled: false,
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Teléfono',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextField(
                                      keyboardType: TextInputType.phone,
                                      controller: _numeroController,
                                      decoration: const InputDecoration(
                                          hintText: "Escribe tu número de teléfono"),
                                      enabled: !_status,
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: new Text(
                                        'Dirección',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    flex: 2,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: new Text(
                                        'Ciudad',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    flex: 2,
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: new TextField(
                                        controller: _direccionController,
                                        decoration: const InputDecoration(
                                            hintText: "Escribe tu dirección"),
                                        enabled: !_status,
                                      ),
                                    ),
                                    flex: 2,
                                  ),
                                  Flexible(
                                    child: new TextField(
                                      controller: _ciudadController,
                                      decoration: const InputDecoration(
                                          hintText: "Escribe tu ciudad"),
                                      enabled: !_status,
                                    ),
                                    flex: 2,
                                  ),
                                ],
                              )),
                          !_status ? _getActionButtons() : new Container(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                    child: new Text("Guardar"),
                    textColor: Colors.white,
                    color: Colors.green,
                    onPressed: () {
                      final temp_txt = profile['username'];
                      var flag = true;
                      temp_txt.runes.forEach((int rune) {
                        if((rune >= 48 && rune <= 57) || (rune >= 65 &&
                            rune <= 90) || (rune >= 97 && rune <= 122)){
                        }else{
                          flag = false;
                        }
                      });
                      if(flag){
                        Map profileTemp = new Map();
                        profileTemp.addAll(profile);
                        profileTemp.remove('id');
                        var username = profileTemp['username'];
                        profileTemp['first_name'] = username;
                        username = username.toString().replaceAll(' ', '');
                        profileTemp['username'] = username.toString().toLowerCase().trim();
                        actualizarProfileService(jsonEncode(profileTemp), profile['id']).then((code){
                          if(code == 200){
                            setState(() {
                              _status = true;
                              FocusScope.of(context).requestFocus(new FocusNode());
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => CustomDialog(
                                title:'Éxito!',
                                description:'Datos actualizados correctamente!',
                                buttonText: "Okay",
                              ),
                            );
                            SharedPreferencesHelper.setName(username);
                          }else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => CustomDialog(
                                title:'Error',
                                description:'Por favor, intenta con otro nombre de usuario.',
                                buttonText: "Okay",
                              ),
                            );
                          }
                        });

                      } else{
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => CustomDialog(
                            title:'Error',
                            description:'El nombre de usuario solo puede contener letras y números\nsin espacios.',
                            buttonText: "Okay",
                          ),
                        );

                      }

                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                    child: new Text("Cancelar"),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.green,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        if(_nombreController.text == 'guess'){
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              title:'No autorizado',
              description:'Debes iniciar sesión para poder realizar esta acción.',
              buttonText: "Okay",
            ),
          );
        }else{
          setState(() {
            _status = false;
          });
        }
      },
    );
  }
}
