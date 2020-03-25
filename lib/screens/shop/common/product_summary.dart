import 'package:Petti/screens/shop/model/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../cards/model/cards.dart' as cardp;
import '../../cards/ui/common/separator.dart';
import '../detail/detail_page.dart';
import '../../cards/ui/text_style.dart';

class ProductSummary extends StatelessWidget {

  final Product product;
  final bool horizontal;

  ProductSummary(this.product, {this.horizontal = true});

  ProductSummary.vertical(this.product): horizontal = false;


  @override
  Widget build(BuildContext context) {

    final planetThumbnail = new Container(
      margin: new EdgeInsets.symmetric(
        vertical: 10.0
      ),
      alignment: horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child:  CircleAvatar(
        backgroundColor: Colors.white,
        radius: 50.0,
        child: CircleAvatar(
          radius: 40.0,
          backgroundImage: NetworkImage(
              product.image,
          ),
        ),
      ),
    );



    Widget _planetValue({String value, String image}) {
      return new Container(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Image.asset(image, height: 18.0),
            new Container(width: 16.0),
            new Text(value, style: Style.mediumTextStyle),
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
          new Container(height: 8.0),
          new Text(product.name, style: Style.titleTextStyle),
          new Container(height: 10.0),
          new Text(product.category, style: Style.commonTextStyle),
          new Separator(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: !horizontal ? <Widget>[
              new Expanded(
                flex: horizontal ? 1 : 0,
                child: _planetValue(
                  value: 'Barranquilla',
                  image: 'assets/images/ic_distance.png')

              ),
              new Container(width: 8.0),
              new Expanded(
                flex: horizontal ? 1: 0,
                child: _planetValue(
                    value: product.price + ' COP',
                    image: 'assets/images/coin.png'),
              )
            ] :
            <Widget>[
              new Expanded(
                  flex: horizontal ? 1 : 0,
                  child: _planetValue(
                      value: 'Barranquilla',
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
                      value: product.price,
                      image: 'assets/images/coin.png'):Container()
              )
            ],
          ),
        ],
      ),
    );


    final planetCard = Container(
      child: planetCardContent,
      height: horizontal ? 140.0 : 185.0,
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
              pageBuilder: (_, __, ___) => new DetailPageMaster(product, null),
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
