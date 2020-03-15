import 'package:flutter/material.dart';
import '../../model/cards.dart' as cardsp;
import '../../ui/common/plannet_summary.dart';

class HomePageBody extends StatefulWidget {

  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  List<cardsp.Card>cards;
  @override
  void initState() {
    super.initState();
    cardsp.getCards().then((data){
      setState(() {
          cards = data;
          print(cards);
      });
    });

  }

  buildFeed() {
    if (cards != null) {
      return  new CustomScrollView(
        scrollDirection: Axis.vertical,
        shrinkWrap: false,
        slivers: <Widget>[
          new SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            sliver: new SliverList(
              delegate: new SliverChildBuilderDelegate(
                    (context, index) => new PlanetSummary(cards[index]),
                childCount: cards.length,
              ),
            ),
          )
        ],
      );
    } else {
      print('loading');
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      child: new Container(
        color: Colors.white,
        child: buildFeed(),
      ),
    );
  }
}
