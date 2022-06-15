import 'package:hangr/helpers/outfit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calendar_map.g.dart';

@JsonSerializable()
class CalendarMap {
  final Map<DateTime, Outfit> _calendarMap;

  CalendarMap(this._calendarMap);

  Outfit? getFromDate(DateTime time) => _calendarMap[time];
  Outfit addOutfit(DateTime time, Outfit outfit) =>
      _calendarMap.putIfAbsent(time, () => outfit);

  factory CalendarMap.fromJson(Map<String, dynamic> json) =>
      _$CalendarMapFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarMapToJson(this);
}
