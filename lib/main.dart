import 'package:flutter/material.dart';
import 'package:hangr/pages/loading_screen.dart';
import 'package:hangr/themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
      },
    ),
  );
}
