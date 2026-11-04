import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_access.dart';
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

  Future<Either<Failure, VitalsAccess>> getAccess();
  Future<Either<Failure, VitalsAccess>> alertNavigator();

  Future<Either<Failure, String>> classifyPreview(Map<String, dynamic> payload);

  Future<Either<Failure, Map<String, dynamic>>> getMonitoringProfile(
    VitalsCaptureKind kind,
  );
  Future<Either<Failure, Map<String, dynamic>>> setMonitoringProfile(
    VitalsCaptureKind kind,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, VitalsCaptureResult>> addSecondReading(
    String sessionId,
    Map<String, dynamic> payload,
  );
  Future<Either<Failure, VitalsCaptureResult>> addWellbeing(
    String sessionId,
    bool answer,
  );

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
  });

  Future<Either<Failure, Referral>> createReferralFromReading(
    VitalsCaptureKind kind,
    String readingId, {
    double? userLat,
    double? userLng,
    String? facilityId,
  });

  Future<
    Either<Failure, ({List<int> bytes, Map<String, List<String>> headers})>
  >
  downloadReport(String reportType);
  Future<Either<Failure, String?>> reportEmailPrefill();
  Future<Either<Failure, void>> emailReport(String email, String reportType);
}
