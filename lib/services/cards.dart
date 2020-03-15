import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:Petti/utils/utils.dart';

Future<List<dynamic>>getDataCardsService() async{
  var url = 'http://$DOMAIN/api/v1/mascotas/servicios';
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

Future<int> reservarService(String data) async {
  var url = 'http://$DOMAIN/api/v1/mascotas/reservas/';
  print(data);
  final headers = await getHeaders();
  Response response = await post(url, headers: headers, body: data);
  print(response.statusCode);
  int statusCode = response.statusCode;
  return statusCode;
}
