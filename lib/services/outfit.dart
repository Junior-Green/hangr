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
  @JsonValue("sports")
  sports,
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

  void addOutfit(Outfit o) {
    _outfits.add(o);
    notifyListeners();
    _handler.writeOutfits(_outfits);
  }

  void removeOutfit(Outfit o) {
    _outfits.remove(o);
    notifyListeners();
    _handler.writeOutfits(_outfits);
  }

  void removeOutfitsWithWearable(String id) {
    _outfits.removeWhere((element) {
      if (element.wearableIds.contains(id)) {
        File(element.imagePath).delete();
        return true;
      }
      return false;
    });

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
