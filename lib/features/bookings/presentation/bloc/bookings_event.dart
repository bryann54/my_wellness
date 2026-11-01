part of 'bookings_bloc.dart';

abstract class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyBookingsEvent extends BookingsEvent {
  final bool refresh;
  const LoadMyBookingsEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreMyBookingsEvent extends BookingsEvent {
  const LoadMoreMyBookingsEvent();
}

class LoadBookingTimelineEvent extends BookingsEvent {
  final String bookingId;
  const LoadBookingTimelineEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class CompleteBookingEvent extends BookingsEvent {
  final String bookingId;
  const CompleteBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class CreateBookingEvent extends BookingsEvent {
  final CreateBookingParams params;
  const CreateBookingEvent(this.params);

  @override
  List<Object?> get props => [
    params.serviceType,
    params.facilityId,
    params.referralId,
    params.preferredDate,
    params.priceKes,
  ];
}

class PushStkForBookingEvent extends BookingsEvent {
  final StkPushParams params;
  const PushStkForBookingEvent(this.params);

  @override
  List<Object?> get props => [params.bookingId, params.amountKes];
}

class AwaitBookingConsentEvent extends BookingsEvent {
  const AwaitBookingConsentEvent();
}

class FinishBookingFlowEvent extends BookingsEvent {
  const FinishBookingFlowEvent();
}

class ResetCreateBookingEvent extends BookingsEvent {
  const ResetCreateBookingEvent();
}

class MatchFacilitiesEvent extends BookingsEvent {
  final ServiceType serviceType;
  final double? userLat;
  final double? userLng;
  final String? town;
  final String? county;

  const MatchFacilitiesEvent(
    this.serviceType, {
    this.userLat,
    this.userLng,
    this.town,
    this.county,
  });

  @override
  List<Object?> get props => [serviceType, town, county];
}

class SearchFacilitiesEvent extends BookingsEvent {
  final String query;
  const SearchFacilitiesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateFacilityEvent extends BookingsEvent {
  final CreateFacilityParams params;
  const CreateFacilityEvent(this.params);

  @override
  List<Object?> get props => [params.name, params.town, params.county];
}

class LoadMyReferralsEvent extends BookingsEvent {
  final bool refresh;
  const LoadMyReferralsEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadReferralEvent extends BookingsEvent {
  final String referralId;
  final bool silent;
  const LoadReferralEvent(this.referralId, {this.silent = false});

  @override
  List<Object?> get props => [referralId, silent];
}

class GenerateReferralFromSessionEvent extends BookingsEvent {
  final String sessionId;
  final double? userLat;
  final double? userLng;
  final String? facilityId;

  const GenerateReferralFromSessionEvent(
    this.sessionId, {
    this.userLat,
    this.userLng,
    this.facilityId,
  });

  @override
  List<Object?> get props => [sessionId, facilityId];
}

class GenerateReferralFromBpReadingEvent extends BookingsEvent {
  final String readingId;
  final double? userLat;
  final double? userLng;
  final String? facilityId;

  const GenerateReferralFromBpReadingEvent(
    this.readingId, {
    this.userLat,
    this.userLng,
    this.facilityId,
  });

  @override
  List<Object?> get props => [readingId, facilityId];
}

class GenerateReferralFromBsReadingEvent extends BookingsEvent {
  final String readingId;
  final double? userLat;
  final double? userLng;
  final String? facilityId;

  const GenerateReferralFromBsReadingEvent(
    this.readingId, {
    this.userLat,
    this.userLng,
    this.facilityId,
  });

  @override
  List<Object?> get props => [readingId, facilityId];
}
