import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hangr/constants.dart';
import 'package:hangr/logic/logger.dart';
import 'package:hangr/model/calendar_map.dart';
import 'package:hangr/model/outfit.dart';
import 'package:hangr/model/wearable.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  late String _directoryPath;
  final Completer<bool> isInitialized = Completer();

  FileHandler() {
    try {
      getTemporaryDirectory().then((dir) {
        _directoryPath = dir.path;
        isInitialized.complete(true);
      });
    } on Exception catch (e, trace) {
      Logger.log(
        'Error finding device temporary directory path in file_handler.dart',
      );
      Logger.reportError(trace, e);
    }
  }

  FileHandler.path(this._directoryPath) {
    isInitialized.complete(true);
  }

  // ignore: avoid_setters_without_getters
  set path(String path) => _directoryPath = path;

  Future<Map<DateTime, List<String>>> readCalendarMap() async {
    if (!isInitialized.isCompleted) {
      throw Exception('FileHandler is not yet initialized.');
    }
    final f = File('$_directoryPath/data/$calendarMapPath');

    try {
      if (await f.exists()) {
        final content = await f.readAsString();
        return (json.decode(content) as Map<String, dynamic>).map(
          (k, e) => MapEntry(
            DateTime.parse(k),
            (e as List<dynamic>).map((e) => e as String).toList(),
          ),
        );
      }
    } on Exception catch (e, trace) {
      Logger.log(
        'Error retrieving calendar map data from device local storage.',
      );
      Logger.reportError(trace, e);
    }
    return <DateTime, List<String>>{};
  }

  Future<List<Outfit>> readOutfits() async {
    if (!isInitialized.isCompleted) {
      throw Exception('FileHandler is not yet initialized.');
    }

    final File f = File('$_directoryPath/data/$outfitsPath');
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
    } on Exception catch (e, trace) {
      Logger.log(
        'Error retrieving outfit data from device local storage.',
      );
      Logger.reportError(trace, e);
    }
    return outfits;
  }

  Future<List<Wearable>> readWearables() async {
    if (!isInitialized.isCompleted) {
      throw Exception('FileHandler is not yet initialized.');
    }

    final File f = File('$_directoryPath/data/$wearablesPath');
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
    } on Exception catch (e, trace) {
      Logger.log(
        'Error retrieving wearable data from device local storage.',
      );
      Logger.reportError(trace, e);
    }
    return wearables;
  }

  Future<bool> writeWearables(List<Wearable> wearables) async {
    if (!isInitialized.isCompleted) {
      throw Exception('FileHandler is not yet initialized.');
    }

    try {
      if (!await File('$_directoryPath/data/$wearablesPath').exists()) {
        await File('$_directoryPath/data/$wearablesPath')
            .create(recursive: true);
      }
      await File('$_directoryPath/data/$wearablesPath')
          .writeAsString(json.encode(wearables));
      return await File('$_directoryPath/data/$wearablesPath').exists();
    } on Exception catch (e, trace) {
      Logger.log(
        'Error writing wearable data to device local storage.',
      );
      Logger.reportError(trace, e);
      return false;
    }
  }

  Future<bool> writeOutfits(List<Outfit> outfits) async {
    if (!isInitialized.isCompleted) {
      throw Exception('FileHandler is not yet initialized.');
    }

    try {
      if (!await File('$_directoryPath/data/$outfitsPath').exists()) {
        await File('$_directoryPath/data/$outfitsPath').create(recursive: true);
      }
      await File('$_directoryPath//data/$outfitsPath')
          .writeAsString(json.encode(outfits));
      return await File('$_directoryPath/data/$outfitsPath').exists();
    } on Exception catch (e, trace) {
      Logger.log(
        'Error writing outfit data to device local storage.',
      );
      Logger.reportError(trace, e);
      return false;
    }
  }

  Future<bool> writeCalendarMap(CalendarMap map) async {
    if (!isInitialized.isCompleted) {
      throw Exception('FileHandler is not yet initialized.');
    }

    try {
      if (!await File('$_directoryPath/data/$calendarMapPath').exists()) {
        await File('$_directoryPath/data/$calendarMapPath')
            .create(recursive: true);
      }
      final data = map.getMap().map((k, e) => MapEntry(k.toIso8601String(), e));
      await File('$_directoryPath/data/$calendarMapPath')
          .writeAsString(json.encode(data));
      return File('$_directoryPath/data/$calendarMapPath').exists();
    } on Exception catch (e, trace) {
      Logger.log(
        'Error writing calendar map data to device local storage.',
      );
      Logger.reportError(trace, e);
      return false;
    }
  }

  Future<void> deleteAllFiles() async {
    if (!isInitialized.isCompleted) {
      throw Exception('FileHandler is not yet initialized.');
    }

    final File wearables = File('$_directoryPath/data/$wearablesPath');
    final File outfits = File('$_directoryPath/data/$outfitsPath');
    final File map = File('$_directoryPath/data/$calendarMapPath');

    if (await wearables.exists()) {
      wearables.delete();
    }
    if (await outfits.exists()) {
      outfits.delete();
    }
    if (await map.exists()) {
      map.delete();
    }
  }
}
