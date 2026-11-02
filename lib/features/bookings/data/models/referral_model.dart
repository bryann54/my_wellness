import 'package:json_annotation/json_annotation.dart';
import 'facility_model.dart';
import 'service_booking_model.dart';

part 'referral_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ReferralServiceModel {
  final String code;
  final String name;

  const ReferralServiceModel({required this.code, required this.name});

  factory ReferralServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralServiceModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ReferralModel {
  final String id;
  final String sourceType;
  final String? session;
  final String escalationCategory;
  @JsonKey(defaultValue: '')
  final String escalationCategoryDisplay;
  @JsonKey(name: 'required_services', defaultValue: <ReferralServiceModel>[])
  final List<ReferralServiceModel> requiredServices;
  @JsonKey(defaultValue: '')
  final String reason;
  final FacilityModel? recommendedFacility;
  @JsonKey(fromJson: _toStrOrNull)
  final String? distanceKm;
  @JsonKey(fromJson: _toIntOrNull)
  final int? travelTimeMinutes;
  @JsonKey(defaultValue: 'unavailable')
  final String shaAccreditationStatus;
  final BookingSummaryModel? booking;
  final String status;
  @JsonKey(fromJson: _dateOrNull)
  final DateTime? createdAt;

  const ReferralModel({
    required this.id,
    required this.sourceType,
    this.session,
    required this.escalationCategory,
    this.escalationCategoryDisplay = '',
    this.requiredServices = const [],
    this.reason = '',
    this.recommendedFacility,
    this.distanceKm,
    this.travelTimeMinutes,
    this.shaAccreditationStatus = 'unavailable',
    this.booking,
    required this.status,
    this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralModelToJson(this);
}

DateTime? _dateOrNull(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String? _toStrOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}
