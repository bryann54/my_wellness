import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';

import '../entities/booking_timeline.dart';
import '../entities/facility.dart';
import '../entities/referral.dart';
import '../entities/service_booking.dart';

abstract class BookingsRepository {
  Future<Either<Failure, ServiceBooking>> createBooking(
    CreateBookingParams params,
  );

  Future<Either<Failure, BookingsPage>> getMyBookings({String? cursor});

  Future<Either<Failure, BookingTimeline>> getBookingTimeline(String bookingId);

  Future<Either<Failure, ServiceBooking>> completeBooking(String bookingId);

  Future<Either<Failure, List<Facility>>> matchFacilities({
    required ServiceType serviceType,
    double? userLat,
    double? userLng,
    String? town,
    String? county,
  });

  Future<Either<Failure, List<Facility>>> searchFacilities(String query);

  Future<Either<Failure, Facility>> createFacility(CreateFacilityParams params);

  Future<Either<Failure, List<Referral>>> getMyReferrals();

  Future<Either<Failure, Referral>> getReferral(String id);

  Future<Either<Failure, Referral>> generateReferralFromSession(
    String sessionId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  });

  Future<Either<Failure, Referral>> generateReferralFromBpReading(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  });

  Future<Either<Failure, Referral>> generateReferralFromBsReading(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  });

  Future<Either<Failure, Map<String, dynamic>>> pushStkForBooking(
    StkPushParams params,
  );
}

class CreateBookingParams {
  final ServiceType serviceType;
  final String serviceLabel;
  final int? priceKes;
  final String? dnaTestKind;
  final String? clinicianTier;
  final String? preferredLawFirm;
  final String? preferredDate;
  final String? preferredFacility;
  final String? facilityId;
  final String? referralId;
  final String? assessmentSlug;
  final String? sessionId;
  final String? contactPhone;
  final String? notes;

  const CreateBookingParams({
    required this.serviceType,
    required this.serviceLabel,
    this.priceKes,
    this.dnaTestKind,
    this.clinicianTier,
    this.preferredLawFirm,
    this.preferredDate,
    this.preferredFacility,
    this.facilityId,
    this.referralId,
    this.assessmentSlug,
    this.sessionId,
    this.contactPhone,
    this.notes,
  });

  Map<String, dynamic> toPayload() => {
    'service_type': serviceTypeToWire(serviceType),
    'service_label': serviceLabel,
    if (priceKes != null) 'price_kes': priceKes,
    if (dnaTestKind != null && dnaTestKind!.isNotEmpty)
      'dna_test_kind': dnaTestKind,
    if (clinicianTier != null && clinicianTier!.isNotEmpty)
      'clinician_tier': clinicianTier,
    if (preferredLawFirm != null && preferredLawFirm!.isNotEmpty)
      'preferred_law_firm': preferredLawFirm,
    if (preferredDate != null) 'preferred_date': preferredDate,
    if (preferredFacility != null && preferredFacility!.isNotEmpty)
      'preferred_facility': preferredFacility,
    if (facilityId != null) 'facility_id': facilityId,
    if (referralId != null) 'referral_id': referralId,
    if (assessmentSlug != null) 'assessment_slug': assessmentSlug,
    if (sessionId != null) 'session_id': sessionId,
    if (contactPhone != null && contactPhone!.isNotEmpty)
      'contact_phone': contactPhone,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

class CreateFacilityParams {
  final String name;
  final String town;
  final String county;
  final String? address;
  final String? phone;
  const CreateFacilityParams({
    required this.name,
    required this.town,
    required this.county,
    this.address,
    this.phone,
  });
  Map<String, dynamic> toPayload() => {
    'name': name,
    'town': town,
    'county': county,
    if (address != null && address!.isNotEmpty) 'address': address,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
  };
}

class StkPushParams {
  final String bookingId;
  final int amountKes;
  final String phone;
  final String serviceTypeLabel;
  final String? sessionId;
  final String? packageId;

  const StkPushParams({
    required this.bookingId,
    required this.amountKes,
    required this.phone,
    required this.serviceTypeLabel,
    this.sessionId,
    this.packageId,
  });

  Map<String, dynamic> toPayload() => {
    'booking_id': bookingId,
    'amount': amountKes,
    'phone': phone,
    'service_type': serviceTypeLabel,
    if (sessionId != null) 'session_id': sessionId,
    if (packageId != null) 'package_id': packageId,
  };
}
