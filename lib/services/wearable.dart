import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hangr/services/file_handler.dart';
import 'package:json_annotation/json_annotation.dart';

part '../serializers/wearable.g.dart';

enum WearableType {
  @JsonValue("headwear")
  headwear,
  @JsonValue("top")
  top,
  @JsonValue("bottom")
  bottom,
  @JsonValue("footwear")
  footwear,
  @JsonValue("accessory")
  accessory,
}

@JsonSerializable(explicitToJson: true)
class Wearable {
  final WearableType type;
  final String id;
  final String name;
  final String brand;
  final String primaryColor;
  final String imagePath;
  final DateTime timeTaken;
  DateTime? last;
  int times = 0;

  Wearable(
    this.id,
    this.type,
    this.brand,
    this.primaryColor,
    this.imagePath,
    this.name,
    this.timeTaken, [
    this.last,
    this.times = 0,
  ]);

  void incrementTimeWorn() => times++;
  void decrementTimeWorn() => times--;

  set lastWorn(DateTime? time) => last;

  DateTime? get lastWorn => last;
  int get timesWorn => times;

  factory Wearable.fromJson(Map<String, dynamic> json) =>
      _$WearableFromJson(json);

  Map<String, dynamic> toJson() => _$WearableToJson(this);
}

class MyWearables extends ChangeNotifier {
  final FileHandler _handler;
  final List<Wearable> _wearables;

  MyWearables(this._wearables, this._handler);

  Future<void> addWearable(Wearable w) async {
    _wearables.add(w);
    await _handler.writeWearables(_wearables);
    notifyListeners();
  }

  Future<void> removeWearable(Wearable w) async {
    if (await File(w.imagePath).exists()) {
      await File(w.imagePath).delete();
    }
    _wearables.remove(w);
    await _handler.writeWearables(_wearables);
    notifyListeners();
  }

  Future<void> removeAllWearables() async {
    for (final w in _wearables) {
      if (await File(w.imagePath).exists()) {
        await File(w.imagePath).delete();
      }
    }
    _wearables.clear();
    await _handler.writeWearables(_wearables);
    notifyListeners();
  }

  List<Wearable> get getWearables => _wearables.toList();
}
