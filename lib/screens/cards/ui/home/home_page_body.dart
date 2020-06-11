import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/cards.dart' as cardsp;
import '../../ui/common/plannet_summary.dart';
import 'package:Petti/screens/cards/ui/home/searchVetCare.dart';

class HomePageBody extends StatefulWidget {
  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  List<cardsp.Card> cards;
  @override
  void initState() {
    super.initState();
    cardsp.getCards().then((data) {
      setState(() {
        cards = data;
        print(cards);
      });
    });
  }

  Widget buildFeed(String search) {
    List<cardsp.Card> searching = [];
    List<String> _searching =
        Provider.of<Search>(context).search.toString().split(' ');
    if (cards != null) {
      cards.forEach((c) {
        bool add = true;
        _searching.forEach((s) {
          if (!c.location.toLowerCase().contains(s)) {
            add = false;
          }
        });
        if (add) {
          searching.add(c);
        }
      });
      return ListView.builder(
        padding: EdgeInsets.only(bottom: 70),
        itemCount: searching.length,
        //itemCount: cards.length,
        itemBuilder: (context, index) {
          return PlanetSummary(searching[index]);
          //return PlanetSummary(cards[index]);
        },
      );

      /*CustomScrollView(
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
      );*/
    } else {
      print('loading');
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    print(Provider.of<Search>(context).search +
        ':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
    return new Expanded(
      child: new Container(
        color: Colors.white,
        child: buildFeed(''),
      ),
    );
  }
}
