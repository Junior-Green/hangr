import 'package:flutter/material.dart';
import 'package:hangr/pages/loading_screen.dart';
import 'package:hangr/pages/premium.dart';
import 'package:hangr/services/theme_handler.dart';
import 'package:hangr/themes.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<ThemeHandler>(
      create: (_) => ThemeHandler(),
      child: Consumer<ThemeHandler>(
        builder: (_,handler,__) => MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: handler.mode,
          initialRoute: '/',
          routes: {
            '/': (_) => const LoadingScreen(),
            '/premium': (_) => const BuyPremium(),
          },
        ),
      ),
    ),
  );
}
