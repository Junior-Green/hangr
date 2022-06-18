import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  static const _outfitsPath = 'outfits.json';
  static const _wearablesPath = 'wearables.json';
  static const _calendarMapPath = 'calendar_map.json';
  static late final String _dirPath;

  FileHandler() {
    _getDirPath().then((path) => _dirPath = path).onError((error, stackTrace) {
      return _dirPath = "";
    });
  }

  Future<String> _getDirPath() async {
    String path = "";
    try {
      final localDir = await getApplicationDocumentsDirectory();
      path = localDir.path;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return path;
  }

  Future<CalendarMap?> readCalendarMap() async {
    final f = File('$_dirPath/$_calendarMapPath');
    CalendarMap? map;

    if (await f.exists()) {
      final content = await f.readAsString();
      map = CalendarMap.fromJson(jsonDecode(content) as Map<String, dynamic>);
    }
    return map;
  }

  Future<List<Outfit>?> readOutfits() async {
    final File f = File('$_dirPath/$_outfitsPath');
    List<Outfit>? outfits;

    try {
      if (await f.exists()) {
        await f.readAsString().then((contents) {
          final Iterable l = jsonDecode(contents) as Iterable<dynamic>;
          outfits = List<Outfit>.from(
              l.map((model) => Outfit.fromJson(model as Map<String, dynamic>)),);
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return outfits;
  }

  Future<List<Wearable>?> readWearables() async {
    final File f = File('$_dirPath/$_wearablesPath');
    List<Wearable>? wearables;

    try {
      if (await f.exists()) {
        await f.readAsString().then((contents) {
          final Iterable l = jsonDecode(contents) as Iterable<dynamic>;
          wearables = List<Wearable>.from(l.map(
              (model) => Wearable.fromJson(model as Map<String, dynamic>),),);
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
      File f = File('$_dirPath/$_wearablesPath');
      f = await f.writeAsString(json.encode(wearables));
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
    return true;
  }

  Future<bool> writeOutfits(List<Outfit> outfits) async {
    try {
      File f = File('$_dirPath/$_outfitsPath');
      f = await f.writeAsString(json.encode(outfits));
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
    return true;
  }

  Future<bool> writeCalendarMap(CalendarMap map) async {
    try {
      File f = File('$_dirPath/$_calendarMapPath');
      f = await f.writeAsString(json.encode(map));
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
    return true;
  }

  Future<bool> deleteAllFiles() async {
    try {
      final File wearables = File('$_dirPath/$_wearablesPath');
      final File outfits = File('$_dirPath/$_outfitsPath');
      final File map = File('$_dirPath/$_calendarMapPath');

      wearables.delete();
      outfits.delete();
      map.delete();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
    return true;
  }
}
