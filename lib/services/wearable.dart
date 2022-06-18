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
  final String name;
  final String brand;
  final String primaryColor;
  final String imagePath;

  const Wearable(this.type, this.brand, this.primaryColor, this.imagePath, this.name);

  factory Wearable.fromJson(Map<String, dynamic> json) =>
      _$WearableFromJson(json);

  Map<String, dynamic> toJson() => _$WearableToJson(this);
}
