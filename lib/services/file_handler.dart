import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';

class FileHandler {
  static const _outfitsPath = 'outfits.json';
  static const _wearablesPath = 'wearables.json';
  static const _calendarMapPath = 'calendar_map.json';
  static const _configurationsPath = 'configurations.json';
  final String _directoryPath;

  FileHandler(this._directoryPath);

  Future<Map<DateTime, List<String>>> readCalendarMap() async {
    final f = File('$_directoryPath/$_calendarMapPath');

    if (await f.exists()) {
      final content = await f.readAsString();
      return (json.decode(content) as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          DateTime.parse(k),
          (e as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
    }
    return <DateTime, List<String>>{};
  }

  Future<List<Outfit>> readOutfits() async {
    final File f = File('$_directoryPath/$_outfitsPath');
    List<Outfit> outfits = [];

    try {
      if (await f.exists()) {
        await f.readAsString().then((contents) {
          final Iterable l = jsonDecode(contents) as Iterable<dynamic>;
          outfits = List<Outfit>.from(
            l.map((model) => Outfit.fromJson(model as Map<String, dynamic>)),
          );
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return outfits;
  }

  Future<List<Wearable>> readWearables() async {
    final File f = File('$_directoryPath/$_wearablesPath');
    List<Wearable> wearables = [];

    try {
      if (await f.exists()) {
        await f.readAsString().then((contents) {
          final Iterable l = jsonDecode(contents) as Iterable<dynamic>;
          wearables = List<Wearable>.from(
            l.map(
              (model) => Wearable.fromJson(model as Map<String, dynamic>),
            ),
          );
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return wearables;
  }

  Future<bool> writeWearables(List<Wearable> wearables) async {
    try {
      await File('$_directoryPath/$_wearablesPath')
          .writeAsString(json.encode(wearables));
      return await File('$_directoryPath/$_wearablesPath').exists();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<bool> writeOutfits(List<Outfit> outfits) async {
    try {
      await File('$_directoryPath/$_outfitsPath')
          .writeAsString(json.encode(outfits));
      return await File('$_directoryPath/$_outfitsPath').exists();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<bool> writeCalendarMap(CalendarMap map) async {
    try {
      final data = map.getMap().map((k, e) => MapEntry(k.toIso8601String(), e));
      await File('$_directoryPath/$_calendarMapPath')
          .writeAsString(json.encode(data));
      return File('$_directoryPath/$_calendarMapPath').exists();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<bool> deleteAllFiles() async {
    try {
      final File wearables = File('$_directoryPath/$_wearablesPath');
      final File outfits = File('$_directoryPath/$_outfitsPath');
      final File map = File('$_directoryPath/$_calendarMapPath');

      if (await wearables.exists()) {
        wearables.delete();
      }
      if (await outfits.exists()) {
        outfits.delete();
      }
      if (await map.exists()) {
        map.delete();
      }
    } on Exception {
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> readConfigMap() async {
    final f = File('$_directoryPath/$_configurationsPath');

    if (await f.exists()) {
      final content = await f.readAsString();
      final map = json.decode(content) as Map<String, dynamic>;
      return {
        'camera_quality': map['camera_quality'] as int,
        'theme': map['theme'] as String,
        'notifications': map['notifications'] as bool,
        'notification_time': map['notification_time'] as String,
        'isPremiumUser': map['isPremiumUser'] as bool
      };
    }
    return _defaultConfigMap();
  }

  Future<bool> writeConfigMap(Map<String, dynamic> config) async {
    try {
      await File('$_directoryPath/$_configurationsPath')
          .writeAsString(json.encode(config));
      return File('$_directoryPath/$_configurationsPath').exists();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Map<String, dynamic> _defaultConfigMap() => {
        'camera_quality': 50,
        'theme': 'system',
        'notifications': false,
        'notification_time': '0:00',
        'isPremiumUser': false
      };
}
