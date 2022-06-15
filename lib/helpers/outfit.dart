import 'package:json_annotation/json_annotation.dart';

part 'outfit.g.dart';

enum OutfitType {
  @JsonValue("casual")
  CASUAL,
  @JsonValue("formal")
  FORMAL,
  @JsonValue("sports")
  SPORTS,
  @JsonValue("business")
  BUSINESS
}

@JsonSerializable(explicitToJson: true)
class Outfit {
  final OutfitType type;
  final List<String> wearables;

  Outfit(this.wearables, this.type);

  factory Outfit.fromJson(Map<String, dynamic> json) => _$OutfitFromJson(json);
  Map<String, dynamic> toJson() => _$OutfitToJson(this);
}
