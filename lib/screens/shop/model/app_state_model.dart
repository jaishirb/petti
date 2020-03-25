import 'dart:convert';

import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'product.dart';
import 'products_repository.dart';

double _salesTaxRate = 0.06;
double _shippingCostPerItem = 7;

class AppStateModel extends foundation.ChangeNotifier {
  // All the available products.
  List<Product> _availableProducts = new List<Product>();

  // The currently selected category of products.
  Category _selectedCategory = Category.all;

  // The IDs and quantities of products currently in the cart.
  var _productsInCart = <int, int>{};
  var _colorsProductsInCart = <int, String>{};

  Map<int, int> get productsInCart {
    return Map.from(_productsInCart);
  }

  void resetProductsInCart(){
    _productsInCart = <int, int>{};
  }

  // Total number of items in the cart.
  int get totalCartQuantity {
    return _productsInCart.values.fold(0, (accumulator, value) {
      return accumulator + value;
    });
  }

  Category get selectedCategory {
    return _selectedCategory;
  }

  // Totaled prices of the items in the cart.
  double subtotalCost(List<Product> _products) {
    return _productsInCart.keys.map((id) {
      // Extended price for product line
      Product elem;
      for(var item in _products){
        if(item.id == id){
          elem = item;
          break;
        }
      }
      return int.parse(elem.price.replaceAll('.', '')) * _productsInCart[id];
    }).fold(0, (accumulator, extendedPrice) {
      return accumulator + extendedPrice;
    });
  }

  // Total shipping cost for the items in the cart.
  double get shippingCost {
    int total = 0;
    for(var elem in _productsInCart.keys){
      total += _productsInCart[elem];
    }
    if(_productsInCart.length >= 3 || total >= 3){
      return 0;
    }
    return 4500;
  }

  // Sales tax for the items in the cart

  // Total cost to order everything in the cart.
  double totalCost (List<Product>_products){
    return subtotalCost(_products) + shippingCost;
  }

  // Returns a copy of the list of available products, filtered by category.
  Future<List<Product>> getProducts() async{
    String jsonProducts = await SharedPreferencesHelper.getProductos();
    List<Product> products = (json.decode(jsonProducts) as List).map((i) => Product.fromJson(i)).toList();
    _availableProducts = products;
    return products;
  }

  // Search the product catalog
  List<Product> search(String searchTerms) {
    return new List<Product>();
    /**
    return getProducts().where((product) {
      return product.name.toLowerCase().contains(searchTerms.toLowerCase());
    }).toList();
     **/
  }

  // Adds a product to the cart.
  void addProductToCart(int productId, Color color, String cantidad) {
    var hex = '#${color.value.toRadixString(16)}';
    print(hex);
    print(cantidad);
    if (!_productsInCart.containsKey(productId)) {
      _productsInCart[productId] = int.parse(cantidad);
    } else {
      _productsInCart[productId] += int.parse(cantidad);
    }
    _colorsProductsInCart[productId] = hex;
    notifyListeners();
  }

  Map<String, dynamic>generateJSONCompra(String nombre, String email, String location){
    List<Map<String, dynamic>>individuales = new List<Map<String, dynamic>>();
    for(var elem in _productsInCart.keys){
      individuales.add({
        'producto': elem,
        'color': _colorsProductsInCart[elem],
        'cantidad': _productsInCart[elem]
      });
    }
    Map<String, dynamic>data = {
      'pedidos_individuales': individuales,
      'domicilio_cliente': location,
      'telefono_cliente': email,
      'nombre_cliente': nombre,
    };
    return data;
  }

  // Removes an item from the cart.
  void removeItemFromCart(int productId) {
    if (_productsInCart.containsKey(productId)) {
      if (_productsInCart[productId] == 1) {
        _productsInCart.remove(productId);
      } else {
        _productsInCart[productId]--;
      }
    }

    notifyListeners();
  }

  // Returns the Product instance matching the provided id.
  Product getProductById(int id) {
    //var product = _availableProducts.firstWhere((product) => product.id == id, orElse: () => null);
    //if (product == null) addPr;
    return _availableProducts.firstWhere((p) => p.id == id);
  }

  // Removes everything from the cart.
  void clearCart() {
    _productsInCart.clear();
    notifyListeners();
  }

  // Loads the list of available products from the repo.
  Future<List<Product>>loadProducts(String url) async{
    List<Product> tempProductos = await ProductsRepository.loadProducts(url);
    _availableProducts.addAll(tempProductos);
    notifyListeners();
    return tempProductos;
  }

  void setCategory(Category newCategory) {
    _selectedCategory = newCategory;
    notifyListeners();
  }
}
