import 'dart:convert';

import 'package:Petti/screens/shop/model/product.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:Petti/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';
import 'product_row_item.dart';

class ProductList extends StatefulWidget {
  ProductListTab createState() => new ProductListTab();
}

class ProductListTab extends State<ProductList>  {
  List<Product>products = new List<Product>();
  ScrollController _scrollController = new ScrollController();
  int loads = 2;
  String jsonProducts;
  bool loading = false;
  bool flag = true;

  @override
  void initState() {
    super.initState();
    AppStateModel().loadProducts(null).then((productos){
      setState(() {
        products = productos;
        jsonProducts = jsonEncode(products.map((i) => i.toJson()).toList()).toString();
        SharedPreferencesHelper.setProductos(jsonProducts);
      });
    });
    _scrollController.addListener((){
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent/2 && flag){
        setState(() {
          loading = true;
        });
        loadMore();
        loads += 1;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  loadMore() async{
    var url = 'http://$DOMAIN/api/v1/shop/?page=$loads';
    AppStateModel().loadProducts(url).then((productos){
      setState(() {
        if(productos.length == 0){
          flag = false;
        }else{
          flag = true;
        }
        products.addAll(productos);
        jsonProducts = jsonEncode(products.map((i) => i.toJson()).toList()).toString();
        SharedPreferencesHelper.setProductos(jsonProducts);
        loading = false;
      });
    });
  }

  buildFeed() {
    if (products.length != 0) {
      return Consumer<AppStateModel>(
        builder: (context, model, child) {
          return CustomScrollView(
            controller: _scrollController,
            semanticChildCount: products.length,
            slivers: <Widget>[
              const CupertinoSliverNavigationBar(
                largeTitle: Text('Pettishop',
                    style: const TextStyle(
                        fontFamily: "Billabong", color: Color.fromRGBO(28, 96, 97, 1.0),
                        fontSize: 35.0)),
              ),
              SliverSafeArea(
                top: false,
                minimum: const EdgeInsets.only(top: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index < products.length) {
                        return ProductRowItem(
                          index: index,
                          product: products[index],
                          lastItem: index == products.length - 1,
                        );
                      }

                      return null;
                    },
                  ),
                ),
              )
            ],
          );
        },
      );
    } else {
      return new Container(
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
          ),
          child: new Center(child: const CupertinoActivityIndicator()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return buildFeed();
  }
}