import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hangr/services/file_handler.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

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

  const Wearable(
    this.id,
    this.type,
    this.brand,
    this.primaryColor,
    this.imagePath,
    this.name,
    this.timeTaken,
  );

  factory Wearable.fromJson(Map<String, dynamic> json) =>
      _$WearableFromJson(json);

  Map<String, dynamic> toJson() => _$WearableToJson(this);
}

class MyWearables extends ChangeNotifier {
  late final FileHandler _handler;
  final List<Wearable> _wearables;

  MyWearables(this._wearables) {
    _initHandler();
  }

  void addWearable(Wearable w) {
    _wearables.add(w);
    _handler.writeWearables(_wearables);
    notifyListeners();
  }

  void removeWearable(Wearable w) {
    File(w.imagePath).delete();
    _wearables.remove(w);
    _handler.writeWearables(_wearables);
    notifyListeners();
  }

  List<Wearable> get getWearables => _wearables.toList();

  Future<void> _initHandler() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    _handler = FileHandler(directory.path);
  }
}
