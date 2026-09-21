// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'county_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountyModel _$CountyModelFromJson(Map<String, dynamic> json) => CountyModel(
  id: (json['id'] as num?)?.toInt(),
  code: (json['code'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$CountyModelToJson(CountyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };
