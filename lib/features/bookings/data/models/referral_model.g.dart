// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralServiceModel _$ReferralServiceModelFromJson(
  Map<String, dynamic> json,
) => ReferralServiceModel(
  code: json['code'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$ReferralServiceModelToJson(
  ReferralServiceModel instance,
) => <String, dynamic>{'code': instance.code, 'name': instance.name};

ReferralModel _$ReferralModelFromJson(
  Map<String, dynamic> json,
) => ReferralModel(
  id: json['id'] as String,
  sourceType: json['source_type'] as String,
  session: json['session'] as String?,
  escalationCategory: json['escalation_category'] as String,
  escalationCategoryDisplay:
      json['escalation_category_display'] as String? ?? '',
  requiredServices:
      (json['required_services'] as List<dynamic>?)
          ?.map((e) => ReferralServiceModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  reason: json['reason'] as String? ?? '',
  recommendedFacility: json['recommended_facility'] == null
      ? null
      : FacilityModel.fromJson(
          json['recommended_facility'] as Map<String, dynamic>,
        ),
  distanceKm: _toStrOrNull(json['distance_km']),
  travelTimeMinutes: _toIntOrNull(json['travel_time_minutes']),
  shaAccreditationStatus:
      json['sha_accreditation_status'] as String? ?? 'unavailable',
  booking: json['booking'] == null
      ? null
      : BookingSummaryModel.fromJson(json['booking'] as Map<String, dynamic>),
  status: json['status'] as String,
  createdAt: _dateOrNull(json['created_at']),
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
      'distance_km': instance.distanceKm,
      'travel_time_minutes': instance.travelTimeMinutes,
      'sha_accreditation_status': instance.shaAccreditationStatus,
      'booking': instance.booking?.toJson(),
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
    };
