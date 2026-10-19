import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_content.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_result.dart';
import 'package:my_wellness/features/vitals/domain/repositories/vitals_capture_repository.dart';

@lazySingleton
class GetVitalsCaptureContentUseCase
    implements UseCase<VitalsCaptureContent, VitalsCaptureKind> {
  final VitalsCaptureRepository _r;
  GetVitalsCaptureContentUseCase(this._r);
  @override
  Future<Either<Failure, VitalsCaptureContent>> call(VitalsCaptureKind k) =>
      _r.getContent(k);
}

@lazySingleton
class CreateVitalsSessionUseCase
    implements
        UseCase<
          VitalsCaptureResult,
          ({VitalsCaptureKind kind, Map<String, dynamic> payload})
        > {
  final VitalsCaptureRepository _r;
  CreateVitalsSessionUseCase(this._r);
  @override
  Future<Either<Failure, VitalsCaptureResult>> call(
    ({VitalsCaptureKind kind, Map<String, dynamic> payload}) p,
  ) => _r.createSession(p.kind, p.payload);
}

@lazySingleton
class GetVitalsReferralUseCase
    implements
        UseCase<Referral?, ({VitalsCaptureKind kind, String readingId})> {
  final VitalsCaptureRepository _r;
  GetVitalsReferralUseCase(this._r);
  @override
  Future<Either<Failure, Referral?>> call(
    ({VitalsCaptureKind kind, String readingId}) p,
  ) => _r.getReferralFromReading(p.kind, p.readingId);
}
