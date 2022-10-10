import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hangr/services/file_handler.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

part '../serializers/outfit.g.dart';

enum OutfitType {
  @JsonValue("casual")
  casual,
  @JsonValue("formal")
  formal,
  @JsonValue("athletic")
  athletic,
  @JsonValue("business")
  business
}

@JsonSerializable(explicitToJson: true)
class Outfit {
  final String name;
  final String primaryColor;
  final String secondaryColor;
  final OutfitType type;
  final List<String> wearableIds;
  final String imagePath;
  final DateTime timeMade;

  const Outfit(
    this.wearableIds,
    this.type,
    this.name,
    this.primaryColor,
    this.secondaryColor,
    this.imagePath,
    this.timeMade,
  );

  factory Outfit.fromJson(Map<String, dynamic> json) => _$OutfitFromJson(json);
  Map<String, dynamic> toJson() => _$OutfitToJson(this);
}

class MyOutfits extends ChangeNotifier {
  late final FileHandler _handler;
  final List<Outfit> _outfits;

  MyOutfits(this._outfits) {
    _initHandler();
  }

  Future<void> addOutfit(Outfit o) async {
    _outfits.add(o);
    await _handler.writeOutfits(_outfits);
    notifyListeners();
  }

  Future<void> removeOutfit(Outfit o) async {
    if (await File(o.imagePath).exists()) {
      await File(o.imagePath).delete();
    }
    _outfits.remove(o);
    await _handler.writeOutfits(_outfits);
    notifyListeners();
  }

  Future<void> removeOutfitsWithWearable(String id) async {
    _outfits.removeWhere((element) {
      if (element.wearableIds.contains(id)) {
        if (File(element.imagePath).existsSync()) {
          File(element.imagePath).deleteSync();
        }
        return true;
      }
      return false;
    });

    await _handler.writeOutfits(_outfits);
    notifyListeners();
  }

  Future<void> removeAllOutfits() async {
    for (final outfit in _outfits) {
      if (await File(outfit.imagePath).exists()) {
        await File(outfit.imagePath).delete();
      }
    }
    _outfits.clear();
    await _handler.writeOutfits(_outfits);
    notifyListeners();
  }

  bool containsWearable(String id) =>
      _outfits.indexWhere((element) => element.wearableIds.contains(id)) != -1;

  List<Outfit> get getOutfits => _outfits.toList();

  Future<void> _initHandler() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    _handler = FileHandler(directory.path);
  }
}
