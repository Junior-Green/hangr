import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hangr/pages/loading_screen.dart';
import 'package:hangr/services/firebase.dart' as fb;
import 'package:hangr/services/theme_handler.dart';
import 'package:hangr/themes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await fb.initializeFireBase();
    await fb.user?.getIdTokenResult(true);
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  runApp(
    ChangeNotifierProvider<ThemeHandler>(
      create: (_) => ThemeHandler(),
      child: Consumer<ThemeHandler>(
        builder: (_, handler, __) => MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: handler.mode,
          initialRoute: '/',
          routes: {
            '/': (_) => const LoadingScreen(),
          },
        ),
      ),
    ),
  );
}
