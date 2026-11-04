import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_access.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_content.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_result.dart';
import 'package:my_wellness/features/vitals/domain/repositories/vitals_capture_repository.dart';

@LazySingleton(as: VitalsCaptureRepository)
class VitalsCaptureRepositoryImpl implements VitalsCaptureRepository {
  final VitalsCaptureRemoteDataSource _remote;
  VitalsCaptureRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, VitalsCaptureContent>> getContent(
    VitalsCaptureKind kind,
  ) async {
    try {
      return Right(await _remote.getContent(kind));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, VitalsCaptureResult>> createSession(
    VitalsCaptureKind kind,
    Map<String, dynamic> payload,
  ) async {
    try {
      return Right(await _remote.createSession(kind, payload));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Referral?>> getReferralFromReading(
    VitalsCaptureKind kind,
    String readingId,
  ) async {
    try {
      return Right(await _remote.getReferralFromReading(kind, readingId));
    } on Exception {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, VitalsAccess>> getAccess() async {
    try {
      return Right(await _remote.getAccess());
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, VitalsAccess>> alertNavigator() async {
    try {
      return Right(await _remote.alertNavigator());
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, String>> classifyPreview(
    Map<String, dynamic> payload,
  ) async {
    try {
      return Right(await _remote.classifyPreview(payload));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMonitoringProfile(
    VitalsCaptureKind kind,
  ) async {
    try {
      return Right(await _remote.getMonitoringProfile(kind));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> setMonitoringProfile(
    VitalsCaptureKind kind,
    Map<String, dynamic> payload,
  ) async {
    try {
      return Right(await _remote.setMonitoringProfile(kind, payload));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, VitalsCaptureResult>> addSecondReading(
    String sessionId,
    Map<String, dynamic> payload,
  ) async {
    try {
      return Right(await _remote.addSecondReading(sessionId, payload));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, VitalsCaptureResult>> addWellbeing(
    String sessionId,
    bool answer,
  ) async {
    try {
      return Right(await _remote.addWellbeing(sessionId, answer));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<
    Either<
      Failure,
      ({
        List<Map<String, dynamic>> candidates,
        List<String> requiredServices,
        String? reason,
      })
    >
  >
  facilityCandidates(
    VitalsCaptureKind kind,
    String readingId, {
    double? userLat,
    double? userLng,
  }) async {
    try {
      return Right(
        await _remote.facilityCandidates(
          kind,
          readingId,
          userLat: userLat,
          userLng: userLng,
        ),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Referral>> createReferralFromReading(
    VitalsCaptureKind kind,
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  }) async {
    try {
      return Right(
        await _remote.createReferralFromReading(
          kind,
          readingId,
          userLat: userLat,
          userLng: userLng,
          facilityId: facilityId,
        ),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<
    Either<Failure, ({List<int> bytes, Map<String, List<String>> headers})>
  >
  downloadReport(String reportType) async {
    try {
      final res = await _remote.downloadReport(reportType);
      return Right((bytes: res.bytes, headers: res.headers));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, String?>> reportEmailPrefill() async {
    try {
      return Right(await _remote.reportEmailPrefill());
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> emailReport(
    String email,
    String reportType,
  ) async {
    try {
      await _remote.emailReport(email, reportType);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  Failure _map(Exception e) {
    if (e is UnauthorizedException) return const UnauthorizedFailure();
    if (e is PaymentRequiredException) {
      return ValidationFailure(error: e.code);
    }
    if (e is ValidationException) return ValidationFailure(error: e.message);
    if (e is NotFoundException) return NotFoundFailure(error: e.message);
    if (e is NetworkException) return const NetworkFailure();
    if (e is ServerException) return const ServerFailure();
    return GeneralFailure(error: e.toString());
  }
}
