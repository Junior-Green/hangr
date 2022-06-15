import 'package:flutter/material.dart';
import 'package:hangr/pages/loading_screen.dart';
import 'package:hangr/themes.dart';

main() => runApp(MaterialApp(
        themeMode: ThemeMode.system,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => const Loading(),
        }));
