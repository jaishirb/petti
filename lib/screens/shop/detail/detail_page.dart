import 'package:Petti/screens/shop/model/app_state_model.dart';
import 'package:Petti/screens/shop/model/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import '../app.dart';
import '../common/product_summary.dart';
import '../../cards/ui/common/separator.dart';
import '../../cards/ui/text_style.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../product_list_tab.dart';


class DetailPageMaster extends StatelessWidget {
  final Product product;
  final model;
  DetailPageMaster(this.product, this.model);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Petti",
      home: DetailPageMinor(product, model),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DetailPageMinor extends StatefulWidget{
  final Product product;
  final model;
  DetailPageMinor(this.product, this.model);
  @override
  State<StatefulWidget> createState() {
    return DetailPage(product, model);
  }

}
class DetailPage extends State<DetailPageMinor> {

  final Product product;
  final AppStateModel model;
  ProgressDialog pr;
  Color colorSelected;
  TextEditingController cantidadController = new TextEditingController();
  List _cities = new List<String>.generate(50, (i) => (i + 1).toString());

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentCity;

  DetailPage(this.product, this.model);

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentCity = _dropDownMenuItems[0].value;
    colorSelected = product.colors[0];
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _cities) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(
          value: city,
          child: new Text(city)
      ));
    }
    return items;
  }

  Future<void> _anadidoDialog(BuildContext _context) async {
    return showCupertinoDialog<void>(
      context: _context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Éxito'),
          content: Text('¡Producto añadido al carrito!'),
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

  void book(BuildContext context)async{
    model.addProductToCart(product.id, colorSelected, _currentCity);
    _anadidoDialog(context);
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
            _getContent(context),
            _getToolbar(context),
          ],
        ),
      ),
    );
  }

  Container _getBackground () {
    return new Container(
            child: new Image.network(product.image,
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

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentCity = selectedCity;
    });
  }

  Container _getContent(BuildContext context) {
    final _overviewTitle = "Descripción".toUpperCase();

    return new Container(
            child: new ListView(
              padding: new EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 32.0),
              children: <Widget>[
                new ProductSummary(product,
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
                          product.description, style: Style.commonTextStyle
                      ),
                      new DropdownButton(
                        value: _currentCity,
                        items: _dropDownMenuItems,
                        onChanged: changedDropDownItem,
                      )
                    ],
                  ),

                ),
                new Container(
                  padding: EdgeInsets.only(left: 12.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MaterialColorPicker(
                        shrinkWrap: true,
                        allowShades: false,
                        circleSize: 35,
                        onColorChange: (Color color) {
                          setState(() {
                            colorSelected = color;
                          });
                        },
                        selectedColor: product.colors[0],
                        colors: product.colors,
                      ),

                    ],
                  ),

                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 25.0, top: 25.0),
                  child:   Align(
                    alignment: Alignment.bottomCenter,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        print('------------!!!');
                        print(cantidadController.text);
                        book(context);
                      },
                      icon: Icon(Icons.add_shopping_cart),
                      label: Text("Añadir al carrito"),
                      backgroundColor: Color.fromRGBO(28, 96, 97, 1.0),
                    ),
                  ),
                )


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
            child: CupertinoNavigationBarBackButton(
              color: Colors.black,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>
              CupertinoApp(
                theme: new CupertinoThemeData(
                  brightness: Brightness.light,
                  primaryColor: Color.fromRGBO(28, 96, 97, 1.0),
                  barBackgroundColor: CupertinoColors.white,
                  scaffoldBackgroundColor: CupertinoColors.white,
                  textTheme: new CupertinoTextThemeData(
                    primaryColor: CupertinoColors.white,
                  ),
                ),
                debugShowCheckedModeBanner: false,
                home: ProductList(),
              ))),
            ),
          );
  }

  @override
  State<StatefulWidget> createState() {
   return DetailPage(product, model);
  }
}