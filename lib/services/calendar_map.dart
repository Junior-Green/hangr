import 'package:hangr/services/outfit.dart';
import 'package:json_annotation/json_annotation.dart';
part '../serializers/calendar_map.g.dart';

@JsonSerializable(explicitToJson: true)
class CalendarMap {
  late final Map<DateTime, Outfit> calendarMap;

  CalendarMap(this.calendarMap);
  CalendarMap.empty() : this(<DateTime, Outfit>{});

  Outfit? getFromDate(DateTime time) => calendarMap[time];
  Outfit addOutfit(DateTime time, Outfit outfit) =>
      calendarMap.putIfAbsent(time, () => outfit);

  factory CalendarMap.fromJson(Map<String, dynamic> json) =>
      _$CalendarMapFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarMapToJson(this);
}
