import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      final MyOutfits outfits = MyOutfits(await handler.readOutfits());
      final MyWearables wearables =
          MyWearables(await handler.readWearables(), handler);

      if (kDebugMode) {
        await wearables.removeAllWearables();
        await outfits.removeAllOutfits();
        final ByteData byteData =
            await rootBundle.load('assets/images/shirt.jpg');

        final File file = await File('${directory.path}/shirt.jpg').create();
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
        final List<Wearable> wearablesToAdd =
            _getWearables('${directory.path}/shirt.jpg');
        for (final w in wearablesToAdd) {
          wearables.addWearable(w);
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              Provider.value(value: calendarMap),
              ChangeNotifierProvider.value(value: wearables),
              ChangeNotifierProvider.value(value: outfits),
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

  List<Wearable> _getWearables(String directory) => [
        Wearable(
          '1',
          WearableType.top,
          'Nike',
          'Black',
          directory,
          'Shirt1',
          DateTime.now(),
        ),
        Wearable(
          '2',
          WearableType.top,
          'Nike',
          'Black',
          directory,
          'Shirt2',
          DateTime.now(),
        ),
        Wearable(
          '3',
          WearableType.top,
          'Nike',
          'Black',
          directory,
          'Shirt3',
          DateTime.now(),
        ),
        Wearable(
          '4',
          WearableType.bottom,
          'Nike',
          'Black',
          directory,
          'Bottom1',
          DateTime.now(),
        ),
        Wearable(
          '5',
          WearableType.bottom,
          'Nike',
          'Black',
          directory,
          'Bottom2',
          DateTime.now(),
        ),
        Wearable(
          '6',
          WearableType.bottom,
          'Nike',
          'Black',
          directory,
          'Bottom3',
          DateTime.now(),
        ),
        Wearable(
          '7',
          WearableType.headwear,
          'Nike',
          'Black',
          directory,
          'Headwear1',
          DateTime.now(),
        ),
        Wearable(
          '8',
          WearableType.headwear,
          'Nike',
          'Black',
          directory,
          'Headwear2',
          DateTime.now(),
        ),
        Wearable(
          '9',
          WearableType.headwear,
          'Nike',
          'Black',
          directory,
          'Headwear3',
          DateTime.now(),
        ),
        Wearable(
          '10',
          WearableType.footwear,
          'Nike',
          'Black',
          directory,
          'Footwear1',
          DateTime.now(),
        ),
        Wearable(
          '11',
          WearableType.footwear,
          'Nike',
          'Black',
          directory,
          'Footwear2',
          DateTime.now(),
        ),
        Wearable(
          '12',
          WearableType.footwear,
          'Nike',
          'Black',
          directory,
          'Footwear3',
          DateTime.now(),
        ),
        Wearable(
          '13',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory1',
          DateTime.now(),
        ),
        Wearable(
          '14',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory2',
          DateTime.now(),
        ),
        Wearable(
          '15',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
        )
      ];
}
