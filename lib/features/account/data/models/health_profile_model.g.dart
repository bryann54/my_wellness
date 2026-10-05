// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthProfileModel _$HealthProfileModelFromJson(Map<String, dynamic> json) =>
    HealthProfileModel(
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      age: _intFromJson(json['age']),
      ageStale: json['age_stale'] == null
          ? false
          : _boolFromJson(json['age_stale']),
      dateOfBirth: json['date_of_birth'] as String?,
      weightKg: _doubleFromJson(json['weight_kg']),
      heightCm: _doubleFromJson(json['height_cm']),
      bmiStale: json['bmi_stale'] == null
          ? false
          : _boolFromJson(json['bmi_stale']),
      gender: json['gender'] as String,
      county: json['county'] as String?,
      subCounty: _intFromJson(json['sub_county']),
      constituency: _intFromJson(json['constituency']),
      ward: _intFromJson(json['ward']),
      occupation: json['occupation'] == null
          ? ''
          : _stringFromJson(json['occupation']),
      memberCode: json['member_code'] as String,
      healthProfileCompleted: json['health_profile_completed'] == null
          ? false
          : _boolFromJson(json['health_profile_completed']),
      hasHypertension: _boolOrNullFromJson(json['has_hypertension']),
      onHtnMedication: _boolOrNullFromJson(json['on_htn_medication']),
      htnMedications: json['htn_medications'] == null
          ? ''
          : _stringFromJson(json['htn_medications']),
      hasDiabetes: _boolOrNullFromJson(json['has_diabetes']),
      onDmMedication: _boolOrNullFromJson(json['on_dm_medication']),
      dmMedications: json['dm_medications'] == null
          ? ''
          : _stringFromJson(json['dm_medications']),
      htnOnboardingSeen: json['htn_onboarding_seen'] == null
          ? false
          : _boolFromJson(json['htn_onboarding_seen']),
      dmOnboardingSeen: json['dm_onboarding_seen'] == null
          ? false
          : _boolFromJson(json['dm_onboarding_seen']),
      shaBeneficiaryId: json['sha_beneficiary_id'] == null
          ? ''
          : _stringFromJson(json['sha_beneficiary_id']),
      shaBeneficiaryIdType: json['sha_beneficiary_id_type'] == null
          ? ''
          : _stringFromJson(json['sha_beneficiary_id_type']),
      nationalIdNumber: _stringOrNullFromJson(json['national_id_number']),
      analyticsOptOut: json['analytics_opt_out'] == null
          ? false
          : _boolFromJson(json['analytics_opt_out']),
      shaDataSharingConsent: json['sha_data_sharing_consent'] == null
          ? false
          : _boolFromJson(json['sha_data_sharing_consent']),
    );

Map<String, dynamic> _$HealthProfileModelToJson(HealthProfileModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'age': instance.age,
      'age_stale': instance.ageStale,
      'date_of_birth': instance.dateOfBirth,
      'weight_kg': instance.weightKg,
      'height_cm': instance.heightCm,
      'bmi_stale': instance.bmiStale,
      'gender': instance.gender,
      'county': instance.county,
      'sub_county': instance.subCounty,
      'constituency': instance.constituency,
      'ward': instance.ward,
      'occupation': instance.occupation,
      'member_code': instance.memberCode,
      'health_profile_completed': instance.healthProfileCompleted,
      'has_hypertension': instance.hasHypertension,
      'on_htn_medication': instance.onHtnMedication,
      'htn_medications': instance.htnMedications,
      'has_diabetes': instance.hasDiabetes,
      'on_dm_medication': instance.onDmMedication,
      'dm_medications': instance.dmMedications,
      'htn_onboarding_seen': instance.htnOnboardingSeen,
      'dm_onboarding_seen': instance.dmOnboardingSeen,
      'sha_beneficiary_id': instance.shaBeneficiaryId,
      'sha_beneficiary_id_type': instance.shaBeneficiaryIdType,
      'national_id_number': instance.nationalIdNumber,
      'analytics_opt_out': instance.analyticsOptOut,
      'sha_data_sharing_consent': instance.shaDataSharingConsent,
    };
