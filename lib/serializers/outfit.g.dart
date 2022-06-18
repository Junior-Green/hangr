// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../services/outfit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Outfit _$OutfitFromJson(Map<String, dynamic> json) => Outfit(
      (json['wearables'] as List<dynamic>).map((e) => e as String).toList(),
      $enumDecode(_$OutfitTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$OutfitToJson(Outfit instance) => <String, dynamic>{
      'type': _$OutfitTypeEnumMap[instance.type],
      'wearables': instance.wearableIds,
    };

const _$OutfitTypeEnumMap = {
  OutfitType.casual: 'casual',
  OutfitType.formal: 'formal',
  OutfitType.sports: 'sports',
  OutfitType.business: 'business',
};
