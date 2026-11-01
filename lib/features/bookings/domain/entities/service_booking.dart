import 'package:equatable/equatable.dart';
import 'facility.dart';

enum BookingStatus { pending, confirmed, paid, cancelled, completed, unknown }

BookingStatus bookingStatusFrom(String raw) => switch (raw) {
  'pending' => BookingStatus.pending,
  'confirmed' => BookingStatus.confirmed,
  'paid' => BookingStatus.paid,
  'cancelled' => BookingStatus.cancelled,
  'completed' => BookingStatus.completed,
  _ => BookingStatus.unknown,
};

String bookingStatusToWire(BookingStatus s) => switch (s) {
  BookingStatus.pending => 'pending',
  BookingStatus.confirmed => 'confirmed',
  BookingStatus.paid => 'paid',
  BookingStatus.cancelled => 'cancelled',
  BookingStatus.completed => 'completed',
  BookingStatus.unknown => '',
};

enum ServiceType {
  screening,
  navigator,
  checkup,
  dnaTest,
  referralVisit,
  secondOpinion,
  unknown,
}

ServiceType serviceTypeFrom(String raw) => switch (raw) {
  'screening' => ServiceType.screening,
  'navigator' => ServiceType.navigator,
  'checkup' => ServiceType.checkup,
  'dna_test' => ServiceType.dnaTest,
  'referral_visit' => ServiceType.referralVisit,
  'second_opinion' => ServiceType.secondOpinion,
  _ => ServiceType.unknown,
};

String serviceTypeToWire(ServiceType t) => switch (t) {
  ServiceType.screening => 'screening',
  ServiceType.navigator => 'navigator',
  ServiceType.checkup => 'checkup',
  ServiceType.dnaTest => 'dna_test',
  ServiceType.referralVisit => 'referral_visit',
  ServiceType.secondOpinion => 'second_opinion',
  ServiceType.unknown => '',
};

bool _manuallyCompletable(bool isHieManaged, BookingStatus status) =>
    !isHieManaged &&
    (status == BookingStatus.pending ||
        status == BookingStatus.confirmed ||
        status == BookingStatus.paid);

class BookingSummary extends Equatable {
  final String id;
  final String status;
  final String serviceLabel;
  final String? preferredDate;
  final DateTime? checkedInAt;
  final bool isHieManaged;
  final String? followUpToId;

  const BookingSummary({
    required this.id,
    required this.status,
    required this.serviceLabel,
    this.preferredDate,
    this.checkedInAt,
    this.isHieManaged = false,
    this.followUpToId,
  });

  BookingStatus get statusEnum => bookingStatusFrom(status);

  bool get canBeManuallyCompleted =>
      _manuallyCompletable(isHieManaged, statusEnum);

  @override
  List<Object?> get props => [
    id,
    status,
    serviceLabel,
    preferredDate,
    checkedInAt,
    isHieManaged,
    followUpToId,
  ];
}

class ServiceBooking extends Equatable {
  final String id;
  final ServiceType serviceType;
  final String serviceLabel;
  final int priceKes;
  final BookingStatus status;
  final bool requiresScheduling;
  final String dnaTestKind;
  final String clinicianTier;
  final String preferredLawFirm;
  final String? preferredDate;
  final DateTime? appointmentTime;
  final String preferredFacility;
  final Facility? facility;
  final DateTime? checkedInAt;
  final String contactPhone;
  final String notes;
  final String? followUpToId;
  final List<BookingSummary> followUps;
  final DateTime? createdAt;
  final bool isHieManaged;
  final String? referralId;

  const ServiceBooking({
    required this.id,
    required this.serviceType,
    required this.serviceLabel,
    required this.priceKes,
    required this.status,
    required this.requiresScheduling,
    required this.dnaTestKind,
    required this.clinicianTier,
    required this.preferredLawFirm,
    this.preferredDate,
    this.appointmentTime,
    required this.preferredFacility,
    this.facility,
    this.checkedInAt,
    required this.contactPhone,
    required this.notes,
    this.followUpToId,
    this.followUps = const [],
    this.createdAt,
    this.isHieManaged = false,
    this.referralId,
  });

  bool get canBeManuallyCompleted => _manuallyCompletable(isHieManaged, status);

  bool get needsImmediatePayment =>
      priceKes > 0 && status == BookingStatus.pending;

  @override
  List<Object?> get props => [
    id,
    serviceType,
    serviceLabel,
    priceKes,
    status,
    requiresScheduling,
    dnaTestKind,
    clinicianTier,
    preferredLawFirm,
    preferredDate,
    appointmentTime,
    preferredFacility,
    facility,
    checkedInAt,
    contactPhone,
    notes,
    followUpToId,
    followUps,
    createdAt,
    isHieManaged,
    referralId,
  ];
}

class BookingsPage {
  final List<ServiceBooking> items;
  final String? nextCursor;

  const BookingsPage({required this.items, this.nextCursor});
}
