import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  splashColor: Colors.transparent,
  errorColor: Colors.red,
  highlightColor: Colors.transparent,
  colorScheme: ColorScheme.dark(
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.grey[900]!,
    onSecondary: const Color.fromARGB(128, 214, 214, 214),
    tertiary: const Color.fromARGB(255, 210, 3, 79),
  ),
  textTheme: Typography.whiteCupertino,
  textSelectionTheme: const TextSelectionThemeData(
    selectionColor: Color.fromARGB(128, 214, 214, 214),
    cursorColor: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        width: 5,
        color: Color.fromARGB(255, 210, 3, 79),
      ),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        width: 20,
      ),
    ),
    labelStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Color.fromARGB(128, 214, 214, 214),
    ),
    floatingLabelAlignment: FloatingLabelAlignment.center,
  ),
);

final lightTheme = ThemeData(
  primaryColor: Colors.white,
  errorColor: Colors.red,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.grey[300]!,
    onSecondary: const Color.fromARGB(128, 180, 180, 180),
    tertiary: const Color.fromARGB(255, 210, 3, 79),
  ),
  textTheme: Typography.blackCupertino,
  scaffoldBackgroundColor: Colors.white,
  textSelectionTheme: const TextSelectionThemeData(
    selectionColor: Colors.white,
    selectionHandleColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        width: 5,
        color: Color.fromARGB(255, 210, 3, 79),
      ),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        width: 20,
      ),
    ),
    labelStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Color.fromARGB(128, 214, 214, 214),
    ),
    floatingLabelAlignment: FloatingLabelAlignment.center,
  ),
);
