// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constituency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConstituencyModel _$ConstituencyModelFromJson(Map<String, dynamic> json) =>
    ConstituencyModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      county: (json['county'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConstituencyModelToJson(ConstituencyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'county': instance.county,
    };
