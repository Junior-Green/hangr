import 'package:flutter/material.dart';
import 'package:hangr/pages/home.dart';
import 'package:hangr/pages/loading_screen.dart';
import 'package:hangr/themes.dart';
import 'package:provider/provider.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    builder: (context, _) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return MaterialApp(
          themeMode: themeProvider.mode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          initialRoute: '/',
          routes: {
            '/': (context) => const Loading(),
            '/home': (context) => const DefaultTabController(
                length: 3, child: Home(), initialIndex: 1),
            '/location': (context) => SizedBox(),
          });
    },
  ));
}
