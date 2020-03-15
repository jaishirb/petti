import 'dart:convert';

import 'package:Petti/screens/cards/ui/detail/dialog.dart';
import 'package:Petti/services/cards.dart';
import 'package:flutter/material.dart';
import '../../model/cards.dart' as cardp;
import '../../ui/common/plannet_summary.dart';
import '../../ui/common/separator.dart';
import '../../ui/text_style.dart';
import 'package:progress_dialog/progress_dialog.dart';


class DetailPage extends StatelessWidget {

  final cardp.Card planet;
  ProgressDialog pr;

  DetailPage(this.planet);

  void book(BuildContext context)async{
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    pr.style(
        message: 'Creando reserva...',
        borderRadius: 0.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 5.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 7.0, fontWeight: FontWeight.w200),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w300)
    );
    pr.show();
    int statusCode = await reservarService(jsonEncode({'servicio': int.parse(planet.id)}));
    Future.delayed(Duration(seconds: 3)).then((onValue){
      print("PR status  ${pr.isShowing()}" );
      if(pr.isShowing()){
        pr.hide();
      }
      String title, description;
      if(statusCode == 200 || statusCode == 201){
        title = "¡Muy bien!";
        description = "Hemos recibido tu reserva, \n¡pronto un asesor te contactará!";
      }else{
        title = "Oops";
        description = "Parece que ha habido un error, \nintenta más tarde.";
      }
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: title,
          description: description,
          buttonText: "Okay",
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        constraints: new BoxConstraints.expand(),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                 Colors.white,
                 Colors.white
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
            Container(
              margin: const EdgeInsets.only(bottom: 25.0),
              child:   Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    book(context);
                  },
                  icon: Icon(Icons.accessibility),
                  label: Text("Adquirir servicio"),
                  backgroundColor: Color.fromRGBO(28, 96, 97, 1.0),
                ),
              ),
            )
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
                  Color.fromRGBO(28, 96, 97, 0.8),
                  Color.fromRGBO(89, 192, 154, 0.8),
                ],
                stops: [0.5, 1.0],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
              ),
            ),
          );
  }

  Container _getContent() {
    final _overviewTitle = "Descripción".toUpperCase();
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
                          planet.description, style: Style.commonTextStyle
                      ),

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