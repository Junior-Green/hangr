import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hangr/pages/home.dart';
import 'package:hangr/services/alert.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/file_handler.dart';
import 'package:hangr/services/notifications.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/page_transition.dart';
import 'package:hangr/services/theme_handler.dart';
import 'package:hangr/services/wearable.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

//TODO: IMPLEMENT FIREBASE CLOUD STORAGE
  Future<void> initApp() async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final FileHandler handler = FileHandler(directory.path);
      final CalendarMap calendarMap =
          CalendarMap(await handler.readCalendarMap(), handler);
      final MyOutfits outfits = MyOutfits(await handler.readOutfits(), handler);
      final MyWearables wearables =
          MyWearables(await handler.readWearables(), handler);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final DateTime date = await _fetchTime();
      final Notifications notifications = Notifications()..initialize();
      final String timezone = await FlutterNativeTimezone.getLocalTimezone();

      await prefs.setString('time_zone', timezone);
      prefs.setBool(
        'is_premium_user',
        prefs.getBool('is_premium_user') ?? false,
      );

      if (!mounted) return;

      context
          .read<ThemeHandler>()
          .setMode(_getThemeMode(prefs.getString('theme') ?? 'system'));

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
        final List<Wearable> wearablesToAdd = _getWearables(
          '${directory.path}/shirt.jpg',
          DateTime(date.year, date.month, date.day),
        );
        for (final w in wearablesToAdd) {
          wearables.addWearable(w);
        }
      }

      if (!mounted) return;

      fadeInPageReplacement(
        context,
        MultiProvider(
          providers: [
            Provider.value(value: notifications),
            Provider.value(value: calendarMap),
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

  List<Wearable> _getWearables(String directory, DateTime date) => [
        Wearable(
          '1',
          WearableType.top,
          'Nike',
          'Black',
          directory,
          'Shirt1',
          DateTime.now(),
          date.subtract(
            const Duration(days: 1),
          ),
          1,
        ),
        Wearable(
          '2',
          WearableType.top,
          'Nike',
          'Black',
          directory,
          'Shirt2',
          DateTime.now(),
          date.subtract(
            const Duration(days: 2),
          ),
          2,
        ),
        Wearable(
          '3',
          WearableType.top,
          'Nike',
          'Black',
          directory,
          'Shirt3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 3),
          ),
          3,
        ),
        Wearable(
          '4',
          WearableType.bottom,
          'Nike',
          'Black',
          directory,
          'Bottom1',
          DateTime.now(),
          date.subtract(
            const Duration(days: 4),
          ),
          4,
        ),
        Wearable(
          '5',
          WearableType.bottom,
          'Nike',
          'Black',
          directory,
          'Bottom2',
          DateTime.now(),
          date.subtract(
            const Duration(days: 5),
          ),
          5,
        ),
        Wearable(
          '6',
          WearableType.bottom,
          'Nike',
          'Black',
          directory,
          'Bottom3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 6),
          ),
          6,
        ),
        Wearable(
          '7',
          WearableType.headwear,
          'Nike',
          'Black',
          directory,
          'Headwear1',
          DateTime.now(),
          date.subtract(
            const Duration(days: 7),
          ),
          7,
        ),
        Wearable(
          '8',
          WearableType.headwear,
          'Nike',
          'Black',
          directory,
          'Headwear2',
          DateTime.now(),
          date.subtract(
            const Duration(days: 8),
          ),
          8,
        ),
        Wearable(
          '9',
          WearableType.headwear,
          'Nike',
          'Black',
          directory,
          'Headwear3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 9),
          ),
          9,
        ),
        Wearable(
          '10',
          WearableType.footwear,
          'Nike',
          'Black',
          directory,
          'Footwear1',
          DateTime.now(),
          date.subtract(
            const Duration(days: 10),
          ),
          10,
        ),
        Wearable(
          '11',
          WearableType.footwear,
          'Nike',
          'Black',
          directory,
          'Footwear2',
          DateTime.now(),
          date.subtract(
            const Duration(days: 11),
          ),
          11,
        ),
        Wearable(
          '12',
          WearableType.footwear,
          'Nike',
          'Black',
          directory,
          'Footwear3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 12),
          ),
          12,
        ),
        Wearable(
          '13',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory1',
          DateTime.now(),
          date.subtract(
            const Duration(days: 3),
          ),
          13,
        ),
        Wearable(
          '14',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory2',
          DateTime.now(),
          date.subtract(
            const Duration(days: 14),
          ),
          14,
        ),
        Wearable(
          '15',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          15,
        ),
        Wearable(
          '16',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          16,
        ),
        Wearable(
          '17',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          17,
        ),
        Wearable(
          '18',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          18,
        ),
        Wearable(
          '19',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          19,
        ),
        Wearable(
          '20',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          20,
        ),
        Wearable(
          '21',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          21,
        ),
        Wearable(
          '22',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          22,
        ),
        Wearable(
          '23',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          23,
        ),
        Wearable(
          '24',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          24,
        ),
        Wearable(
          '25',
          WearableType.accessory,
          'Nike',
          'Black',
          directory,
          'Accessory3',
          DateTime.now(),
          date.subtract(
            const Duration(days: 15),
          ),
          25,
        ),
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
          await showMessageAlert(
            context,
            'Connection Error',
            "An error occured while connecting to the internet. The device's time will be used.",
          );
          return DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
        },
      );
}
