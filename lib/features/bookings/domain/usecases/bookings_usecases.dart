import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';

import '../entities/booking_timeline.dart';
import '../entities/facility.dart';
import '../entities/referral.dart';
import '../entities/service_booking.dart';
import '../repositories/bookings_repository.dart';

@lazySingleton
class CreateBookingUseCase {
  final BookingsRepository _repo;
  CreateBookingUseCase(this._repo);
  Future<Either<Failure, ServiceBooking>> call(CreateBookingParams params) =>
      _repo.createBooking(params);
}

@lazySingleton
class GetMyBookingsUseCase {
  final BookingsRepository _repo;
  GetMyBookingsUseCase(this._repo);
  Future<Either<Failure, BookingsPage>> call({String? cursor}) =>
      _repo.getMyBookings(cursor: cursor);
}

@lazySingleton
class GetBookingTimelineUseCase {
  final BookingsRepository _repo;
  GetBookingTimelineUseCase(this._repo);
  Future<Either<Failure, BookingTimeline>> call(String bookingId) =>
      _repo.getBookingTimeline(bookingId);
}

@lazySingleton
class CompleteBookingUseCase {
  final BookingsRepository _repo;
  CompleteBookingUseCase(this._repo);
  Future<Either<Failure, ServiceBooking>> call(String bookingId) =>
      _repo.completeBooking(bookingId);
}

@lazySingleton
class MatchFacilitiesUseCase {
  final BookingsRepository _repo;
  MatchFacilitiesUseCase(this._repo);
  Future<Either<Failure, List<Facility>>> call({
    required ServiceType serviceType,
    double? userLat,
    double? userLng,
    String? town,
    String? county,
  }) => _repo.matchFacilities(
    serviceType: serviceType,
    userLat: userLat,
    userLng: userLng,
    town: town,
    county: county,
  );
}

@lazySingleton
class SearchFacilitiesUseCase {
  final BookingsRepository _repo;
  SearchFacilitiesUseCase(this._repo);
  Future<Either<Failure, List<Facility>>> call(String query) =>
      _repo.searchFacilities(query);
}

@lazySingleton
class CreateFacilityUseCase {
  final BookingsRepository _repo;
  CreateFacilityUseCase(this._repo);
  Future<Either<Failure, Facility>> call(CreateFacilityParams params) =>
      _repo.createFacility(params);
}

@lazySingleton
class GetMyReferralsUseCase {
  final BookingsRepository _repo;
  GetMyReferralsUseCase(this._repo);
  Future<Either<Failure, List<Referral>>> call() => _repo.getMyReferrals();
}

@lazySingleton
class GetReferralUseCase {
  final BookingsRepository _repo;
  GetReferralUseCase(this._repo);
  Future<Either<Failure, Referral>> call(String id) => _repo.getReferral(id);
}

@lazySingleton
class GenerateReferralFromSessionUseCase {
  final BookingsRepository _repo;
  GenerateReferralFromSessionUseCase(this._repo);
  Future<Either<Failure, Referral>> call(
    String sessionId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _repo.generateReferralFromSession(
    sessionId,
    userLat: userLat,
    userLng: userLng,
    facilityId: facilityId,
  );
}

@lazySingleton
class GenerateReferralFromBpReadingUseCase {
  final BookingsRepository _repo;
  GenerateReferralFromBpReadingUseCase(this._repo);
  Future<Either<Failure, Referral>> call(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _repo.generateReferralFromBpReading(
    readingId,
    userLat: userLat,
    userLng: userLng,
    facilityId: facilityId,
  );
}

@lazySingleton
class GenerateReferralFromBsReadingUseCase {
  final BookingsRepository _repo;
  GenerateReferralFromBsReadingUseCase(this._repo);
  Future<Either<Failure, Referral>> call(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _repo.generateReferralFromBsReading(
    readingId,
    userLat: userLat,
    userLng: userLng,
    facilityId: facilityId,
  );
}

@lazySingleton
class PushStkForBookingUseCase {
  final BookingsRepository _repo;
  PushStkForBookingUseCase(this._repo);
  Future<Either<Failure, Map<String, dynamic>>> call(StkPushParams params) =>
      _repo.pushStkForBooking(params);
}
