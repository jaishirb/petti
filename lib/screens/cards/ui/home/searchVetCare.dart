import 'package:flutter/material.dart';

class Search with ChangeNotifier {
  String _search = '';
  get search {
    return _search;
  }

  set search(String s) {
    this._search = s.toLowerCase();
    notifyListeners();
  }
}