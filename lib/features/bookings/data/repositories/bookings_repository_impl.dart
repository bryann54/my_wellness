import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/bookings/data/models/models_extensions.dart';

import '../../domain/entities/booking_timeline.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/referral.dart';
import '../../domain/entities/service_booking.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../datasources/bookings_remote_datasource.dart';

@LazySingleton(as: BookingsRepository)
class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsRemoteDataSource _remote;

  BookingsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ServiceBooking>> createBooking(
    CreateBookingParams params,
  ) => _guard(
    () async => (await _remote.createBooking(params.toPayload())).toEntity(),
  );

  @override
  Future<Either<Failure, BookingsPage>> getMyBookings({String? cursor}) =>
      _guard(() async {
        final page = await _remote.getMyBookings(cursor: cursor);
        return BookingsPage(
          items: page.items.map((m) => m.toEntity()).toList(growable: false),
          nextCursor: page.nextCursor,
        );
      });

  @override
  Future<Either<Failure, BookingTimeline>> getBookingTimeline(
    String bookingId,
  ) => _guard(
    () async => (await _remote.getBookingTimeline(bookingId)).toEntity(),
  );

  @override
  Future<Either<Failure, ServiceBooking>> completeBooking(String bookingId) =>
      _guard(() async => (await _remote.completeBooking(bookingId)).toEntity());

  @override
  Future<Either<Failure, List<Facility>>> matchFacilities({
    required ServiceType serviceType,
    double? userLat,
    double? userLng,
    String? town,
    String? county,
  }) => _guard(
    () async => (await _remote.matchFacilities(
      serviceType: serviceTypeToWire(serviceType),
      userLat: userLat,
      userLng: userLng,
      town: town,
      county: county,
    )).map((m) => m.toEntity()).toList(growable: false),
  );

  @override
  Future<Either<Failure, List<Facility>>> searchFacilities(String query) =>
      _guard(
        () async => (await _remote.searchFacilities(
          query,
        )).map((m) => m.toEntity()).toList(growable: false),
      );

  @override
  Future<Either<Failure, Facility>> createFacility(
    CreateFacilityParams params,
  ) => _guard(
    () async => (await _remote.createFacility(params.toPayload())).toEntity(),
  );

  @override
  Future<Either<Failure, List<Referral>>> getMyReferrals() => _guard(
    () async => (await _remote.getMyReferrals())
        .map((m) => m.toEntity())
        .toList(growable: false),
  );

  @override
  Future<Either<Failure, Referral>> getReferral(String id) =>
      _guard(() async => (await _remote.getReferral(id)).toEntity());

  @override
  Future<Either<Failure, Referral>> generateReferralFromSession(
    String sessionId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _guard(
    () async => (await _remote.generateReferralFromSession(
      sessionId,
      userLat: userLat,
      userLng: userLng,
      facilityId: facilityId,
    )).toEntity(),
  );

  @override
  Future<Either<Failure, Referral>> generateReferralFromBpReading(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _guard(
    () async => (await _remote.generateReferralFromBpReading(
      readingId,
      userLat: userLat,
      userLng: userLng,
      facilityId: facilityId,
    )).toEntity(),
  );

  @override
  Future<Either<Failure, Referral>> generateReferralFromBsReading(
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) => _guard(
    () async => (await _remote.generateReferralFromBsReading(
      readingId,
      userLat: userLat,
      userLng: userLng,
      facilityId: facilityId,
    )).toEntity(),
  );

  @override
  Future<Either<Failure, Map<String, dynamic>>> pushStkForBooking(
    StkPushParams params,
  ) => _guard(() => _remote.stkPush(params.toPayload()));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on Exception catch (error) {
      return Left(_mapException(error));
    } catch (error) {
      return Left(GeneralFailure(error: error.toString()));
    }
  }

  Failure _mapException(Exception error) => switch (error) {
    UnauthorizedException() => const UnauthorizedFailure(),
    NetworkException() => const NetworkFailure(),
    NotFoundException(:final message) => NotFoundFailure(error: message),
    ValidationException(:final message) => ValidationFailure(error: message),
    ServerException() => const ServerFailure(),
    _ => GeneralFailure(error: error.toString()),
  };
}
