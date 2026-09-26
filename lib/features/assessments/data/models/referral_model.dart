import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';

part 'referral_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReferralModel {
  final String id;

  @JsonKey(name: 'source_type')
  final String sourceType;

  final String session;

  @JsonKey(name: 'escalation_category')
  final String escalationCategory;

  @JsonKey(name: 'escalation_category_display')
  final String? escalationCategoryDisplay;

  @JsonKey(name: 'required_services')
  final List<ReferralServiceModel> requiredServices;

  final String? reason;

  @JsonKey(name: 'recommended_facility')
  final ReferralFacilityModel? recommendedFacility;

  @JsonKey(name: 'score_breakdown')
  final ReferralScoreBreakdownModel? scoreBreakdown;

  @JsonKey(name: 'sha_accreditation_status')
  final String? shaAccreditationStatus;

  final String status;

  const ReferralModel({
    required this.id,
    required this.sourceType,
    required this.session,
    required this.escalationCategory,
    required this.status,
    this.escalationCategoryDisplay,
    this.requiredServices = const [],
    this.reason,
    this.recommendedFacility,
    this.scoreBreakdown,
    this.shaAccreditationStatus,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralModelToJson(this);

  Referral toEntity() => Referral(
    id: id,
    sourceType: sourceType,
    sessionId: session,
    escalationCategory: escalationCategory,
    escalationCategoryDisplay: escalationCategoryDisplay,
    requiredServices: requiredServices
        .map((s) => s.toEntity())
        .toList(growable: false),
    reason: reason,
    recommendedFacility: recommendedFacility?.toEntity(),
    scoreBreakdown: scoreBreakdown?.toEntity(),
    shaAccreditationStatus: shaAccreditationStatus,
    status: status,
  );
}

@JsonSerializable()
class ReferralServiceModel {
  final String code;
  final String name;
  const ReferralServiceModel({required this.code, required this.name});

  factory ReferralServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralServiceModelToJson(this);

  ReferralService toEntity() => ReferralService(code: code, name: name);
}

@JsonSerializable()
class ReferralFacilityModel {
  final String id;
  final String name;
  final String? town;
  final String? county;
  final String? address;
  final String? phone;
  final List<dynamic> services;

  @JsonKey(name: 'covers_sha')
  final bool coversSha;

  @JsonKey(name: 'keph_level')
  final int? kephLevel;

  final String? latitude;
  final String? longitude;

  @JsonKey(name: 'distance_km')
  final double? distanceKm;

  const ReferralFacilityModel({
    required this.id,
    required this.name,
    this.town,
    this.county,
    this.address,
    this.phone,
    this.services = const [],
    this.coversSha = false,
    this.kephLevel,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  factory ReferralFacilityModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralFacilityModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralFacilityModelToJson(this);

  ReferralFacility toEntity() => ReferralFacility(
    id: id,
    name: name,
    town: town,
    county: county,
    address: address,
    phone: phone,
    coversSha: coversSha,
    kephLevel: kephLevel,
    latitude: latitude == null ? null : double.tryParse(latitude!),
    longitude: longitude == null ? null : double.tryParse(longitude!),
    distanceKm: distanceKm,
  );
}

@JsonSerializable()
class ReferralScoreBreakdownModel {
  @JsonKey(name: 'total')
  final double total;

  @JsonKey(name: 'service_match')
  final double? serviceMatch;

  @JsonKey(name: 'clinical_capability')
  final double? clinicalCapability;

  @JsonKey(name: 'escalation_match')
  final double? escalationMatch;

  @JsonKey(name: 'sha_accreditation')
  final double? shaAccreditation;

  @JsonKey(name: 'facility_readiness')
  final double? facilityReadiness;

  const ReferralScoreBreakdownModel({
    required this.total,
    this.serviceMatch,
    this.clinicalCapability,
    this.escalationMatch,
    this.shaAccreditation,
    this.facilityReadiness,
  });

  factory ReferralScoreBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralScoreBreakdownModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralScoreBreakdownModelToJson(this);

  ReferralScoreBreakdown toEntity() => ReferralScoreBreakdown(
    total: total,
    components: {
      if (serviceMatch != null) 'service_match': serviceMatch!,
      if (clinicalCapability != null)
        'clinical_capability': clinicalCapability!,
      if (escalationMatch != null) 'escalation_match': escalationMatch!,
      if (shaAccreditation != null) 'sha_accreditation': shaAccreditation!,
      if (facilityReadiness != null) 'facility_readiness': facilityReadiness!,
    },
  );
}
