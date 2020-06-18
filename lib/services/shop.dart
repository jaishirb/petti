import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:Petti/utils/utils.dart';

Future<List<dynamic>>getProductosService(String url) async{
  List<dynamic> data = new List<dynamic>();
  String result;
  try {
    final headers = await getHeaders();
    var response = await get(url, headers: headers);
    int statusCode = response.statusCode;
    if (statusCode == HttpStatus.ok) {
      var body = utf8.decode(response.bodyBytes);
      data = jsonDecode(body)['results'];
    } else {
      result =
      'Error getting a feed: Http status $statusCode';
    }
  } catch (exception) {
    result = 'Failed invoking the getFeed function. Exception: $exception';
  }
  print(result);
  return data;
}

Future<List<dynamic>>getProductosMoreService(int index) async{
  var url = 'http://$DOMAIN/api/v1/shop/?page$index';
  List<dynamic> data = new List<dynamic>();
  String result;
  try {
    final headers = await getHeaders();
    var response = await get(url, headers: headers);
    int statusCode = response.statusCode;
    if (statusCode == HttpStatus.ok) {
      var body = utf8.decode(response.bodyBytes);
      data = jsonDecode(body)['results'];
    } else {
      result =
      'Error getting a feed: Http status $statusCode';
    }
  } catch (exception) {
    result = 'Failed invoking the getFeed function. Exception: $exception';
  }
  print(result);
  return data;
}

Future<List<dynamic>>getProductosFilterService(String nombre) async {
  String url = 'http://$DOMAIN/api/v1/shop/filter/?nombre=$nombre';
  List<dynamic> data = new List<dynamic>();
  String result;
  try {
    final headers = await getHeaders();
    var response = await get(url, headers: headers);
    int statusCode = response.statusCode;
    if (statusCode == HttpStatus.ok) {
      var body = utf8.decode(response.bodyBytes);
      data = jsonDecode(body);
    } else {
      result =
      'Error getting a feed: Http status $statusCode';
    }
  } catch (exception) {
    result = 'Failed invoking the getFeed function. Exception: $exception';
  }
  print(result);
  return data;
}

Future<int> crearPedidoService(String data) async {
  var url = 'http://$DOMAIN/api/v1/shop/pedidos/';
  print(data);
  final headers = await getHeaders();
  Response response = await post(url, headers: headers, body: data);
  print(response.statusCode);
  var body = utf8.decode(response.bodyBytes);
  int id = jsonDecode(body)['id'];
  int statusCode = response.statusCode;
  return id;
}