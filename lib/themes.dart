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
        primary: Colors.black,
        onPrimary: Colors.white,
        tertiary: Color.fromARGB(255, 210, 3, 79),
        secondary: Colors.grey[900]!,
        onSecondary: Color.fromARGB(128, 214, 214, 214),
      ),
      textTheme: Typography.whiteCupertino);

  static final light = ThemeData(
    primaryColor: Colors.white,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.grey[300]!,
        onSecondary: Color.fromARGB(128, 180, 180, 180),
        tertiary: Color.fromARGB(255, 210, 3, 79)),
    textTheme: Typography.blackCupertino,
    scaffoldBackgroundColor: Colors.white,
  );
}
