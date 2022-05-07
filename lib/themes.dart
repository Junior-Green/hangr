import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;

  bool get isDarkMode => mode == ThemeMode.dark;
}

class AppTheme {
  static final dark = ThemeData(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.grey[950],
      colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color.fromARGB(255, 210, 3, 79),
          tertiary: Color.fromARGB(137, 214, 214, 214)),
      textTheme: Typography.blackCupertino);

  static final light = ThemeData(
    primaryColor: Colors.white,
    colorScheme: const ColorScheme.dark(
        primary: Color.fromARGB(255, 0, 0, 0),
        secondary: Color.fromARGB(255, 210, 3, 79),
        tertiary: Color.fromARGB(137, 214, 214, 214)),
    textTheme: Typography.whiteCupertino,
    scaffoldBackgroundColor: Colors.white,
  );
}
