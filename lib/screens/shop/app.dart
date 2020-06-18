import 'package:provider/provider.dart';

import 'model/app_state_model.dart';
import 'search_tab.dart';
import 'product_list_tab.dart';
import 'shopping_cart_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

int _cartItemCount = 0;

class CupertinoStoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _cartItemCount = Provider.of<AppStateModel>(context).totalProductsCount;
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Pettishop',
              style: const TextStyle(
                  fontFamily: "Billabong",
                  color: Color.fromRGBO(28, 96, 97, 1.0),
                  fontSize: 35.0)),
          centerTitle: true,
          backgroundColor: Colors.white,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(alignment: Alignment.center, children: <Widget>[
                Icon(Icons.shopping_cart, color: Colors.teal, size: 35),
                Container(
                    alignment: Alignment.bottomRight,
                    width: 40,
                    child: Stack(alignment: Alignment.center, children: [
                      Icon(Icons.brightness_1, color: Colors.amber, size: 22),
                      Text(_cartItemCount.toString(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ]))
              ]),
            )
          ],
        ),
        body: CupertinoStoreHomePage());
  }
}

class CupertinoStoreHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), title: Text('Productos')),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search), title: Text('Buscar')),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shopping_cart), title: Text('Carrito')),
        ],
      ),
      tabBuilder: (context, index) {
        CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                //navigationBar: CupertinoNavigationBar(leading: CupertinoNavigationBarBackButton(),                ),
                child: ProductList(),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: SearchTab(),
              );
            });
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: ShoppingCartTab(),
              );
            });
            break;
        }
        return returnValue;
      },
    );
  }
}
