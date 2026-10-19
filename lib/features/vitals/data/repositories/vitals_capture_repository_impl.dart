import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
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

  Failure _map(Exception e) {
    if (e is UnauthorizedException) return const UnauthorizedFailure();
    if (e is ValidationException) return ValidationFailure(error: e.message);
    if (e is NotFoundException) return NotFoundFailure(error: e.message);
    if (e is NetworkException) return const NetworkFailure();
    if (e is ServerException) return const ServerFailure();
    return GeneralFailure(error: e.toString());
  }
}
