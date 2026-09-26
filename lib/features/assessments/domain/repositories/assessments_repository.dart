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
  const CanStartResult({
    required this.allowed,
    this.lastCompletedAt,
    this.nextEligibleAt,
  });
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
  Future<Either<Failure, bool>> submitBmiMetrics(
    String slug,
    String sessionId, {
    required String weightKg,
    required String heightCm,
  });
  Future<Either<Failure, AssessmentScore>> getScore(
    String slug,
    String sessionId,
  );
  Future<Either<Failure, BmiPreview>> previewBmi({
    required String weightKg,
    required String heightCm,
  });

  /// Optional — returns null if the backend has no referral for this session.
  Future<Either<Failure, Referral?>> getReferralForSession(String sessionId);
}
