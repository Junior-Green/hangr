// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../services/wearable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wearable _$WearableFromJson(Map<String, dynamic> json) => Wearable(
      $enumDecode(_$WearableTypeEnumMap, json['type']),
      json['brand'] as String,
      json['primaryColor'] as String,
      json['imagePath'] as String,
      json['name'] as String,
    );

Map<String, dynamic> _$WearableToJson(Wearable instance) => <String, dynamic>{
      'type': _$WearableTypeEnumMap[instance.type],
      'name': instance.name,
      'brand': instance.brand,
      'primaryColor': instance.primaryColor,
      'imagePath': instance.imagePath,
    };

const _$WearableTypeEnumMap = {
  WearableType.headwear: 'headwear',
  WearableType.top: 'top',
  WearableType.bottom: 'bottom',
  WearableType.footwear: 'footwear',
  WearableType.accessory: 'accessory',
};
