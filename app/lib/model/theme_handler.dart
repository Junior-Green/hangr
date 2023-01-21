import 'package:flutter/material.dart';

class ThemeHandler with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeHandler({ThemeMode mode = ThemeMode.system}) : _mode = mode;

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
