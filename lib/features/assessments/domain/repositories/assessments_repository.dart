import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_answer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/domain/entities/bmi_preview.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/domain/entities/vitals_access.dart';

class CanStartResult {
  final bool allowed;
  final String? lastCompletedAt;
  final String? nextEligibleAt;
  final String? blockedReason;
  final String? priorSlug;
  final String? priorTitle;

  const CanStartResult({
    required this.allowed,
    this.lastCompletedAt,
    this.nextEligibleAt,
    this.blockedReason,
    this.priorSlug,
    this.priorTitle,
  });

  bool get isChapterLocked => blockedReason == 'chapter_not_unlocked';
  bool get isCancerBlocked => blockedReason == 'cancer_diagnosed_blocked';
  bool get isAgeIneligible => blockedReason == 'age_ineligible';
  bool get isGenderIneligible => blockedReason == 'gender_ineligible';
  bool get isEbolaAccessRequired => blockedReason == 'ebola_access_required';
  bool get isPaused => blockedReason == 'assessment_paused';
  bool get isCooldown => blockedReason == null && !allowed;
}

class SubmitAnswerResult {
  final int nextIndex;
  final bool terminate;
  final bool completed;
  final String? reference;
  const SubmitAnswerResult({
    required this.nextIndex,
    required this.terminate,
    required this.completed,
    this.reference,
  });
}

abstract class AssessmentsRepository {
  Future<Either<Failure, VitalsAccess>> getVitalsAccess();
  Future<Either<Failure, List<AssessmentSummary>>> listAssessments();
  Future<Either<Failure, CanStartResult>> canStart(String slug);
  Future<Either<Failure, AssessmentDefinition>> getDefinition(String slug);
  Future<Either<Failure, AssessmentSession>> startSession(String slug);
  Future<Either<Failure, AssessmentSession>> submitCancerPreScreening(
    String slug,
    String sessionId, {
    required String priorCancerHistory,
    required String priorCancerType,
    int? priorCancerYear,
  });
  Future<Either<Failure, List<AssessmentAnswer>>> getAnswers(
    String slug,
    String sessionId,
  );
  Future<Either<Failure, SubmitAnswerResult>> submitAnswer(
    String slug,
    String sessionId, {
    required String questionKey,
    required int questionIndex,
    required String answer,
  });
  Future<Either<Failure, AssessmentScore>> getScore(
    String slug,
    String sessionId,
  );
  Future<Either<Failure, BmiPreview>> previewBmi({
    required String weightKg,
    required String heightCm,
  });
  Future<Either<Failure, void>> submitBmiMetrics(
    String slug,
    String sessionId, {
    required double weightKg,
    required double heightCm,
  });
  Future<Either<Failure, Referral?>> getReferralForSession(String sessionId);
  Future<Either<Failure, DownloadedReport>> downloadReport(
    String slug,
    String sessionId,
  );
  Future<Either<Failure, String?>> getReportEmailPrefill(
    String slug,
    String sessionId,
  );
  Future<Either<Failure, void>> emailReport(
    String slug,
    String sessionId,
    String email,
  );
}

class DownloadedReport {
  final List<int> bytes;
  final String? filename;
  final String? passwordHint;

  const DownloadedReport({
    required this.bytes,
    this.filename,
    this.passwordHint,
  });
}
