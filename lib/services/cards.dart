import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:Petti/utils/utils.dart';

Future<Map<String, dynamic>>getDataCards() async{
  var url = 'http://$DOMAIN/api/v1/mascotas/veterinarias';
  Map<String, dynamic> data;
  String result;
  try {
    var request = await get(url, headers: getHeaders());
    int statusCode = request.statusCode;
    if (statusCode == HttpStatus.ok) {
      var body = request.body;
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