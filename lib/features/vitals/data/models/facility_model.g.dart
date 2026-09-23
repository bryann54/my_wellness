// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityModel _$FacilityModelFromJson(Map<String, dynamic> json) =>
    FacilityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      town: json['town'] as String?,
      county: json['county'] as String?,
    );

Map<String, dynamic> _$FacilityModelToJson(FacilityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'town': instance.town,
      'county': instance.county,
    };
