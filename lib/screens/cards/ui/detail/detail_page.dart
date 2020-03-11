import 'package:flutter/material.dart';
import '../../model/planets.dart';
import '../../ui/common/plannet_summary.dart';
import '../../ui/common/separator.dart';
import '../../ui/text_style.dart';


class DetailPage extends StatelessWidget {

  final Planet planet;

  DetailPage(this.planet);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        constraints: new BoxConstraints.expand(),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(28, 96, 97, 1.0),
                  Color.fromRGBO(89, 192, 154, 1.0),
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
        child: new Stack (
          children: <Widget>[
            _getBackground(),
            _getGradient(),
            _getContent(),
            _getToolbar(context),
          ],
        ),
      ),
    );
  }

  Container _getBackground () {
    return new Container(
            child: new Image.network(planet.picture,
              fit: BoxFit.cover,
              height: 300.0,
            ),
            constraints: new BoxConstraints.expand(height: 295.0),
          );
  }

  Container _getGradient() {
    return new Container(
            margin: new EdgeInsets.only(top: 190.0),
            height: 110.0,
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors: <Color>[
                  Color.fromRGBO(89, 192, 154, 1.0),
                  Color.fromRGBO(21, 157, 99, 1.0),
                ],
                stops: [0.0, 0.9],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
              ),
            ),
          );
  }

  Container _getContent() {
    final _overviewTitle = "Overview".toUpperCase();
    return new Container(
            child: new ListView(
              padding: new EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 32.0),
              children: <Widget>[
                new PlanetSummary(planet,
                  horizontal: false,
                ),
                new Container(
                  padding: new EdgeInsets.symmetric(horizontal: 32.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(_overviewTitle,
                        style: Style.headerTextStyle,),
                      new Separator(),
                      new Text(
                          planet.description, style: Style.commonTextStyle),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Container _getToolbar(BuildContext context) {
    return new Container(
            margin: new EdgeInsets.only(
                top: MediaQuery
                    .of(context)
                    .padding
                    .top),
            child: new BackButton(color: Colors.white),
          );
  }
}