import 'package:flutter/material.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String token = "";
  bool guess = true;
  String username = "";
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  _loadUserInfo() async {
    token = await SharedPreferencesHelper.getToken();
    guess = await SharedPreferencesHelper.getGuess();
    username = await SharedPreferencesHelper.getName();
//    print('--------------------------------');print(token);
    await new Future.delayed(const Duration(seconds: 4));
    if (token == "" || guess || username=='guess') {
      SharedPreferencesHelper.setGuess(false);
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50.0,
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundImage: CachedNetworkImageProvider(
                              "https://pettiapp.s3.us-east-2.amazonaws.com/images/LOGO1.png"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Text(
                        "Petti",
                        style: TextStyle(
                            color: Color.fromRGBO(28, 96, 97, 1.0),
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
