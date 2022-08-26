// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../services/wearable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wearable _$WearableFromJson(Map<String, dynamic> json) => Wearable(
      json['id'] as String,
      $enumDecode(_$WearableTypeEnumMap, json['type']),
      json['brand'] as String,
      json['primaryColor'] as String,
      json['imagePath'] as String,
      json['name'] as String,
      DateTime.parse(json['timeTaken'] as String),
    );

Map<String, dynamic> _$WearableToJson(Wearable instance) => <String, dynamic>{
      'type': _$WearableTypeEnumMap[instance.type],
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'primaryColor': instance.primaryColor,
      'imagePath': instance.imagePath,
      'timeTaken': instance.timeTaken.toIso8601String(),
    };

const _$WearableTypeEnumMap = {
  WearableType.headwear: 'headwear',
  WearableType.top: 'top',
  WearableType.bottom: 'bottom',
  WearableType.footwear: 'footwear',
  WearableType.accessory: 'accessory',
};
