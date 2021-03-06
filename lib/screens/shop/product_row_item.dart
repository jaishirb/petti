import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'detail/detail_page.dart';
import 'model/app_state_model.dart';
import 'model/product.dart';
import 'styles.dart';

class ProductRowItem extends StatelessWidget {
  const ProductRowItem({
    this.index,
    this.product,
    this.lastItem,
    this.flagProduct
  });

  final Product product;
  final int index;
  final bool lastItem;
  final bool flagProduct;

  @override
  Widget build(BuildContext context) {
    final row = SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.only(
        left: 16,
        top: 8,
        bottom: 8,
        right: 8,
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 50.0,
            child: CircleAvatar(
              radius: 40.0,
              backgroundImage: CachedNetworkImageProvider(
                product.image,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.name,
                    style: Styles.productRowItemName,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  Text(
                    '\$${product.price}',
                    style: Styles.productRowItemPrice,
                  )
                ],
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              final model = Provider.of<AppStateModel>(context, listen: false);
              //model.addProductToCart(product.id);
              Navigator.of(context).push(
                new PageRouteBuilder(
                  pageBuilder: (_, __, ___) => CupertinoTabView(builder: (context) {
                    return CupertinoPageScaffold(
                      child: DetailPageMaster(product, model, flagProduct),
                    );
                  }),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                  new FadeTransition(opacity: animation, child: child),
                ) ,
              );
            },
            child: const Icon(
              CupertinoIcons.plus_circled,
              semanticLabel: 'Add',
              size: 32.0,
            ),
          ),
        ],
      ),
    );

    if (lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        Padding(
          padding: const EdgeInsets.only(
            left: 100,
            right: 16,
          ),
          child: Container(
            height: 1,
            color: Styles.productRowDivider,
          ),
        ),
      ],
    );
  }
}
