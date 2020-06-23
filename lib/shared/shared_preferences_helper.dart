import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SharedPreferencesHelper {
  static final String _token = "token";

  static Future<String>getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token) ?? "";
  }

  static Future<bool> setToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_token, value);
  }

  static Future<bool> setGuess(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('guess', value);
  }

  static Future<bool>getGuess() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('guess') ?? false;
  }

  static Future<bool> setProductos(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('productos', value);
  }

  static Future<String>getProductos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('productos') ?? '';
  }

  static Future<bool> setName(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('name', value);
  }
  static Future<bool> setEmail(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('email', value);
  }
  static getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  static Future<String>getEmailAsync() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  static Future<String>getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  static Future<String>getSection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('section') ?? "";
  }

  static Future<bool> setSection(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('section', value);
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