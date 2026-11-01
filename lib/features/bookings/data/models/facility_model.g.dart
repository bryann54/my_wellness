// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilityModel _$FacilityModelFromJson(
  Map<String, dynamic> json,
) => FacilityModel(
  id: json['id'] as String,
  name: json['name'] as String,
  town: json['town'] as String? ?? '',
  county: json['county'] as String? ?? '',
  address: json['address'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  services:
      (json['services'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  latitude: _toDoubleOrNull(json['latitude']),
  longitude: _toDoubleOrNull(json['longitude']),
  coversSha: json['covers_sha'] as bool? ?? false,
  kephLevel: _toIntOrNull(json['keph_level']),
  shaFunds:
      (json['sha_funds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  distanceKm: _toDoubleOrNull(json['distance_km']),
);

Map<String, dynamic> _$FacilityModelToJson(FacilityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'town': instance.town,
      'county': instance.county,
      'address': instance.address,
      'phone': instance.phone,
      'services': instance.services,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'covers_sha': instance.coversSha,
      'keph_level': instance.kephLevel,
      'sha_funds': instance.shaFunds,
      'distance_km': instance.distanceKm,
    };
