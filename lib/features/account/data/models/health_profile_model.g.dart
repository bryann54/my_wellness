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
      age: (json['age'] as num?)?.toInt(),
      ageStale: json['age_stale'] as bool? ?? false,
      dateOfBirth: json['date_of_birth'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      bmiStale: json['bmi_stale'] as bool? ?? false,
      gender: json['gender'] as String,
      county: json['county'] as String?,
      subCounty: (json['sub_county'] as num?)?.toInt(),
      constituency: (json['constituency'] as num?)?.toInt(),
      ward: (json['ward'] as num?)?.toInt(),
      occupation: json['occupation'] as String? ?? '',
      memberCode: json['member_code'] as String,
      healthProfileCompleted:
          json['health_profile_completed'] as bool? ?? false,
      hasHypertension: json['has_hypertension'] as bool?,
      onHtnMedication: json['on_htn_medication'] as bool?,
      htnMedications: json['htn_medications'] as String? ?? '',
      hasDiabetes: json['has_diabetes'] as bool?,
      onDmMedication: json['on_dm_medication'] as bool?,
      dmMedications: json['dm_medications'] as String? ?? '',
      htnOnboardingSeen: json['htn_onboarding_seen'] as bool? ?? false,
      dmOnboardingSeen: json['dm_onboarding_seen'] as bool? ?? false,
      shaBeneficiaryId: json['sha_beneficiary_id'] as String? ?? '',
      shaBeneficiaryIdType: json['sha_beneficiary_id_type'] as String? ?? '',
      nationalIdNumber: json['national_id_number'] as String?,
      analyticsOptOut: json['analytics_opt_out'] as bool? ?? false,
      shaDataSharingConsent: json['sha_data_sharing_consent'] as bool? ?? false,
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
