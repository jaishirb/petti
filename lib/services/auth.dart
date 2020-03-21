import 'dart:convert';

import 'package:Petti/utils/utils.dart';
import 'package:http/http.dart';

String auth_endpoint = 'http://$DOMAIN/api/v1/users/';

Future<String> authBackend(String data) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  Response response = await post(auth_endpoint, headers: headers, body: data);
  int statusCode = response.statusCode;
  var body = response.body;
  var values = jsonDecode(response.body);
  return values['key'].toString();
}