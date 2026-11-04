import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_access.dart';
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

@lazySingleton
class GetVitalsAccessUseCase implements UseCase<VitalsAccess, NoParams> {
  final VitalsCaptureRepository _r;
  GetVitalsAccessUseCase(this._r);
  @override
  Future<Either<Failure, VitalsAccess>> call(NoParams p) => _r.getAccess();
}

@lazySingleton
class AlertVitalsNavigatorUseCase implements UseCase<VitalsAccess, NoParams> {
  final VitalsCaptureRepository _r;
  AlertVitalsNavigatorUseCase(this._r);
  @override
  Future<Either<Failure, VitalsAccess>> call(NoParams p) => _r.alertNavigator();
}

@lazySingleton
class ClassifyVitalsPreviewUseCase
    implements UseCase<String, Map<String, dynamic>> {
  final VitalsCaptureRepository _r;
  ClassifyVitalsPreviewUseCase(this._r);
  @override
  Future<Either<Failure, String>> call(Map<String, dynamic> p) =>
      _r.classifyPreview(p);
}

@lazySingleton
class GetMonitoringProfileUseCase
    implements UseCase<Map<String, dynamic>, VitalsCaptureKind> {
  final VitalsCaptureRepository _r;
  GetMonitoringProfileUseCase(this._r);
  @override
  Future<Either<Failure, Map<String, dynamic>>> call(VitalsCaptureKind k) =>
      _r.getMonitoringProfile(k);
}

@lazySingleton
class SetMonitoringProfileUseCase
    implements
        UseCase<
          Map<String, dynamic>,
          ({VitalsCaptureKind kind, Map<String, dynamic> payload})
        > {
  final VitalsCaptureRepository _r;
  SetMonitoringProfileUseCase(this._r);
  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    ({VitalsCaptureKind kind, Map<String, dynamic> payload}) p,
  ) => _r.setMonitoringProfile(p.kind, p.payload);
}

@lazySingleton
class AddVitalsSecondReadingUseCase
    implements
        UseCase<
          VitalsCaptureResult,
          ({String sessionId, Map<String, dynamic> payload})
        > {
  final VitalsCaptureRepository _r;
  AddVitalsSecondReadingUseCase(this._r);
  @override
  Future<Either<Failure, VitalsCaptureResult>> call(
    ({String sessionId, Map<String, dynamic> payload}) p,
  ) => _r.addSecondReading(p.sessionId, p.payload);
}

@lazySingleton
class AddVitalsWellbeingUseCase
    implements UseCase<VitalsCaptureResult, ({String sessionId, bool answer})> {
  final VitalsCaptureRepository _r;
  AddVitalsWellbeingUseCase(this._r);
  @override
  Future<Either<Failure, VitalsCaptureResult>> call(
    ({String sessionId, bool answer}) p,
  ) => _r.addWellbeing(p.sessionId, p.answer);
}

@lazySingleton
class GetReferralFacilityCandidatesUseCase
    implements
        UseCase<
          ({
            List<Map<String, dynamic>> candidates,
            List<String> requiredServices,
            String? reason,
          }),
          ({
            VitalsCaptureKind kind,
            String readingId,
            double? userLat,
            double? userLng,
          })
        > {
  final VitalsCaptureRepository _r;
  GetReferralFacilityCandidatesUseCase(this._r);
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
  call(
    ({
      VitalsCaptureKind kind,
      String readingId,
      double? userLat,
      double? userLng,
    })
    p,
  ) => _r.facilityCandidates(
    p.kind,
    p.readingId,
    userLat: p.userLat,
    userLng: p.userLng,
  );
}

@lazySingleton
class CreateReferralFromReadingUseCase
    implements
        UseCase<
          Referral,
          ({
            VitalsCaptureKind kind,
            String readingId,
            double? userLat,
            double? userLng,
            String? facilityId,
          })
        > {
  final VitalsCaptureRepository _r;
  CreateReferralFromReadingUseCase(this._r);
  @override
  Future<Either<Failure, Referral>> call(
    ({
      VitalsCaptureKind kind,
      String readingId,
      double? userLat,
      double? userLng,
      String? facilityId,
    })
    p,
  ) => _r.createReferralFromReading(
    p.kind,
    p.readingId,
    userLat: p.userLat,
    userLng: p.userLng,
    facilityId: p.facilityId,
  );
}

@lazySingleton
class DownloadVitalsReportUseCase
    implements
        UseCase<
          ({List<int> bytes, Map<String, List<String>> headers}),
          String
        > {
  final VitalsCaptureRepository _r;
  DownloadVitalsReportUseCase(this._r);
  @override
  Future<
    Either<Failure, ({List<int> bytes, Map<String, List<String>> headers})>
  >
  call(String reportType) => _r.downloadReport(reportType);
}

@lazySingleton
class GetVitalsReportEmailPrefillUseCase implements UseCase<String?, NoParams> {
  final VitalsCaptureRepository _r;
  GetVitalsReportEmailPrefillUseCase(this._r);
  @override
  Future<Either<Failure, String?>> call(NoParams p) => _r.reportEmailPrefill();
}

@lazySingleton
class EmailVitalsReportUseCase
    implements UseCase<void, ({String email, String reportType})> {
  final VitalsCaptureRepository _r;
  EmailVitalsReportUseCase(this._r);
  @override
  Future<Either<Failure, void>> call(({String email, String reportType}) p) =>
      _r.emailReport(p.email, p.reportType);
}
