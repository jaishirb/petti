import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:Petti/utils/utils.dart';


Future<List<dynamic>>getDataFeedService(String action) async {
  print("Staring getFeed");
  String _action;
  switch(action){
    case 'Adopción':
      _action = 'adopcion';
      break;
    case 'Compra/venta':
      _action = 'compraventa';
      break;
    case 'Parejas':
      _action = 'parejas';
      break;
  }
  var url = 'http://$DOMAIN/api/v1/mascotas/publicaciones/?action=$_action';
  List<dynamic> data;
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
