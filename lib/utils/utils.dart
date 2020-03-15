import 'package:Petti/shared/shared_preferences_helper.dart';

const DOMAIN = "52.24.128.245/petti";

Future<Map<String, String>>getHeaders() async{
  final token = await SharedPreferencesHelper.getToken();
  Map<String, String> headers = {
    "Content-type": "application/json",
    "Authorization": "Token " + token
  };
  print(headers);
  return headers;
}