// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../services/calendar_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarMap _$CalendarMapFromJson(Map<String, dynamic> json) => CalendarMap(
      (json['calendarMap'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            DateTime.parse(k), Outfit.fromJson(e as Map<String, dynamic>),),
      ),
    );

Map<String, dynamic> _$CalendarMapToJson(CalendarMap instance) =>
    <String, dynamic>{
      'calendarMap':
          instance.calendarMap.map((k, e) => MapEntry(k.toIso8601String(), e)),
    };
