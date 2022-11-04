import 'package:hangr/services/file_handler.dart';

class CalendarMap {
  final Map<DateTime, List<String>> _calendarMap;
  final FileHandler _handler;

  CalendarMap(this._calendarMap, this._handler);
  CalendarMap.empty(this._handler) : _calendarMap = <DateTime, List<String>>{};

  List<String> getOutfitFromDate(DateTime time) => _calendarMap[time] ?? [];
  Future<void> updateOutfit(DateTime time, List<String> wearableIds) async {
    _calendarMap[time] = wearableIds;
    _handler.writeCalendarMap(this);
  }

  Map<DateTime, List<String>> getMap() => _calendarMap;
}
