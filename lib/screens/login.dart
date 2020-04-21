import 'dart:convert';

import 'package:Petti/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;

import '../shared/shared_preferences_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
 TextEditingController  emaillogController = new TextEditingController();
 TextEditingController  passwordlogController = new TextEditingController();
 TextEditingController  passwordController = new TextEditingController();
 TextEditingController  password2Controller = new TextEditingController();
 TextEditingController  emailController = new TextEditingController();
 bool isLoggedIn = false;
 String token;
 var firebaseAuth = FirebaseAuth.instance;


 @override
  void initState() {
    super.initState();
  }

  void onLoginStatusChange(bool isLoggedIn, String token){
      setState(() {
        this.isLoggedIn = isLoggedIn;
        this.token = token;
        print("token: " + this.token);
      });
  }

  void getUserInfo(FacebookLoginResult result) async{
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
    final profile = json.decode(graphResponse.body);
    print(profile);
  }

 void initiateSignIn(String type) {
   _handleSignIn(type).then((result) {
     if (result == 1) {
       setState(() {
         this.isLoggedIn = true;
       });
     } else {
        print("error de login");
     }
   });
 }

 void loginActions(String displayName, String email) async{
   SharedPreferencesHelper.setName(displayName);
   SharedPreferencesHelper.setEmail(email);
   print("User : " + displayName);
   print("Email: " + email);
   String token = await authBackend(jsonEncode({'email': email,
     'password': displayName}));
   print('*******************');
   print(token);
   SharedPreferencesHelper.setToken(token);
   Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'),
   );
 }
 void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (buildcontext) {
        return AlertDialog(
             title: new Text("Error"),
             content: new Text("Las contraseñas no coinciden"),
             actions: <Widget>[
               new FlatButton(onPressed: (){
                 Navigator.of(context).pop();
               }, child: new Text("Cerrar"))
             ],
            );
      }
    );
  }

 void _showAlertDialogLogin() {
   showDialog(
       context: context,
       builder: (buildcontext) {
         return AlertDialog(
           title: new Text("Error"),
           content: new Text("Los datos no coinciden con ninguna cuenta"),
           actions: <Widget>[
             new FlatButton(onPressed: (){
               Navigator.of(context).pop();
             }, child: new Text("Cerrar"))
           ],
         );
       }
   );
 }

  void loginActionsIndependient(String displayName, String email, String password) async{
   SharedPreferencesHelper.setName(displayName);
   SharedPreferencesHelper.setEmail(email);
   String token = await authBackend(jsonEncode({'email': email,
     'password': password}));
   if(token != null){
     SharedPreferencesHelper.setToken(token);
     Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'),
     );
   }else{
     _showAlertDialogLogin();
   }
 }

 void loginActionsIndependientSignUp(String displayName, String email, String password) async{
   SharedPreferencesHelper.setName(displayName);
   SharedPreferencesHelper.setEmail(email);
   String token = await authBackend(jsonEncode({'email': email,
     'password': password}));
   if(token != null){
     SharedPreferencesHelper.setToken(token);
     Navigator.pushNamedAndRemoveUntil(context, '/home', ModalRoute.withName('/home'),
     );
   }else{
     _showAlertDialogLogin();
   }
 }


 Future<int> _handleSignIn(String type) async {
   switch (type) {
     case "FB":
       try{
         FacebookLoginResult facebookLoginResult = await initiateFacebookLogin();
         final accessToken = facebookLoginResult.accessToken.token;
         if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
           final facebookAuthCred =
           FacebookAuthProvider.getCredential(accessToken: accessToken);
           final user = await firebaseAuth.signInWithCredential(facebookAuthCred);
           loginActions(user.displayName, user.email);
           return 1;
         } else
           return 0;
       }catch (error){
         print("error: " + error.toString());
       }
       break;
     case "G":
       try {
         GoogleSignInAccount googleSignInAccount = await _handleGoogleSignIn();
         final googleAuth = await googleSignInAccount.authentication;
         final googleAuthCred = GoogleAuthProvider.getCredential(
             idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
         final user = await firebaseAuth.signInWithCredential(googleAuthCred);
         loginActions(user.displayName, user.email);
         return 1;
       } catch (error) {
         print("error: " + error.toString());
         return 0;
       }
       break;
       case "S":
       try {
         if(passwordController.text == password2Controller.text){
           var m = emailController.text.split("@");
           loginActionsIndependientSignUp(m[0],emailController.text,passwordController.text);
         }else{
           _showAlertDialog();
         }
         return 1;
       }catch (error) {
         print("error: " + error.toString());
         return 0;
        }
       break;
       case "L":
       try {
           var m = emaillogController.text.split("@");
           loginActionsIndependient(m[0],emaillogController.text,passwordlogController.text);
           return 1;
       }catch (error) {
         print("error: " + error.toString());
         return 0;
       }
   }
   return 0;
 }

 Future<FacebookLoginResult> initiateFacebookLogin() async{
   FacebookLogin login = FacebookLogin();
   FacebookLoginResult result = await login.logIn(['email']);

   switch (result.status) {
     case FacebookLoginStatus.loggedIn:
       var tokenFacebook = result.accessToken.token;
       onLoginStatusChange(true, tokenFacebook);
       getUserInfo(result);
       break;
     case FacebookLoginStatus.cancelledByUser:
     //TODO: _showCancelledMessage();
       break;
     case FacebookLoginStatus.error:
       print("error: " + result.errorMessage);
       break;
   }
   return result;
 }

 Future<GoogleSignInAccount> _handleGoogleSignIn() async {
   GoogleSignIn googleSignIn = GoogleSignIn(
       scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);
   GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
   return googleSignInAccount;
 }

  Widget homePage() {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
      child: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white,

              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              tileMode: TileMode.clamp)
        /**
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.1), BlendMode.dstATop),
          image: AssetImage('assets/petshop.png'),
          fit: BoxFit.cover,
        ),
         **/
      ),
      child: new Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 250.0),
            child: Center(
              /**
              child: Icon(
                Icons.apps,
                color: Colors.white,
                size: 40.0,
              ),
              **/
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /**
                Text(
                  "Petti",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                    **/
                Text(
                  "Petti",
                  style: TextStyle(
                      fontFamily: "Billabong",
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          new Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 150.0),
            alignment: Alignment.center,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new OutlineButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color:  Color.fromRGBO(28, 96, 97, 1.0),
                    highlightedBorderColor:  Color.fromRGBO(28, 96, 97, 1.0),
                    onPressed: () => gotoSignup(),
                    child: new Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Expanded(
                            child: Text(
                              "Registrarse",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromRGBO(28, 96, 97, 1.0),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          new Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
            alignment: Alignment.center,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color.fromRGBO(28, 96, 97, 1.0),
                    onPressed: () => gotoLogin(),
                    child: new Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 20.0,
                      ),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Expanded(
                            child: Text(
                              "Iniciar sesión",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )));
  }

  Widget loginPage() {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
      child: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        /**
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.05), BlendMode.dstATop),
          image: AssetImage('assets/petshop.png'),
          fit: BoxFit.cover,
        ),
         */
      ),
      child: SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left:120.0, right: 120.0, top: 120.0, bottom: 70.0),
              child: Center(
                child: Icon(
                  Icons.account_circle,
                  color: Color.fromRGBO(28, 96, 97, 1.0),
                  size: 70.0,
                ),
              ),
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Correo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    child: TextField(
                      controller: emaillogController,
                      obscureText: false,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'email@domain.com',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 24.0,
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Contraseña",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    child: TextField(
                      controller: passwordlogController,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '*********',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 24.0,
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
              alignment: Alignment.center,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new FlatButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      onPressed: () => {
                        initiateSignIn("L")
                      },
                      child: new Container(

                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 20.0,
                        ),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Expanded(
                              child: Text(
                                "Iniciar sesión",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  new Expanded(
                    child: new Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(border: Border.all(width: 0.25)),
                    ),
                  ),
                  Text(
                    "O conectar con",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  new Expanded(
                    child: new Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(border: Border.all(width: 0.25)),
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
              child: new Row(
                children: <Widget>[
                  Platform.isAndroid?
                  new Expanded(
                    child: new Container(
                      margin: EdgeInsets.only(right: 8.0),
                      alignment: Alignment.center,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new FlatButton(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              color: Color(0Xff3B5998),
                              onPressed: () => {},
                              child: new Container(
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new FlatButton(
                                        onPressed: ()=>{initiateSignIn("FB")},
                                        padding: EdgeInsets.only(
                                          top: 20.0,
                                          bottom: 20.0,
                                        ),
                                        child: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Text(
                                              "FACEBOOK",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ):new Container(),
                  new Expanded(
                    child: new Container(
                      margin: EdgeInsets.only(left: 8.0),
                      alignment: Alignment.center,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new FlatButton(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              color: Color(0Xffdb3236),
                              onPressed: () => {},
                              child: new Container(
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Expanded(
                                      child: new FlatButton(
                                        onPressed: ()=>{initiateSignIn("G")},
                                        padding: EdgeInsets.only(
                                          top: 20.0,
                                          bottom: 20.0,
                                        ),
                                        child: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Text(
                                              "GOOGLE",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    )));
  }

  Widget signupPage() {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
      child:
      Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left:120.0, right: 120.0, top: 100.0, bottom: 70.0),
              child: Center(
                child: Icon(
                  Icons.account_circle,
                  color: Color.fromRGBO(28, 96, 97, 1.0),
                  size: 70.0,
                ),
              ),
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Correo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    child: TextField(
                      controller: emailController,
                      obscureText: false,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'email@domain.com',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 24.0,
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Contraseña",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '*********',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 24.0,
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: new Text(
                      "Confirmar contraseña",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    child: TextField(
                      controller: password2Controller,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '*********',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 24.0,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: new FlatButton(
                    child: new Text(
                      "¿Ya tienes cuenta?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        fontSize: 15.0,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    onPressed: () => {gotoLogin()},
                  ),
                ),
              ],
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
              alignment: Alignment.center,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new FlatButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      color: Color.fromRGBO(28, 96, 97, 1.0),
                      onPressed: () => {
                        initiateSignIn("S")
                      },
                      child: new Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 20.0,
                        ),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Expanded(
                              child: Text(
                                "Registrarse",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    ));
  }

  gotoLogin() {
    //controller_0To1.forward(from: 0.0);
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  gotoSignup() {
    //controller_minus1To0.reverse(from: 0.0);
    _controller.animateToPage(
      2,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  PageController _controller = new PageController(initialPage: 1, viewportFraction: 1.0);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
        home: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: PageView(
              controller: _controller,
              physics: new AlwaysScrollableScrollPhysics(),
              children: <Widget>[loginPage(), homePage(), signupPage()],
              scrollDirection: Axis.horizontal,
            )),
        )
    );
  }
}
