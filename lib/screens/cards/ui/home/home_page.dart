import 'home_page_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Petti/screens/cards/ui/home/searchVetCare.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Provider.of<Search>(context, listen: false).search = '';
              Navigator.of(context).pop();
              },
          ),
          title: Text('Vet and care',
              style: const TextStyle(
                  fontFamily: "Billabong",
                  color: Color.fromRGBO(28, 96, 97, 1.0),
                  fontSize: 35.0)),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(40, 10, 40, 5),
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: 'Buscar',
                    suffixIcon: Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal))),
                onChanged: (val) {
                  print(val);
                  Provider.of<Search>(context, listen: false).search = val;
                },
              ),
            ),
            HomePageBody()
          ],
        ));
  }
}

class GradientAppBar extends StatelessWidget {
  final String title;
  final double barHeight = 66.0;

  GradientAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return new Container(
      padding: new EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + barHeight,
      child: new Center(
        child: new Text(
          title,
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 36.0),
        ),
      ),
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [const Color(0xFF3366FF), const Color(0xFF00CCFF)],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
    );
  }
}
