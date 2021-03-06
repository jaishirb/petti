import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:Petti/utils/utils.dart';


Future<Map<String, dynamic>>getDataFeedService(String action, String _url) async {
  print("Staring getFeed");
  print(_url);
  Map<String, dynamic> data;
  String result;
  try {
    final headers = await getHeaders();
    var response = await get(_url, headers: headers);
    int statusCode = response.statusCode;
    if (statusCode == HttpStatus.ok) {
      var body = utf8.decode(response.bodyBytes);
      data = jsonDecode(body);
    } else {
      result = 'Error getting a feed: Http status $statusCode';
    }
  } catch (exception) {
    result = 'Failed invoking the getFeed function. Exception: $exception';
  }
  print(result);
  return data;
}

Future<int>eliminarPostService(int id) async{
  var url = 'http://$DOMAIN/api/v1/mascotas/publicaciones/$id/';
  print(id);
  print(url);
  final headers = await getHeaders();

  Response response = await delete(url, headers: headers);
  print(response.statusCode);
  int statusCode = response.statusCode;
  return statusCode;
}
