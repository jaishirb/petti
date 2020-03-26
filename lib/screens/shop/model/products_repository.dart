import 'package:Petti/services/shop.dart';
import 'package:Petti/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'product.dart';

class ProductsRepository {
  static List<Product> _allProducts = <Product>[];


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

  static Future<List<Product>> loadProducts(String url) async{
    if(url == null){
      url = 'http://$DOMAIN/api/v1/shop/';
    }
    List<dynamic> data = await getProductosService(url);
    _allProducts = new List<Product>();
    if(data.length > 0){
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
        _allProducts.add(_producto);
      }
    }
    /**
    if (category == Category.all) {
      return _allProducts;
    } else {
      return _allProducts.where((p) => p.category == category).toList();
    }
     **/
    return _allProducts;
  }
}
