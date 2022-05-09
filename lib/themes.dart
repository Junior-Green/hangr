import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;

  bool get isDarkMode => mode == ThemeMode.dark;
}

class AppTheme {
  static final dark = ThemeData(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Color.fromARGB(255, 210, 3, 79),
          tertiary: Colors.grey[900]),
      textTheme: Typography.blackCupertino);

  static final light = ThemeData(
    primaryColor: Colors.white,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme.dark(
        primary: Color.fromARGB(255, 0, 0, 0),
        secondary: Color.fromARGB(255, 210, 3, 79),
        tertiary: Colors.grey[900]),
    textTheme: Typography.whiteCupertino,
    scaffoldBackgroundColor: Colors.white,
  );
}
