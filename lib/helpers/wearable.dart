import 'package:json_annotation/json_annotation.dart';

part 'wearable.g.dart';

enum WearableType {
  @JsonValue("headwear")
  HEADWEAR,
  @JsonValue("top")
  TOP,
  @JsonValue("bottom")
  BOTTOM,
  @JsonValue("footwear")
  FOOTWEAR,
  @JsonValue("accessory")
  ACCESSORY
}

@JsonSerializable()
class Wearable {
  final WearableType type;
  final String name;
  final String brand;
  final String primaryColor;
  final String imagePath;

  Wearable(this.type, this.brand, this.primaryColor, this.imagePath, this.name);

  factory Wearable.fromJson(Map<String, dynamic> json) =>
      _$WearableFromJson(json);

  Map<String, dynamic> toJson() => _$WearableToJson(this);
}
