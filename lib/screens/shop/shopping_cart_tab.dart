import 'dart:convert';

import 'package:Petti/screens/posts/image_post.dart';
import 'package:Petti/screens/shop/product_list_tab.dart';
import 'package:Petti/services/shop.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';
import 'model/product.dart';
import 'styles.dart';

const double _kDateTimePickerHeight = 216;

class ShoppingCartTab extends StatefulWidget {
  @override
  _ShoppingCartTabState createState() {
    return _ShoppingCartTabState();
  }
}

class _ShoppingCartTabState extends State<ShoppingCartTab> {
  String name;
  String email;
  String location;
  String pin;
  List<Product> _availableProducts = new List<Product>();
  DateTime dateTime = DateTime.now();

  @override
  initState(){
    getProducts();
    super.initState();
  }

  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  Future<List<Product>> getProducts() async{
    String jsonProducts = await SharedPreferencesHelper.getProductos();
    //List<Product> products = (json.decode(jsonProducts) as List).map((i) => Product.fromJson(i)).toList();
    List<Product> products = ProductListTab.products;
    setState(() {
      _availableProducts = products;
    });
    return products;
  }

  Widget _buildNameField() {
    return CupertinoTextField(
      prefix: const Icon(
        CupertinoIcons.person_solid,
        color: CupertinoColors.lightBackgroundGray,
        size: 28,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      clearButtonMode: OverlayVisibilityMode.editing,
      textCapitalization: TextCapitalization.words,
      autocorrect: false,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0,
            color: CupertinoColors.inactiveGray,
          ),
        ),
      ),
      placeholder: 'Nombre',
      onChanged: (newName) {
        setState(() {
          name = newName;
        });
      },
    );
  }

  Widget _buildEmailField() {
    return CupertinoTextField(
      prefix: Icon(
        CupertinoIcons.phone_solid,
        color: CupertinoColors.lightBackgroundGray,
        size: 28,
      ),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      clearButtonMode: OverlayVisibilityMode.editing,
      keyboardType: TextInputType.phone,
      autocorrect: false,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0,
            color: CupertinoColors.inactiveGray,
          ),
        ),
      ),
      placeholder: 'Teléfono',
      onChanged: (newName) {
        setState(() {
          email = newName;
        });
      },
    );
  }

  Widget _buildLocationField() {
    return CupertinoTextField(
      prefix: Icon(
        CupertinoIcons.location_solid,
        color: CupertinoColors.lightBackgroundGray,
        size: 28,
      ),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      clearButtonMode: OverlayVisibilityMode.editing,
      textCapitalization: TextCapitalization.words,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0,
            color: CupertinoColors.inactiveGray,
          ),
        ),
      ),
      placeholder: 'Dirección',
      onChanged: (newName) {
        setState(() {
          location = newName;
        });
      },
    );
  }

  Widget _buildDateAndTimePicker(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const <Widget>[
                Icon(
                  CupertinoIcons.clock,
                  color: CupertinoColors.lightBackgroundGray,
                  size: 28,
                ),
                SizedBox(width: 6),
                Text(
                  'Fecha de entrega',
                  style: Styles.deliveryTimeLabel,
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              DateFormat.yMd().add_jm().format(dateTime.add(new Duration(days: 1))),
              style: Styles.deliveryTime,
            ),
          ],
        )
      ],
    );
  }

  Future<void> _asyncConfirmDialog(BuildContext _context, AppStateModel model) async {
    return showCupertinoDialog<void>(
      context: _context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('¿Estás seguro que deseas vaciar el carrito?'),
          content: Text('Si vaceas el carrito todos los items que seleccionaste se eliminarán.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Aceptar'),
              onPressed: () {
                setState(() {
                  model.resetProductsInCart();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pedidoExitosoDialog(BuildContext _context, AppStateModel model) async {
    return showCupertinoDialog<void>(
      context: _context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Éxito'),
          content: Text('¡Pedido enviado exitosamente!\npronto un agente se contactará contigo.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  model.resetProductsInCart();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pedidoFailDialog(BuildContext _context) async {
    return showCupertinoDialog<void>(
      context: _context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Problemas'),
          content: Text('Oops, ha ocurido un error al crear tu pedido, intentalo luego.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _missingFieldsDialog(BuildContext _context) async {
    return showCupertinoDialog<void>(
      context: _context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Por favor diligencie todos los campos de manera correcta.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _enviarPedidoConfirmDialog(BuildContext _context, AppStateModel model) async {
    crearCompra(model).then((value){
      if(value){
        _pedidoExitosoDialog(context, model);
      }else{
        _pedidoFailDialog(context);
      }
    });
  }


  Product getProductById(int id){
    getProducts();
    return _availableProducts.firstWhere((p) => p.id == id);
  }

  SliverChildBuilderDelegate _buildSliverChildBuilderDelegate(
      AppStateModel model) {
    return SliverChildBuilderDelegate(
      (context, index) {
        final productIndex = index - 4;
        switch (index) {
          case 0:
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildNameField(),
            );
          case 1:
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildEmailField(),
            );
          case 2:
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLocationField(),
            );
          case 3:
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: _buildDateAndTimePicker(context),
            );

          default:
            if(model.productsInCart.length > productIndex && _availableProducts.length == 0){
              getProducts().then((value){
                return ShoppingCartItem(
                  index: index,
                  product: getProductById(
                      model.productsInCart.keys.toList()[productIndex]),
                  quantity: model.productsInCart.values.toList()[productIndex],
                  lastItem: productIndex == model.productsInCart.length - 1,
                  formatter: _currencyFormat,
                );
              });
            }
            if (model.productsInCart.length > productIndex && _availableProducts.length >0) {
              return ShoppingCartItem(
                index: index,
                product: getProductById(
                    model.productsInCart.keys.toList()[productIndex]),
                quantity: model.productsInCart.values.toList()[productIndex],
                lastItem: productIndex == model.productsInCart.length - 1,
                formatter: _currencyFormat,
              );
            } else if (model.productsInCart.keys.length == productIndex &&
                model.productsInCart.isNotEmpty) {
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Domicilio '
                              '${_currencyFormat.format(model.shippingCost(_availableProducts))}',
                              style: Styles.productRowItemPrice,
                            ),
                            const SizedBox(height: 6),
                            /**
                            Text(
                              'Tax ${_currencyFormat.format(model.tax)}',
                              style: Styles.productRowItemPrice,
                            ),
                             **/
                            const SizedBox(height: 6),
                            Text(
                              'Total  ${_currencyFormat.format(model.totalCost(_availableProducts))}',
                              style: Styles.productRowTotal,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 25.0),
                        child:   Align(
                          alignment: Alignment.bottomCenter,
                          child: ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                child: Text('Enviar pedido'),
                                color: Colors.green,
                                onPressed: () {
                                  if(name != null && email != null && email.length == 10 && location != null){
                                    _enviarPedidoConfirmDialog(context, model);
                                  }else{
                                    _missingFieldsDialog(context);
                                  }
                                },
                              ),
                              FlatButton(
                                child: Text('Vaciar carrito'),
                                color: Colors.red,
                                onPressed: () {
                                  _asyncConfirmDialog(context, model);
                                },
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  )
                ],
              );
            }
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        return CustomScrollView(
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Carrito de compras'),
            ),
            SliverSafeArea(
              top: false,
              minimum: const EdgeInsets.only(top: 4),
              sliver: SliverList(
                delegate: _buildSliverChildBuilderDelegate(model),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> crearCompra(AppStateModel model) async{
    Map<String, dynamic> data = model.generateJSONCompra(name, email, location);
    int statusCode = await crearPedidoService(json.encode(data));
    return statusCode == 201;
  }


}

class ShoppingCartItem extends StatelessWidget {
  const ShoppingCartItem({
    @required this.index,
    @required this.product,
    @required this.lastItem,
    @required this.quantity,
    @required this.formatter,
  });

  final Product product;
  final int index;
  final bool lastItem;
  final int quantity;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final row = SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          top: 8,
          bottom: 8,
          right: 8,
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: product.image,
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          product.name,
                          style: Styles.productRowItemName,
                        ),
                        Text(
                          '${formatter.format(quantity * int.parse(product.price.replaceAll('.', '')))}',
                          style: Styles.productRowItemName,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      '${quantity > 1 ? '$quantity x ' : ''}'
                      '${formatter.format(int.parse(product.price.replaceAll('.', '')))}',
                      style: Styles.productRowItemPrice,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return row;
  }
}
