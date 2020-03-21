import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../model/cards.dart' as cardp;
import '../../ui/common/separator.dart';
import '../../ui/detail/detail_page.dart';
import '../../ui/text_style.dart';

class PlanetSummary extends StatelessWidget {

  final cardp.Card card;
  final bool horizontal;

  PlanetSummary(this.card, {this.horizontal = true});

  PlanetSummary.vertical(this.card): horizontal = false;


  @override
  Widget build(BuildContext context) {

    final planetThumbnail = new Container(
      margin: new EdgeInsets.symmetric(
        vertical: 10.0
      ),
      alignment: horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child: new Hero(
          tag: "planet-hero-${card.id}",
          child: CachedNetworkImage(imageUrl: card.image,
          height: 110.0,
          width: 110.0,
        ),
      ),
    );



    Widget _planetValue({String value, String image}) {
      return new Container(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Image.asset(image, height: 12.0),
            new Container(width: 8.0),
            new Text(value, style: Style.smallTextStyle),
          ]
        ),
      );
    }


    final planetCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(horizontal ? 66.0 : 16.0, horizontal ? 12.0 : 42.0, 16.0, 16.0),
      constraints: new BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          new Container(height: 4.0),
          new Text(card.name, style: Style.titleTextStyle),
          new Container(height: 10.0),
          new Text(card.location, style: Style.commonTextStyle),
          new Separator(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: !horizontal ? <Widget>[
              new Expanded(
                flex: horizontal ? 1 : 0,
                child: _planetValue(
                  value: card.distance,
                  image: 'assets/images/ic_distance.png')

              ),
              new Container(width: 8.0),
              new Expanded(
                flex: horizontal ? 1: 0,
                child: _planetValue(
                    value: card.gravity,
                    image: 'assets/images/coin.png'),
              )
            ] :
            <Widget>[
              new Expanded(
                  flex: horizontal ? 1 : 0,
                  child: _planetValue(
                      value: card.distance,
                      image: 'assets/images/ic_distance.png')

              ),

            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(height: 4.0),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                  flex: horizontal ? 1 : 0,
                  child: horizontal ? _planetValue(
                      value: card.gravity,
                      image: 'assets/images/coin.png'):Container()
              )
            ],
          ),
        ],
      ),
    );


    final planetCard = Container(
      child: planetCardContent,
      height: horizontal ? 140.0 : 170.0,
      margin: horizontal
        ? new EdgeInsets.only(left: 46.0)
        : new EdgeInsets.only(top: 72.0),
      padding: new EdgeInsets.only(bottom: 5),
      decoration: new BoxDecoration(
        color: Color.fromRGBO(35, 100, 105, 1.0),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: new Offset(0.0, 10.0),
          ),
        ],
      ),
    );


    return new GestureDetector(
      onTap: horizontal
          ? () => Navigator.of(context).push(
            new PageRouteBuilder(
              pageBuilder: (_, __, ___) => new DetailPage(card),
              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                new FadeTransition(opacity: animation, child: child),
              ) ,
            )
          : null,
      child: new Container(
        margin: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: new Stack(
            children: <Widget>[
              planetCard,
              planetThumbnail,
            ],
          ),
        ),
      )
    );
  }
}
