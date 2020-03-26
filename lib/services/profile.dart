import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:Petti/utils/utils.dart';

Future<Map>getDataProfileService() async{
  var url = 'http://$DOMAIN/api/v1/profiles/get_profile';
  Map data;
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

Future<int> actualizarProfileService(String data, int id) async {
  var url = 'http://$DOMAIN/api/v1/profiles/$id/';
  print(data);
  final headers = await getHeaders();
  print(data);

  Response response = await put(url, headers: headers, body: data);
  print(response.statusCode);
  int statusCode = response.statusCode;
  return statusCode;
}