import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:Petti/screens/home.dart';
import 'package:Petti/screens/login.dart';
import 'package:Petti/screens/landing.dart';
import 'package:Petti/screens/shop/app.dart';
import 'package:Petti/screens/posts/feed.dart';
import 'screens/cards/ui/home/searchVetCare.dart';
import 'package:Petti/screens/shop/model/app_state_model.dart';
//import 'package:intl/intl.dart';
//import 'package:Petti/screens/posts/main.dart';

void main() => runApp(ChangeNotifierProvider<AppStateModel>(
      child: MyApp(),
      create: (context) => AppStateModel()..loadProducts(null),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Map<int, Color> color = {
      50: Color.fromRGBO(28, 96, 97, .1),
      100: Color.fromRGBO(28, 96, 97, .2),
      200: Color.fromRGBO(28, 96, 97, .3),
      300: Color.fromRGBO(28, 96, 97, .4),
      400: Color.fromRGBO(28, 96, 97, .5),
      500: Color.fromRGBO(28, 96, 97, .6),
      600: Color.fromRGBO(28, 96, 97, .7),
      700: Color.fromRGBO(28, 96, 97, .8),
      800: Color.fromRGBO(28, 96, 97, .9),
      900: Color.fromRGBO(28, 96, 97, 1),
    };
    return ChangeNotifierProvider(
        create: (context) => Search(),
        child:MaterialApp(
      title: 'Petti',
      routes: {
        '/': (context) => Landing(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/posts': (context) => Feed(),
        '/shop': (context) => CupertinoStoreApp(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF1c6061, color),
        buttonColor: Colors.green,
        primaryIconTheme: IconThemeData(color: Colors.black),
      ),
    ));
  }
}
