import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hangr/logic/file_handler.dart';
import 'package:json_annotation/json_annotation.dart';

part '../serializers/outfit.g.dart';

enum OutfitType {
  @JsonValue("casual")
  casual,
  @JsonValue("semi_formal")
  semiFormal,
  @JsonValue("athletic")
  athletic,
  @JsonValue("formal")
  formal
}

@JsonSerializable(explicitToJson: true)
class Outfit {
  final String id;
  final String name;
  final String primaryColor;
  final String secondaryColor;
  final OutfitType type;
  final List<String> wearableIds;
  final String imagePath;
  final DateTime timeMade;
  bool uploaded = false;

  Outfit(
    this.id,
    this.wearableIds,
    this.type,
    this.name,
    this.primaryColor,
    this.secondaryColor,
    this.imagePath,
    this.timeMade,
  );

  set isUploaded(bool uploaded) => this.uploaded = uploaded;
  bool get isUploaded => uploaded;

  factory Outfit.fromJson(Map<String, dynamic> json) => _$OutfitFromJson(json);
  Map<String, dynamic> toJson() => _$OutfitToJson(this);
}

class MyOutfits extends ChangeNotifier {
  final FileHandler _handler;
  final List<Outfit> _outfits;

  MyOutfits(this._outfits, this._handler);

  Future<void> addOutfit(Outfit o) async {
    final index = _outfits.indexWhere((element) => element.id == o.id);
    if (index != -1) {
      await removeOutfit(_outfits[index]);
    }
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
}
