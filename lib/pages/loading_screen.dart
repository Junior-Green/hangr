import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hangr/pages/home.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/file_handler.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/page_transition.dart';
import 'package:hangr/services/theme_handler.dart';
import 'package:hangr/services/wearable.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    initApp();
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

  Future<void> initApp() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final FileHandler handler = FileHandler(directory.path);
      final CalendarMap calendarMap =
          CalendarMap(await handler.readCalendarMap(), handler);
      final MyOutfits outfits = MyOutfits(await handler.readOutfits(), handler);
      final MyWearables wearables =
          MyWearables(await handler.readWearables(), handler);
      final configurations = await handler.readConfigMap();
      final date = await _fetchTime();

      if (!mounted) return;

      context
          .read<ThemeHandler>()
          .setMode(_getThemeMode(configurations['theme'] as String));

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

      fadeInPageReplacement(
        context,
        MultiProvider(
          providers: [
            Provider.value(value: calendarMap),
            Provider.value(value: configurations),
            Provider(create: (_) => DateTime(date.year, date.month, date.day)),
            ChangeNotifierProvider.value(value: wearables),
            ChangeNotifierProvider.value(value: outfits),
            ChangeNotifierProvider.value(value: context.read<ThemeHandler>()),
          ],
          builder: (context, widget) => const Home(),
        ),
        const Duration(milliseconds: 500),
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

  ThemeMode _getThemeMode(String val) {
    switch (val) {
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<DateTime> _fetchTime() async =>
      NTP.now(timeout: const Duration(milliseconds: 3000)).onError(
        (error, stackTrace) async {
          await _showErrorMessage(context);
          return DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
        },
      );

  Future<bool?> _showErrorMessage(BuildContext context) => Alert(
        context: context,
        type: AlertType.none,
        title: 'Connection Error',
        desc:
            "An error occured connecting to the internet. The device's time will be used.",
        style: AlertStyle(
          animationType: AnimationType.grow,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          alertBorder: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          isCloseButton: false,
          titleStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          descStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 15,
          ),
        ),
        buttons: [
          DialogButton(
            height: 35,
            margin: const EdgeInsets.symmetric(horizontal: 50),
            radius: const BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).colorScheme.tertiary,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Okay'),
          )
        ],
      ).show();
}
