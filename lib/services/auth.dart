import 'dart:convert';

import 'package:Petti/utils/utils.dart';
import 'package:http/http.dart';

String auth_endpoint = 'http://$DOMAIN/api/v1/users/';
String signup_endpoint = 'http://$DOMAIN/api/v1/signup/';
String profiles_endpoint = 'http://$DOMAIN/api/v1/profiles/';

Future<String> authBackend(String data) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  Response response = await post(auth_endpoint, headers: headers, body: data);
  int statusCode = response.statusCode;
  var body = response.body;
  var values = jsonDecode(response.body);
  print(values);
  if(values.containsKey('key')){
    return values['key'].toString();
  }
  return null;
}

Future<String> signup(String data) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  Response response = await post(signup_endpoint, headers: headers, body: data);
  int statusCode = response.statusCode;
  var body = response.body;
  var values = jsonDecode(response.body);
  print(values);
  if(values.containsKey('key')){
    return values['key'].toString();
  }
  return null;
}

Future<bool> generateCode(String phone) async {
  Map<String, String> headers = {"Content-type": "application/json"};
  Response response = await post(profiles_endpoint + 'generate_code/',
      headers: headers, body: phone);
  int statusCode = response.statusCode;
  var body = response.body;
  var values = jsonDecode(response.body);
  if(statusCode==200){
    return true;
  }
  return false;
}