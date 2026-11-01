// lib/features/bookings/data/models/facility_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'facility_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class FacilityModel {
  final String id;
  final String name;
  final String town;
  final String county;
  final String address;
  final String phone;
  @JsonKey(defaultValue: <String>[])
  final List<String> services;
  @JsonKey(fromJson: _toDoubleOrNull)
  final double? latitude;
  @JsonKey(fromJson: _toDoubleOrNull)
  final double? longitude;
  @JsonKey(name: 'covers_sha', defaultValue: false)
  final bool coversSha;
  @JsonKey(name: 'keph_level', fromJson: _toIntOrNull)
  final int? kephLevel;
  @JsonKey(name: 'sha_funds', defaultValue: <String>[])
  final List<String> shaFunds;
  @JsonKey(name: 'distance_km', fromJson: _toDoubleOrNull)
  final double? distanceKm;

  const FacilityModel({
    required this.id,
    required this.name,
    this.town = '',
    this.county = '',
    this.address = '',
    this.phone = '',
    this.services = const [],
    this.latitude,
    this.longitude,
    this.coversSha = false,
    this.kephLevel,
    this.shaFunds = const [],
    this.distanceKm,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) =>
      _$FacilityModelFromJson(json);

  Map<String, dynamic> toJson() => _$FacilityModelToJson(this);
}

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
