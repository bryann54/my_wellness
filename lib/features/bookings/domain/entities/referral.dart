import 'package:equatable/equatable.dart';
import 'facility.dart';
import 'service_booking.dart';

enum ReferralStatus { generated, viewed, booked, completed, dismissed, unknown }

ReferralStatus referralStatusFrom(String raw) => switch (raw) {
  'generated' => ReferralStatus.generated,
  'viewed' => ReferralStatus.viewed,
  'booked' => ReferralStatus.booked,
  'completed' => ReferralStatus.completed,
  'dismissed' => ReferralStatus.dismissed,
  _ => ReferralStatus.unknown,
};

enum ReferralSourceType { assessment, vitalsBp, vitalsBs, unknown }

ReferralSourceType referralSourceFrom(String raw) => switch (raw) {
  'assessment' => ReferralSourceType.assessment,
  'vitals_bp' => ReferralSourceType.vitalsBp,
  'vitals_bs' => ReferralSourceType.vitalsBs,
  _ => ReferralSourceType.unknown,
};

class ReferralService extends Equatable {
  final String code;
  final String name;
  const ReferralService({required this.code, required this.name});
  @override
  List<Object?> get props => [code, name];
}

class Referral extends Equatable {
  final String id;
  final ReferralSourceType sourceType;
  final String? sessionId;
  final String escalationCategory;
  final String escalationCategoryDisplay;
  final List<ReferralService> requiredServices;
  final String reason;
  final Facility? recommendedFacility;
  final String? distanceKm;
  final int? travelTimeMinutes;
  final String shaAccreditationStatus;
  final BookingSummary? booking;
  final ReferralStatus status;
  final DateTime? createdAt;

  const Referral({
    required this.id,
    required this.sourceType,
    this.sessionId,
    required this.escalationCategory,
    required this.escalationCategoryDisplay,
    this.requiredServices = const [],
    required this.reason,
    this.recommendedFacility,
    this.distanceKm,
    this.travelTimeMinutes,
    this.shaAccreditationStatus = 'unavailable',
    this.booking,
    this.status = ReferralStatus.generated,
    this.createdAt,
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
    distanceKm,
    travelTimeMinutes,
    shaAccreditationStatus,
    booking,
    status,
    createdAt,
  ];
}
