import 'package:equatable/equatable.dart';

class ReferralService extends Equatable {
  final String code;
  final String name;
  const ReferralService({required this.code, required this.name});

  @override
  List<Object?> get props => [code, name];
}

class ReferralFacility extends Equatable {
  final String id;
  final String name;
  final String? town;
  final String? county;
  final String? address;
  final String? phone;
  final bool coversSha;
  final int? kephLevel;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  const ReferralFacility({
    required this.id,
    required this.name,
    this.town,
    this.county,
    this.address,
    this.phone,
    this.coversSha = false,
    this.kephLevel,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  String get locality {
    final t = town?.trim();
    final c = county?.trim();
    if (t != null && t.isNotEmpty && c != null && c.isNotEmpty) {
      return '$t, $c';
    }
    return t?.isNotEmpty == true ? t! : (c ?? '');
  }

  @override
  List<Object?> get props => [
    id,
    name,
    town,
    county,
    address,
    phone,
    coversSha,
    kephLevel,
    latitude,
    longitude,
    distanceKm,
  ];
}

class ReferralScoreBreakdown extends Equatable {
  final double total;
  final Map<String, double> components;
  const ReferralScoreBreakdown({
    required this.total,
    this.components = const {},
  });

  @override
  List<Object?> get props => [total, components];
}

class Referral extends Equatable {
  final String id;
  final String sourceType;
  final String sessionId;
  final String escalationCategory;
  final String? escalationCategoryDisplay;
  final List<ReferralService> requiredServices;
  final String? reason;
  final ReferralFacility? recommendedFacility;
  final ReferralScoreBreakdown? scoreBreakdown;
  final String? shaAccreditationStatus;
  final String status;

  const Referral({
    required this.id,
    required this.sourceType,
    required this.sessionId,
    required this.escalationCategory,
    required this.status,
    this.escalationCategoryDisplay,
    this.requiredServices = const [],
    this.reason,
    this.recommendedFacility,
    this.scoreBreakdown,
    this.shaAccreditationStatus,
  });

  @override
  List<Object?> get props => [
    id,
    sourceType,
    sessionId,
    escalationCategory,
    escalationCategoryDisplay,
    requiredServices,
    reason,
    recommendedFacility,
    scoreBreakdown,
    shaAccreditationStatus,
    status,
  ];
}
