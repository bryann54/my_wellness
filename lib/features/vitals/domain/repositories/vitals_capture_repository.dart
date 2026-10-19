import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_content.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_capture_result.dart';

abstract class VitalsCaptureRepository {
  Future<Either<Failure, VitalsCaptureContent>> getContent(
    VitalsCaptureKind kind,
  );
  Future<Either<Failure, VitalsCaptureResult>> createSession(
    VitalsCaptureKind kind,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, Referral?>> getReferralFromReading(
    VitalsCaptureKind kind,
    String readingId,
  );
}
