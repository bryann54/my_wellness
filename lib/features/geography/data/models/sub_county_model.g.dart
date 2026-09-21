// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_county_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubCountyModel _$SubCountyModelFromJson(Map<String, dynamic> json) =>
    SubCountyModel(
      id: (json['id'] as num?)?.toInt(),
      code: (json['code'] as num?)?.toInt(),
      name: json['name'] as String?,
      county: (json['county'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubCountyModelToJson(SubCountyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'county': instance.county,
    };
