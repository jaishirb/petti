import 'package:Petti/shared/shared_preferences_helper.dart';

const DOMAIN = "52.24.128.245/petti";

getHeaders(){
  final token = SharedPreferencesHelper.getToken();
  Map<String, String> headers = {
    "Content-type": "application/json",
    "Authorization": "Token $token"
  };
}