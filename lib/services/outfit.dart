import 'package:json_annotation/json_annotation.dart';

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
  final OutfitType type;
  final List<String> wearableIds;

  const Outfit(this.wearableIds, this.type);

  factory Outfit.fromJson(Map<String, dynamic> json) => _$OutfitFromJson(json);
  Map<String, dynamic> toJson() => _$OutfitToJson(this);
}
