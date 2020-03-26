import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Category {
  all,
  accessories,
  clothing,
  home,
}

class Product {
  const Product({
    @required this.category,
    @required this.id,
    @required this.name,
    @required this.price,
    @required this.image,
    @required this.colors,
    @required this.description,
  })  : assert(category != null, 'category must not be null'),
        assert(id != null, 'id must not be null'),
        assert(name != null, 'name must not be null'),
        assert(price != null, 'price must not be null'),
        assert(image != null, 'image must not be null');

  final String category;
  final int id;
  final String name;
  final String description;
  final String price;
  final String image;
  final List<ColorSwatch<dynamic>>colors;

  String get assetName => '$id-0.jpg';
  String get assetPackage => 'shrine_images';

  @override
  String toString() => '$name (id=$id)';

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

  Map<String,dynamic> toJson(){
    return {
      "category": this.category,
      "id": this.id,
      "name": this.name,
      "description": this.description,
      "price": this.price,
      "image": this.image,
      "colors": [],
    };
  }

  static Product fromJson(Map<String, dynamic>jsonProducts){
    return Product(
      category: jsonProducts['category'],
      id: jsonProducts['id'],
      name: jsonProducts['name'],
      description: jsonProducts['description'],
      price: jsonProducts['price'],
      image: jsonProducts['image'],
      colors: jsonProducts['colores'],
    );
  }
}
