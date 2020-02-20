import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SharedPreferencesHelper {
  static final String _token = "token";

  static getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token) ?? "";
  }

  static Future<bool> setToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_token, value);
  }

  static Future<bool> setName(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('name', value);
  }
  static Future<bool> setEmail(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('email', value);
  }
  static Future<String> getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  static Future<String> getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  static void removeToken() {
    SharedPreferencesHelper.setToken('').then((bool v) => print('ready!'));
  }

  static void removeName(){
    SharedPreferencesHelper.setName('').then((bool v) => print('ready!'));
  }

  static void removeEmail(){
    SharedPreferencesHelper.setEmail('').then((bool v) => print('ready!'));
  }

}