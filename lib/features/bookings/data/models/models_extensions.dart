import '../../domain/entities/booking_timeline.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/referral.dart';
import '../../domain/entities/service_booking.dart';
import 'booking_timeline_model.dart';
import 'facility_model.dart';
import 'referral_model.dart';
import 'service_booking_model.dart';

extension FacilityModelX on FacilityModel {
  Facility toEntity() => Facility(
    id: id,
    name: name,
    town: town,
    county: county,
    address: address,
    phone: phone,
    services: services,
    latitude: latitude,
    longitude: longitude,
    coversSha: coversSha,
    kephLevel: kephLevel,
    shaFunds: shaFunds,
    distanceKm: distanceKm,
  );
}

extension BookingSummaryModelX on BookingSummaryModel {
  BookingSummary toEntity() => BookingSummary(
    id: id,
    status: status,
    serviceLabel: serviceLabel,
    preferredDate: preferredDate,
    checkedInAt: checkedInAt,
    isHieManaged: isHieManaged,
    followUpToId: followUpTo,
  );
}

extension ServiceBookingModelX on ServiceBookingModel {
  ServiceBooking toEntity() => ServiceBooking(
    id: id,
    serviceType: serviceTypeFrom(serviceType),
    serviceLabel: serviceLabel,
    priceKes: priceKes,
    status: bookingStatusFrom(status),
    requiresScheduling: requiresScheduling,
    dnaTestKind: dnaTestKind,
    clinicianTier: clinicianTier,
    preferredLawFirm: preferredLawFirm,
    preferredDate: preferredDate,
    appointmentTime: appointmentTime,
    preferredFacility: preferredFacility,
    facility: facility?.toEntity(),
    checkedInAt: checkedInAt,
    contactPhone: contactPhone,
    notes: notes,
    followUpToId: followUpTo,
    followUps: followUps.map((m) => m.toEntity()).toList(growable: false),
    createdAt: createdAt,
    isHieManaged: isHieManaged,
    referralId: referralId,
  );
}

extension TimelineEntryModelX on TimelineEntryModel {
  TimelineEntry toEntity() =>
      TimelineEntry(type: type, createdAt: createdAt, data: data);
}

extension BookingTimelineModelX on BookingTimelineModel {
  BookingTimeline toEntity() => BookingTimeline(
    booking: booking.toEntity(),
    timeline: timeline.map((m) => m.toEntity()).toList(growable: false),
    isOwner: isOwner,
  );
}

extension ReferralServiceModelX on ReferralServiceModel {
  ReferralService toEntity() => ReferralService(code: code, name: name);
}

extension ReferralModelX on ReferralModel {
  Referral toEntity() => Referral(
    id: id,
    sourceType: referralSourceFrom(sourceType),
    sessionId: session,
    escalationCategory: escalationCategory,
    escalationCategoryDisplay: escalationCategoryDisplay,
    requiredServices: requiredServices
        .map((m) => m.toEntity())
        .toList(growable: false),
    reason: reason,
    recommendedFacility: recommendedFacility?.toEntity(),
    distanceKm: distanceKm,
    travelTimeMinutes: travelTimeMinutes,
    shaAccreditationStatus: shaAccreditationStatus,
    booking: booking?.toEntity(),
    status: referralStatusFrom(status),
    createdAt: createdAt,
  );
}
