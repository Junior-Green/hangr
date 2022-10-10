// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../services/outfit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Outfit _$OutfitFromJson(Map<String, dynamic> json) => Outfit(
      (json['wearables'] as List<dynamic>).map((e) => e as String).toList(),
      $enumDecode(_$OutfitTypeEnumMap, json['type']),
      json['name'] as String,
      json['primaryColor'] as String,
      json['secondaryColor'] as String,
      json['imagePath'] as String,
      DateTime.parse(json['timeMade'] as String),
    );

Map<String, dynamic> _$OutfitToJson(Outfit instance) => <String, dynamic>{
      'type': _$OutfitTypeEnumMap[instance.type],
      'name': instance.name,
      'wearables': instance.wearableIds,
      'primaryColor': instance.primaryColor,
      'secondaryColor': instance.secondaryColor,
      'imagePath': instance.imagePath,
      'timeMade': instance.timeMade.toIso8601String(),
    };

const _$OutfitTypeEnumMap = {
  OutfitType.casual: 'casual',
  OutfitType.formal: 'formal',
  OutfitType.athletic: 'athletic',
  OutfitType.business: 'business',
};
