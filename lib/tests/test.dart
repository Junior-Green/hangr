// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:hangr/services/calendar_map.dart';
import 'package:hangr/services/outfit.dart';
import 'package:hangr/services/wearable.dart';
import 'package:hangr/tests/test_helper.dart';
import 'package:hangr/services/file_handler.dart';
import 'package:test/test.dart';

void main() {
  const savePath = '/Users/juniorgreen/Documents';
  late FileHandler handler;
  late List<Wearable> wearables;
  late List<Outfit> outfits;
  late CalendarMap map;

  group('Serialize and write data to disk', () {
    setUp(() {
      handler = FileHandler(savePath);
      wearables = getListWearable();
      outfits = getListOutfit();
      map = getCalendarMap();
    });

    test('write wearables to disk', () async {
      final res = await handler.writeWearables(wearables);
      expect(res, equals(true));
    });

    test('write outfits to disk', () async {
      final res = await handler.writeOutfits(outfits);
      expect(res, equals(true));
    });

    test('write calendar map to disk', () async {
      final res = await handler.writeCalendarMap(map);
      expect(res, equals(true));
    });
  });

  group('Read data from disk and deserialize', () {
    setUp(() async {
      try {
        handler = FileHandler(savePath);
        wearables = getListWearable();
        outfits = getListOutfit();
        map = getCalendarMap();

        await handler.writeWearables(wearables);
        await handler.writeOutfits(outfits);
        await handler.writeCalendarMap(map);
      } on Exception catch (e) {
        print(e);
        exit(1);
      }
    });

    test('read wearables data from disk', () async {
      final List<Wearable> test = await handler.readWearables();
      print(json.encode(test));
      expect(test.length, equals(wearables.length));
      expect(json.encode(test), equals(json.encode(wearables)));
    });

    test('read outfits data from disk', () async {
      final List<Outfit> test = await handler.readOutfits();
      expect(test.length, equals(outfits.length));
      expect(json.encode(test), equals(json.encode(outfits)));
    });

    test('read calendar map data from disk', () async {
      final CalendarMap test = await handler.readCalendarMap();
      expect(json.encode(test), equals(json.encode(map)));
    });
  });

  tearDown(() => handler.deleteAllFiles());
}
