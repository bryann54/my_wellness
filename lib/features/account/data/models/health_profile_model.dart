

import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';

part 'health_profile_model.g.dart';
int? _intFromJson(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double? _doubleFromJson(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

bool _boolFromJson(Object? value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final s = value.trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
  }
  return fallback;
}

bool? _boolOrNullFromJson(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final s = value.trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
  }
  return null;
}

String _stringFromJson(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _stringOrNullFromJson(Object? value) {
  if (value == null) return null;
  final s = value.toString();
  return s.isEmpty ? null : s;
}

@JsonSerializable()
class HealthProfileModel {
  final String email;

  @JsonKey(name: 'full_name')
  final String fullName;

  final String phone;

  @JsonKey(fromJson: _intFromJson)
  final int? age;

  @JsonKey(name: 'age_stale', fromJson: _boolFromJson)
  final bool ageStale;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  @JsonKey(name: 'weight_kg', fromJson: _doubleFromJson)
  final double? weightKg;

  @JsonKey(name: 'height_cm', fromJson: _doubleFromJson)
  final double? heightCm;

  @JsonKey(name: 'bmi_stale', fromJson: _boolFromJson)
  final bool bmiStale;

  final String gender;

  final String? county;

  @JsonKey(name: 'sub_county', fromJson: _intFromJson)
  final int? subCounty;

  @JsonKey(fromJson: _intFromJson)
  final int? constituency;

  @JsonKey(fromJson: _intFromJson)
  final int? ward;

  @JsonKey(fromJson: _stringFromJson)
  final String occupation;

  @JsonKey(name: 'member_code')
  final String memberCode;

  @JsonKey(name: 'health_profile_completed', fromJson: _boolFromJson)
  final bool healthProfileCompleted;

  @JsonKey(name: 'has_hypertension', fromJson: _boolOrNullFromJson)
  final bool? hasHypertension;

  @JsonKey(name: 'on_htn_medication', fromJson: _boolOrNullFromJson)
  final bool? onHtnMedication;

  @JsonKey(name: 'htn_medications', fromJson: _stringFromJson)
  final String htnMedications;

  @JsonKey(name: 'has_diabetes', fromJson: _boolOrNullFromJson)
  final bool? hasDiabetes;

  @JsonKey(name: 'on_dm_medication', fromJson: _boolOrNullFromJson)
  final bool? onDmMedication;

  @JsonKey(name: 'dm_medications', fromJson: _stringFromJson)
  final String dmMedications;

  @JsonKey(name: 'htn_onboarding_seen', fromJson: _boolFromJson)
  final bool htnOnboardingSeen;

  @JsonKey(name: 'dm_onboarding_seen', fromJson: _boolFromJson)
  final bool dmOnboardingSeen;

  @JsonKey(name: 'sha_beneficiary_id', fromJson: _stringFromJson)
  final String shaBeneficiaryId;

  @JsonKey(name: 'sha_beneficiary_id_type', fromJson: _stringFromJson)
  final String shaBeneficiaryIdType;

  @JsonKey(name: 'national_id_number', fromJson: _stringOrNullFromJson)
  final String? nationalIdNumber;

  @JsonKey(name: 'analytics_opt_out', fromJson: _boolFromJson)
  final bool analyticsOptOut;

  @JsonKey(name: 'sha_data_sharing_consent', fromJson: _boolFromJson)
  final bool shaDataSharingConsent;

  const HealthProfileModel({
    required this.email,
    required this.fullName,
    required this.phone,
    this.age,
    this.ageStale = false,
    this.dateOfBirth,
    this.weightKg,
    this.heightCm,
    this.bmiStale = false,
    required this.gender,
    this.county,
    this.subCounty,
    this.constituency,
    this.ward,
    this.occupation = '',
    required this.memberCode,
    this.healthProfileCompleted = false,
    this.hasHypertension,
    this.onHtnMedication,
    this.htnMedications = '',
    this.hasDiabetes,
    this.onDmMedication,
    this.dmMedications = '',
    this.htnOnboardingSeen = false,
    this.dmOnboardingSeen = false,
    this.shaBeneficiaryId = '',
    this.shaBeneficiaryIdType = '',
    this.nationalIdNumber,
    this.analyticsOptOut = false,
    this.shaDataSharingConsent = false,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$HealthProfileModelToJson(this);

  HealthProfile toEntity() => HealthProfile(
    email: email,
    fullName: fullName,
    phone: phone,
    age: age,
    ageStale: ageStale,
    dateOfBirth: dateOfBirth,
    weightKg: weightKg,
    heightCm: heightCm,
    bmiStale: bmiStale,
    gender: gender,
    county: county,
    subCounty: subCounty,
    constituency: constituency,
    ward: ward,
    occupation: occupation,
    memberCode: memberCode,
    healthProfileCompleted: healthProfileCompleted,
    hasHypertension: hasHypertension,
    onHtnMedication: onHtnMedication,
    htnMedications: htnMedications,
    hasDiabetes: hasDiabetes,
    onDmMedication: onDmMedication,
    dmMedications: dmMedications,
    htnOnboardingSeen: htnOnboardingSeen,
    dmOnboardingSeen: dmOnboardingSeen,
    shaBeneficiaryId: shaBeneficiaryId,
    shaBeneficiaryIdType: shaBeneficiaryIdType,
    nationalIdNumber: nationalIdNumber,
    analyticsOptOut: analyticsOptOut,
    shaDataSharingConsent: shaDataSharingConsent,
  );
}
