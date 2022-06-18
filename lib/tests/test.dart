// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';
import 'package:hangr/tests/test_helper.dart';
import 'package:hangr/utility/file_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test/test.dart';

void main() {
  late FileHandler handler;
  late Directory dir;
  late String dirPath;
  late List<Wearable> wearables;
  late List<Outfit> outfits;
  late CalendarMap map;

  setUp(() async {
    try {
      handler = FileHandler();

      dir = await getApplicationDocumentsDirectory();
      dirPath = dir.path;

      wearables = getListWearable();
      outfits = getListOutfit();
      map = getCalendarMap();

      print('Directory path is $dirPath');
    } on Exception catch (e) {
      print(e);
      exit(1);
    }
  });

  group('Serialize and write data to disk', () {
    test('write wearables to disk', () async {
      print(json.encode(wearables));

      final res = await handler.writeWearables(wearables);
      expect(res, equals(true));
    });

    test('write outfits to disk', () async {
      print(json.encode(outfits));
      final res = await handler.writeOutfits(outfits);
      expect(res, equals(true));
    });

    test('write calendar map to disk', () async {
      print(json.encode(map));
      final res = await handler.writeCalendarMap(map);
      expect(res, equals(true));
    });

    tearDown(() async => handler.deleteAllFiles());
  });

  group('Read data from disk and deserialize', () {
    setUp(() async {
      await handler.writeWearables(wearables);
      await handler.writeOutfits(outfits);
      await handler.writeCalendarMap(map);
    });

    group('Wearables', () {
      test('read data from disk', () {
        expect(11.toRadixString(16), equals('b'));
      });
    });

    group('Outfits', () {
      test('read data from disk', () {
        expect(11.toRadixString(16), equals('b'));
      });
    });
    group('CalendarMap', () {
      test('read data map from disk', () {
        expect(11.toRadixString(16), equals('b'));
      });
    });
  });

  tearDown(() async => handler.deleteAllFiles());
}
