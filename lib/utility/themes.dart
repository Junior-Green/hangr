import 'package:flutter/material.dart';

final darkTheme = ThemeData(
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme.dark(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.grey[900]!,
        onSecondary: const Color.fromARGB(128, 214, 214, 214),
        tertiary: const Color.fromARGB(255, 210, 3, 79),),
    textTheme: Typography.whiteCupertino,);

final lightTheme = ThemeData(
  primaryColor: Colors.white,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  colorScheme: ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.grey[300]!,
      onSecondary: const Color.fromARGB(128, 180, 180, 180),
      tertiary: const Color.fromARGB(255, 210, 3, 79),),
  textTheme: Typography.blackCupertino,
  scaffoldBackgroundColor: Colors.white,
);
