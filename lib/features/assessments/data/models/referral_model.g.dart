// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralModel _$ReferralModelFromJson(Map<String, dynamic> json) =>
    ReferralModel(
      id: json['id'] as String,
      sourceType: json['source_type'] as String,
      session: json['session'] as String,
      escalationCategory: json['escalation_category'] as String,
      status: json['status'] as String,
      escalationCategoryDisplay: json['escalation_category_display'] as String?,
      requiredServices:
          (json['required_services'] as List<dynamic>?)
              ?.map(
                (e) => ReferralServiceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      reason: json['reason'] as String?,
      recommendedFacility: json['recommended_facility'] == null
          ? null
          : ReferralFacilityModel.fromJson(
              json['recommended_facility'] as Map<String, dynamic>,
            ),
      scoreBreakdown: json['score_breakdown'] == null
          ? null
          : ReferralScoreBreakdownModel.fromJson(
              json['score_breakdown'] as Map<String, dynamic>,
            ),
      shaAccreditationStatus: json['sha_accreditation_status'] as String?,
    );

Map<String, dynamic> _$ReferralModelToJson(ReferralModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_type': instance.sourceType,
      'session': instance.session,
      'escalation_category': instance.escalationCategory,
      'escalation_category_display': instance.escalationCategoryDisplay,
      'required_services': instance.requiredServices
          .map((e) => e.toJson())
          .toList(),
      'reason': instance.reason,
      'recommended_facility': instance.recommendedFacility?.toJson(),
      'score_breakdown': instance.scoreBreakdown?.toJson(),
      'sha_accreditation_status': instance.shaAccreditationStatus,
      'status': instance.status,
    };

ReferralServiceModel _$ReferralServiceModelFromJson(
  Map<String, dynamic> json,
) => ReferralServiceModel(
  code: json['code'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$ReferralServiceModelToJson(
  ReferralServiceModel instance,
) => <String, dynamic>{'code': instance.code, 'name': instance.name};

ReferralFacilityModel _$ReferralFacilityModelFromJson(
  Map<String, dynamic> json,
) => ReferralFacilityModel(
  id: json['id'] as String,
  name: json['name'] as String,
  town: json['town'] as String?,
  county: json['county'] as String?,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  services: json['services'] as List<dynamic>? ?? const [],
  coversSha: json['covers_sha'] as bool? ?? false,
  kephLevel: (json['keph_level'] as num?)?.toInt(),
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ReferralFacilityModelToJson(
  ReferralFacilityModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'town': instance.town,
  'county': instance.county,
  'address': instance.address,
  'phone': instance.phone,
  'services': instance.services,
  'covers_sha': instance.coversSha,
  'keph_level': instance.kephLevel,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'distance_km': instance.distanceKm,
};

ReferralScoreBreakdownModel _$ReferralScoreBreakdownModelFromJson(
  Map<String, dynamic> json,
) => ReferralScoreBreakdownModel(
  total: (json['total'] as num).toDouble(),
  serviceMatch: (json['service_match'] as num?)?.toDouble(),
  clinicalCapability: (json['clinical_capability'] as num?)?.toDouble(),
  escalationMatch: (json['escalation_match'] as num?)?.toDouble(),
  shaAccreditation: (json['sha_accreditation'] as num?)?.toDouble(),
  facilityReadiness: (json['facility_readiness'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ReferralScoreBreakdownModelToJson(
  ReferralScoreBreakdownModel instance,
) => <String, dynamic>{
  'total': instance.total,
  'service_match': instance.serviceMatch,
  'clinical_capability': instance.clinicalCapability,
  'escalation_match': instance.escalationMatch,
  'sha_accreditation': instance.shaAccreditation,
  'facility_readiness': instance.facilityReadiness,
};
