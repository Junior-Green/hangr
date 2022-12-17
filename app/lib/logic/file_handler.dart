import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hangr/constants.dart';
import 'package:hangr/model/calendar_map.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/wearable.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  late final String _directoryPath;

  FileHandler(){
    getTemporaryDirectory().then((dir) => _directoryPath = dir.path);
  }

  Future<Map<DateTime, List<String>>> readCalendarMap() async {
    final f = File('$_directoryPath/$calendarMapPath');

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
    final File f = File('$_directoryPath/$outfitsPath');
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
    final File f = File('$_directoryPath/$wearablesPath');
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
      await File('$_directoryPath/$wearablesPath')
          .writeAsString(json.encode(wearables));
      return await File('$_directoryPath/$wearablesPath').exists();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<bool> writeOutfits(List<Outfit> outfits) async {
    try {
      await File('$_directoryPath/$outfitsPath')
          .writeAsString(json.encode(outfits));
      return await File('$_directoryPath/$outfitsPath').exists();
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
      await File('$_directoryPath/$calendarMapPath')
          .writeAsString(json.encode(data));
      return File('$_directoryPath/$calendarMapPath').exists();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<bool> deleteAllFiles() async {
    try {
      final File wearables = File('$_directoryPath/$wearablesPath');
      final File outfits = File('$_directoryPath/$outfitsPath');
      final File map = File('$_directoryPath/$calendarMapPath');

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
}
