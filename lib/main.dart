import 'package:flutter/material.dart';
import 'package:hangr/pages/loading_screen.dart';
import 'package:hangr/utility/themes.dart';

void main() => runApp(
      MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const Loading(),
        },
      ),
    );
