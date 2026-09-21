// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ward_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WardModel _$WardModelFromJson(Map<String, dynamic> json) => WardModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  constituency: (json['constituency'] as num?)?.toInt(),
);

Map<String, dynamic> _$WardModelToJson(WardModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'constituency': instance.constituency,
};
