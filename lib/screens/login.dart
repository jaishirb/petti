import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Petti/services/auth.dart';
import '../shared/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  TextEditingController emaillogController = new TextEditingController();
  TextEditingController passwordlogController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController password2Controller = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  bool isLoggedIn = false;
  String token;
  var firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  void onLoginStatusChange(bool isLoggedIn, String token) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.token = token;
      //print("token: " + this.token);
    });
  }

  void getUserInfo(FacebookLoginResult result) async {
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
    final profile = json.decode(graphResponse.body);
    print(profile);
  }

  void setVerify(bool s) {
    setState(() {
      this.verify = s;
    });
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

  void loginActions(String displayName, String email) async {
    SharedPreferencesHelper.setName(displayName);
    SharedPreferencesHelper.setEmail(email);
    print("User : " + displayName);
    print("Email: " + email);
    String token = await authBackend(
        jsonEncode({'email': email, 'password': displayName}));
    print('*******************');
    print(token);
    SharedPreferencesHelper.setToken(token);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      ModalRoute.withName('/home'),
    );
  }

  void _showAlertDialog(String message) {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: new Text("Error"),
            content: new Text(message),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text("Cerrar"))
            ],
          );
        });
  }

  void _showAlertDialogLogin() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: new Text("Error"),
            content: new Text("Intente con otros datos, este usuario ya existe."),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text("Cerrar"))
            ],
          );
        });
  }

  void _showAlertDialogSignup() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: new Text("Error"),
            content: new Text("Los datos ingresados ya existen."),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text("Cerrar"))
            ],
          );
        });
  }

  void loginActionsIndependient(
      String displayName, String email, String password) async {
    SharedPreferencesHelper.setName(displayName);
    SharedPreferencesHelper.setEmail(email);
    String token =
        await authBackend(jsonEncode({'email': email, 'password': password}));
    if (token != null) {
      SharedPreferencesHelper.setToken(token);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        ModalRoute.withName('/home'),
      );
    } else {
      _showAlertDialogLogin();
    }
  }

  void loginActionsIndependientSignUp(
      String displayName, String email, String password, String phone, int code) async {
    SharedPreferencesHelper.setName(displayName);
    SharedPreferencesHelper.setEmail(email);
    String token = await signup(jsonEncode({'email': email, 'password': password, 'code': code, 'phone': phone}));
    if (token != null) {
      SharedPreferencesHelper.setToken(token);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        ModalRoute.withName('/home'),
      );
    }else{
      _showAlertDialogLogin();
    }

  }

  Future<int> _handleSignIn(String type) async {
    switch (type) {
      case "FB":
        try {
          FacebookLoginResult facebookLoginResult =
              await initiateFacebookLogin();
          final accessToken = facebookLoginResult.accessToken.token;
          if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
            final facebookAuthCred =
                FacebookAuthProvider.getCredential(accessToken: accessToken);
            final user =
                await firebaseAuth.signInWithCredential(facebookAuthCred);
            loginActions(user.displayName, user.email);
            return 1;
          } else
            return 0;
        } catch (error) {
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
//         print('********************');
//         print(user);
          loginActions(user.displayName, user.email);
          return 1;
        } catch (error) {
          print("error: " + error.toString());
          return 0;
        }
        break;
      case "S":
        try {
          if (passwordController.text == password2Controller.text) {
            var m = emailController.text.split("@");
            print('-----------------');
            print(emailController.text);
            print(passwordController.text);
            print(phoneController.text);
            print(int.parse(_digit1.text + _digit2.text + _digit3.text + _digit4.text + _digit5.text));
            loginActionsIndependientSignUp(m[0], emailController.text,
                passwordController.text, phoneController.text,
                int.parse(_digit1.text + _digit2.text + _digit3.text + _digit4.text + _digit5.text)
            );
          } else {
            _showAlertDialog('Por favor verifique sus datos');
          }
          return 1;
        } catch (error) {
          print("error: " + error.toString());
          return 0;
        }
        break;
      case "L":
        try {
          var m = emaillogController.text.split("@");
          loginActionsIndependient(
              m[0], emaillogController.text, passwordlogController.text);
          return 1;
        } catch (error) {
          print("error: " + error.toString());
          return 0;
        }
    }
    return 0;
  }

  Future<FacebookLoginResult> initiateFacebookLogin() async {
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
                  colors: [Colors.white, Colors.white],
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
                      )),
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
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 150.0),
                alignment: Alignment.center,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new OutlineButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        highlightedBorderColor: Color.fromRGBO(28, 96, 97, 1.0),
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
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
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
                  padding: EdgeInsets.only(
                      left: 120.0, right: 120.0, top: 120.0, bottom: 70.0),
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
                  margin:
                      const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
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
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_passFocus);
                          },
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
                  margin:
                      const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
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
                          focusNode: _passFocus,
                          onEditingComplete: () {
                            initiateSignIn('L');
                          },
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
                  margin:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                  alignment: Alignment.center,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new FlatButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          color: Color.fromRGBO(28, 96, 97, 1.0),
                          onPressed: () => {initiateSignIn('L')},
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
          ),
        )));
  }

  Widget signupPage() {
    return new Scaffold(
        resizeToAvoidBottomPadding: true,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(color: Colors.white),
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(
                          left: 120.0, right: 120.0, top: 100.0, bottom: 70.0),
                      child: Center(
                          child: Icon(Icons.account_circle,
                              color: Color.fromRGBO(28, 96, 97, 1.0),
                              size: 70.0))),
                  new Row(children: <Widget>[
                    new Expanded(
                        child: new Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: new Text("Correo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(28, 96, 97, 1.0),
                                    fontSize: 15.0))))
                  ]),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 40.0, right: 40.0, top: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(28, 96, 97, 1.0),
                                  width: 0.5,
                                  style: BorderStyle.solid))),
                      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Expanded(
                                child: TextField(
                                    controller: emailController,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'email@domain.com',
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onEditingComplete: () {
                                      FocusScope.of(context)
                                          .requestFocus(_phoneFocus);
                                    }))
                          ])),
                  Divider(height: 24.0),
                  new Row(children: <Widget>[
                    new Expanded(
                        child: new Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: new Text("Teléfono",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(28, 96, 97, 1.0),
                                    fontSize: 15.0))))
                  ]),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 40.0, right: 40.0, top: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(28, 96, 97, 1.0),
                                  width: 0.5,
                                  style: BorderStyle.solid))),
                      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text('+57 '),
                            new Expanded(
                                child: TextField(
                                    focusNode: _phoneFocus,
                                    keyboardType: TextInputType.phone,
                                    controller: phoneController,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '3012345678',
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onEditingComplete: () {
                                      FocusScope.of(context)
                                          .requestFocus(_pass1Focus);
                                    }))
                          ])),
                  Divider(height: 24.0),
                  new Row(children: <Widget>[
                    new Expanded(
                        child: new Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: new Text("Contraseña",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(28, 96, 97, 1.0),
                                    fontSize: 15.0))))
                  ]),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 40.0, right: 40.0, top: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(28, 96, 97, 1.0),
                                  width: 0.5,
                                  style: BorderStyle.solid))),
                      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Expanded(
                                child: TextField(
                                    focusNode: _pass1Focus,
                                    controller: passwordController,
                                    obscureText: true,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '*********',
                                        hintStyle:
                                            TextStyle(color: Colors.grey)),
                                    onEditingComplete: () {
                                      FocusScope.of(context)
                                          .requestFocus(_pass2Focus);
                                    }))
                          ])),
                  Divider(height: 24.0),
                  new Row(children: <Widget>[
                    new Expanded(
                        child: new Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: new Text("Confirmar contraseña",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(28, 96, 97, 1.0),
                                    fontSize: 15.0))))
                  ]),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 40.0, right: 40.0, top: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(28, 96, 97, 1.0),
                                  width: 0.5,
                                  style: BorderStyle.solid))),
                      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Expanded(
                                child: TextField(
                                    focusNode: _pass2Focus,
                                    controller: password2Controller,
                                    obscureText: true,
                                    textAlign: TextAlign.left,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '*********',
                                        hintStyle:
                                            TextStyle(color: Colors.grey))))
                          ])),
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
                            ))
                      ]),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 50.0),
                      alignment: Alignment.center,
                      child: new Row(children: <Widget>[
                        new Expanded(
                            child: new FlatButton(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                color: Color.fromRGBO(28, 96, 97, 1.0),
                                onPressed: () {
                                  if (emailController.text.contains('@') &&
                                      !emailController.text.startsWith('@') &&
                                      !emailController.text.endsWith('@') &&
                                      !emailController.text.endsWith('.') &&
                                      !emailController.text.contains('@.') &&
                                      emailController.text
                                          .substring(
                                              emailController.text.indexOf('@'),
                                              emailController.text.length)
                                          .contains('.')) {
                                    if (phoneController.text.length == 10 &&
                                        phoneController.text.startsWith('3')) {
                                      if (passwordController.text ==
                                          password2Controller.text) {
                                        if (passwordController.text.length >
                                            7) {
                                          print('generating code');
                                          generateCode(jsonEncode({'phone': phoneController.text})).then((value) {
                                            if(value){
                                              setVerify(true);
                                            }else {
                                              _showAlertDialogSignup();
                                        }});
                                        } else {
                                          _showAlertDialog(
                                              'La contraseña debe tener mínimo 8 caracteres');
                                        }
                                      } else {
                                        _showAlertDialog(
                                            'Las contraseñas no coinciden');
                                      }
                                    } else {
                                      _showAlertDialog(
                                          'Numero celular no válido');
                                    }
                                  } else {
                                    _showAlertDialog(
                                        'Correo electrónico no válido');
                                  }
                                },
                                child: new Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal: 20.0,
                                    ),
                                    child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Expanded(
                                              child: Text(
                                            "Registrarse",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ))
                                        ]))))
                      ]))
                ])))));
  }

  TextEditingController _digit1 = TextEditingController(),
      _digit2 = TextEditingController(),
      _digit3 = TextEditingController(),
      _digit4 = TextEditingController(),
      _digit5 = TextEditingController();
  FocusNode _f1 = FocusNode(),
      _f2 = FocusNode(),
      _f3 = FocusNode(),
      _f4 = FocusNode(),
      _f5 = FocusNode(),
      _passFocus = FocusNode(),
      _phoneFocus = FocusNode(),
      _pass1Focus = FocusNode(),
      _pass2Focus = FocusNode();
  Widget verifyPhone() {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            title: Text('Verificar número',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(28, 96, 97, 1.0),
                    fontSize: 20)),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: Color.fromRGBO(28, 96, 97, 1.0)),
                onPressed: () {
                  setVerify(false);
                })),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Hemos enviado un mensaje de texto al'),
              Text('${phoneController.text}',
                  style: TextStyle(
                      fontSize: 15, color: Color.fromRGBO(28, 96, 97, 1.0))),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width / 10,
                        child: TextFormField(
                            focusNode: _f1,
                            onChanged: (n) {
                              if (n.length > 0) {
                                FocusScope.of(context).requestFocus(_f2);
                              }
                            },
                            textAlign: TextAlign.center,
                            controller: _digit1,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(counterText: ''))),
                    Container(
                        width: MediaQuery.of(context).size.width / 10,
                        child: TextFormField(
                            focusNode: _f2,
                            onChanged: (n) {
                              if (n.length > 0) {
                                FocusScope.of(context).requestFocus(_f3);
                              }
                            },
                            textAlign: TextAlign.center,
                            controller: _digit2,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(counterText: ''))),
                    Container(
                        width: MediaQuery.of(context).size.width / 10,
                        child: TextField(
                            focusNode: _f3,
                            onChanged: (n) {
                              if (n.length > 0) {
                                FocusScope.of(context).requestFocus(_f4);
                              }
                            },
                            textAlign: TextAlign.center,
                            controller: _digit3,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(counterText: ''))),
                    Container(
                        width: MediaQuery.of(context).size.width / 10,
                        child: TextField(
                            focusNode: _f4,
                            onChanged: (n) {
                              if (n.length > 0) {
                                FocusScope.of(context).requestFocus(_f5);
                              }
                            },
                            textAlign: TextAlign.center,
                            controller: _digit4,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(counterText: ''))),
                    Container(
                        width: MediaQuery.of(context).size.width / 10,
                        child: TextField(
                            focusNode: _f5,
                            onChanged: (n) {
                              if (n.length > 0) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            textAlign: TextAlign.center,
                            controller: _digit5,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(counterText: ''))),
                  ]),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 100),
                alignment: Alignment.center,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new FlatButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Color.fromRGBO(28, 96, 97, 1.0),
                        onPressed: () => initiateSignIn("S"),
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
                                  "Verificar",
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
              )
            ]));
  }

  gotoLogin() {
    //controller_0To1.forward(from: 0.0);
    _controller.animateToPage(0,
        duration: Duration(milliseconds: 800), curve: Curves.bounceOut);
  }

  gotoSignup() {
    //controller_minus1To0.reverse(from: 0.0);
    _controller.animateToPage(2,
        duration: Duration(milliseconds: 800), curve: Curves.bounceOut);
  }

  PageController _controller =
      new PageController(initialPage: 1, viewportFraction: 1.0);
  bool verify = false;
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
                    children: <Widget>[
                      loginPage(),
                      homePage(),
                      verify ? verifyPhone() : signupPage()
                    ],
                    scrollDirection: Axis.horizontal))));
  }
}
