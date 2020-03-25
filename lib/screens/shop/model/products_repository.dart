import 'package:Petti/services/shop.dart';
import 'package:Petti/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'product.dart';

class ProductsRepository {
  static List<Product> _allProducts = <Product>[];

  /**
  static const _allProducts = <Product>[
    Product(
      category: Category.accessories,
      id: 0,
      isFeatured: true,
      name: 'Vagabond sack',
      price: 120,
    ),
    Product(
      category: Category.accessories,
      id: 1,
      isFeatured: true,
      name: 'Stella sunglasses',
      price: 58,
    ),
    Product(
      category: Category.accessories,
      id: 2,
      isFeatured: false,
      name: 'Whitney belt',
      price: 35,
    ),
    Product(
      category: Category.accessories,
      id: 3,
      isFeatured: true,
      name: 'Garden strand',
      price: 98,
    ),
    Product(
      category: Category.accessories,
      id: 4,
      isFeatured: false,
      name: 'Strut earrings',
      price: 34,
    ),
    Product(
      category: Category.accessories,
      id: 5,
      isFeatured: false,
      name: 'Varsity socks',
      price: 12,
    ),
    Product(
      category: Category.accessories,
      id: 6,
      isFeatured: false,
      name: 'Weave keyring',
      price: 16,
    ),
    Product(
      category: Category.accessories,
      id: 7,
      isFeatured: true,
      name: 'Gatsby hat',
      price: 40,
    ),
    Product(
      category: Category.accessories,
      id: 8,
      isFeatured: true,
      name: 'Shrug bag',
      price: 198,
    ),
    Product(
      category: Category.home,
      id: 9,
      isFeatured: true,
      name: 'Gilt desk trio',
      price: 58,
    ),
    Product(
      category: Category.home,
      id: 10,
      isFeatured: false,
      name: 'Copper wire rack',
      price: 18,
    ),
    Product(
      category: Category.home,
      id: 11,
      isFeatured: false,
      name: 'Soothe ceramic set',
      price: 28,
    ),
    Product(
      category: Category.home,
      id: 12,
      isFeatured: false,
      name: 'Hurrahs tea set',
      price: 34,
    ),
    Product(
      category: Category.home,
      id: 13,
      isFeatured: true,
      name: 'Blue stone mug',
      price: 18,
    ),
    Product(
      category: Category.home,
      id: 14,
      isFeatured: true,
      name: 'Rainwater tray',
      price: 27,
    ),
    Product(
      category: Category.home,
      id: 15,
      isFeatured: true,
      name: 'Chambray napkins',
      price: 16,
    ),
    Product(
      category: Category.home,
      id: 16,
      isFeatured: true,
      name: 'Succulent planters',
      price: 16,
    ),
    Product(
      category: Category.home,
      id: 17,
      isFeatured: false,
      name: 'Quartet table',
      price: 175,
    ),
    Product(
      category: Category.home,
      id: 18,
      isFeatured: true,
      name: 'Kitchen quattro',
      price: 129,
    ),
    Product(
      category: Category.clothing,
      id: 19,
      isFeatured: false,
      name: 'Clay sweater',
      price: 48,
    ),
    Product(
      category: Category.clothing,
      id: 20,
      isFeatured: false,
      name: 'Sea tunic',
      price: 45,
    ),
    Product(
      category: Category.clothing,
      id: 21,
      isFeatured: false,
      name: 'Plaster tunic',
      price: 38,
    ),
    Product(
      category: Category.clothing,
      id: 22,
      isFeatured: false,
      name: 'White pinstripe shirt',
      price: 70,
    ),
    Product(
      category: Category.clothing,
      id: 23,
      isFeatured: false,
      name: 'Chambray shirt',
      price: 70,
    ),
    Product(
      category: Category.clothing,
      id: 24,
      isFeatured: true,
      name: 'Seabreeze sweater',
      price: 60,
    ),
    Product(
      category: Category.clothing,
      id: 25,
      isFeatured: false,
      name: 'Gentry jacket',
      price: 178,
    ),
    Product(
      category: Category.clothing,
      id: 26,
      isFeatured: false,
      name: 'Navy trousers',
      price: 74,
    ),
    Product(
      category: Category.clothing,
      id: 27,
      isFeatured: true,
      name: 'Walter henley (white)',
      price: 38,
    ),
    Product(
      category: Category.clothing,
      id: 28,
      isFeatured: true,
      name: 'Surf and perf shirt',
      price: 48,
    ),
    Product(
      category: Category.clothing,
      id: 29,
      isFeatured: true,
      name: 'Ginger scarf',
      price: 98,
    ),
    Product(
      category: Category.clothing,
      id: 30,
      isFeatured: true,
      name: 'Ramona crossover',
      price: 68,
    ),
    Product(
      category: Category.clothing,
      id: 31,
      isFeatured: false,
      name: 'Chambray shirt',
      price: 38,
    ),
    Product(
      category: Category.clothing,
      id: 32,
      isFeatured: false,
      name: 'Classic white collar',
      price: 58,
    ),
    Product(
      category: Category.clothing,
      id: 33,
      isFeatured: true,
      name: 'Cerise scallop tee',
      price: 42,
    ),
    Product(
      category: Category.clothing,
      id: 34,
      isFeatured: false,
      name: 'Shoulder rolls tee',
      price: 27,
    ),
    Product(
      category: Category.clothing,
      id: 35,
      isFeatured: false,
      name: 'Grey slouch tank',
      price: 24,
    ),
    Product(
      category: Category.clothing,
      id: 36,
      isFeatured: false,
      name: 'Sunshirt dress',
      price: 58,
    ),
    Product(
      category: Category.clothing,
      id: 37,
      isFeatured: true,
      name: 'Fine lines tee',
      price: 58,
    ),
  ];
      **/

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
