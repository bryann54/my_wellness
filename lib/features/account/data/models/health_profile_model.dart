// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';

part 'health_profile_model.g.dart';

@JsonSerializable()
class HealthProfileModel {
  final String email;

  @JsonKey(name: 'full_name')
  final String fullName;

  final String phone;

  final int? age;

  @JsonKey(name: 'age_stale')
  final bool ageStale;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  @JsonKey(name: 'weight_kg')
  final double? weightKg;

  @JsonKey(name: 'height_cm')
  final double? heightCm;

  @JsonKey(name: 'bmi_stale')
  final bool bmiStale;

  final String gender;

  final String? county;

  @JsonKey(name: 'sub_county')
  final int? subCounty;

  final int? constituency;
  final int? ward;
  final String occupation;

  @JsonKey(name: 'member_code')
  final String memberCode;

  @JsonKey(name: 'health_profile_completed')
  final bool healthProfileCompleted;

  @JsonKey(name: 'has_hypertension')
  final bool? hasHypertension;

  @JsonKey(name: 'on_htn_medication')
  final bool? onHtnMedication;

  @JsonKey(name: 'htn_medications')
  final String htnMedications;

  @JsonKey(name: 'has_diabetes')
  final bool? hasDiabetes;

  @JsonKey(name: 'on_dm_medication')
  final bool? onDmMedication;

  @JsonKey(name: 'dm_medications')
  final String dmMedications;

  @JsonKey(name: 'htn_onboarding_seen')
  final bool htnOnboardingSeen;

  @JsonKey(name: 'dm_onboarding_seen')
  final bool dmOnboardingSeen;

  @JsonKey(name: 'sha_beneficiary_id')
  final String shaBeneficiaryId;

  @JsonKey(name: 'sha_beneficiary_id_type')
  final String shaBeneficiaryIdType;

  @JsonKey(name: 'national_id_number')
  final String? nationalIdNumber;

  @JsonKey(name: 'analytics_opt_out')
  final bool analyticsOptOut;

  @JsonKey(name: 'sha_data_sharing_consent')
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
