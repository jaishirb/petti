import 'dart:convert';
import 'search_bar.dart';
import 'model/product.dart';
import 'product_row_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:Petti/services/shop.dart';
import 'package:Petti/screens/shop/product_list_tab.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() {
    return _SearchTabState();
  }
}

class _SearchTabState extends State<SearchTab> {
  TextEditingController _controller;
  FocusNode _focusNode;
  String _terms = '';
  var model;
  List<Product>results = new List<Product>();

  @override
  void initState() {
    initPlatform();
    super.initState();
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
  }

  Future<List<Product>> getProducts() async{
    String jsonProducts = await SharedPreferencesHelper.getProductos();
    List<Product> products = (json.decode(jsonProducts) as List).map((i) => Product.fromJson(i)).toList();
    return products;
  }

  Future<List<Product>> search(String searchTerms) async{
    List<Product> products = List<Product>();
    return products;
  }

  static MaterialColor hexToColor(String code) {
    var _code = int.parse(code.substring(1, 7), radix: 16) + 0xFF000000;
    MaterialColor myColor =  MaterialColor(_code,
        {
          50 :  Color(_code),
          100 : Color(_code),
          200 : Color(_code),
          300 : Color(_code),
          400 : Color(_code),
          500 : Color(_code),
          600 : Color(_code),
          700 : Color(_code),
          800 : Color(_code),
          900 : Color(_code)});
    return myColor;
  }

  buscar(String nombre) async{
    List<dynamic>data = await getProductosFilterService(nombre);
    if(data.length > 0){
      results = new List<Product>();
      List<Product>tempResults = new List<Product>();
      for(Map producto in data){
        String name = producto['nombre'];
        int separador = 3;
        if(name.length > 21){
          separador = 2;
        }
        var arrayNombre = producto['nombre'].toString().split(' ');
        if(arrayNombre.length > separador){
          name = '';
          int index = 1;
          for(var word in arrayNombre){
            if(index == separador){
              name += ' ' + word + '\n';
            }else{
              name += ' ' + word;
            }
            index+=1;
          }
        }
        List<ColorSwatch<dynamic>>_colors = new List<ColorSwatch<dynamic>>();
        for(var color in producto['colores']){
          _colors.add(hexToColor(color['color'].toString())
          );
        }
        Product _producto = new Product(
          category: producto['categoria_read'],
          id: producto['id'],
          name: name,
          description: producto['descripcion'],
          price: producto['precio_read'],
          image: producto['imagen'],
          colors: _colors,
        );
        if(!ProductListTab.products.contains(_producto)){
          ProductListTab.products.add(_producto);
        }
        tempResults.add(_producto);
      }
      setState(() {
        results.addAll(tempResults);
      });
    }else{
      setState(() {
        results = new List<Product>();
      });
    }
  }

  initPlatform() async{
    search(_terms).then((value){
      print(value);
      setState(() {
        print(value.length);
        results = value;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controller.text;
      if(_terms == '' || _terms == ' '){
        initPlatform();
      }else{
        buscar(_terms);
      }
    });
  }

  Widget buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            buildSearchBox(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => ProductRowItem(
                      index: index,
                      product: results[index],
                      lastItem: index == results.length - 1,
                      flagProduct: false,
                    ),
                itemCount: results.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
