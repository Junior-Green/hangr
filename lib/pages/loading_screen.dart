import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hangr/pages/home.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/file_handler.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitFoldingCube(
          color: Theme.of(context).colorScheme.onPrimary,
          size: 90.0,
        ),
      ),
    );
  }

  Future<void> initData() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final FileHandler handler = FileHandler(directory.path);
      final CalendarMap calendarMap = await handler.readCalendarMap();
      final List<Outfit> outfits = await handler.readOutfits();
      final MyWearables wearables = MyWearables(await handler.readWearables());

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              Provider.value(value: calendarMap),
              ChangeNotifierProvider.value(value: wearables),
              Provider.value(value: outfits),
            ],
            builder: (context, widget) => const Home(),
          ),
        ),
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
