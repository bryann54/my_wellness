import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_answer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/domain/entities/bmi_preview.dart';
import 'package:my_wellness/features/assessments/domain/entities/vitals_access.dart';
import 'package:my_wellness/features/assessments/domain/repositories/assessments_repository.dart';

@lazySingleton
class GetVitalsAccessUseCase implements UseCase<VitalsAccess, NoParams> {
  final AssessmentsRepository _r;
  GetVitalsAccessUseCase(this._r);
  @override
  Future<Either<Failure, VitalsAccess>> call(NoParams _) =>
      _r.getVitalsAccess();
}

@lazySingleton
class ListAssessmentsUseCase
    implements UseCase<List<AssessmentSummary>, NoParams> {
  final AssessmentsRepository _r;
  ListAssessmentsUseCase(this._r);
  @override
  Future<Either<Failure, List<AssessmentSummary>>> call(NoParams _) =>
      _r.listAssessments();
}

@lazySingleton
class CanStartAssessmentUseCase implements UseCase<CanStartResult, String> {
  final AssessmentsRepository _r;
  CanStartAssessmentUseCase(this._r);
  @override
  Future<Either<Failure, CanStartResult>> call(String slug) =>
      _r.canStart(slug);
}

@lazySingleton
class GetAssessmentDefinitionUseCase
    implements UseCase<AssessmentDefinition, String> {
  final AssessmentsRepository _r;
  GetAssessmentDefinitionUseCase(this._r);
  @override
  Future<Either<Failure, AssessmentDefinition>> call(String slug) =>
      _r.getDefinition(slug);
}

@lazySingleton
class StartAssessmentSessionUseCase
    implements UseCase<AssessmentSession, String> {
  final AssessmentsRepository _r;
  StartAssessmentSessionUseCase(this._r);
  @override
  Future<Either<Failure, AssessmentSession>> call(String slug) =>
      _r.startSession(slug);
}

@lazySingleton
class GetAssessmentAnswersUseCase
    implements
        UseCase<List<AssessmentAnswer>, ({String slug, String sessionId})> {
  final AssessmentsRepository _r;
  GetAssessmentAnswersUseCase(this._r);
  @override
  Future<Either<Failure, List<AssessmentAnswer>>> call(
    ({String slug, String sessionId}) p,
  ) => _r.getAnswers(p.slug, p.sessionId);
}

@lazySingleton
class SubmitAssessmentAnswerUseCase
    implements
        UseCase<
          SubmitAnswerResult,
          ({
            String slug,
            String sessionId,
            String questionKey,
            int questionIndex,
            String answer,
          })
        > {
  final AssessmentsRepository _r;
  SubmitAssessmentAnswerUseCase(this._r);
  @override
  Future<Either<Failure, SubmitAnswerResult>> call(
    ({
      String slug,
      String sessionId,
      String questionKey,
      int questionIndex,
      String answer,
    })
    p,
  ) => _r.submitAnswer(
    p.slug,
    p.sessionId,
    questionKey: p.questionKey,
    questionIndex: p.questionIndex,
    answer: p.answer,
  );
}

@lazySingleton
class SubmitAssessmentBmiUseCase
    implements
        UseCase<
          bool,
          ({String slug, String sessionId, String weightKg, String heightCm})
        > {
  final AssessmentsRepository _r;
  SubmitAssessmentBmiUseCase(this._r);
  @override
  Future<Either<Failure, bool>> call(
    ({String slug, String sessionId, String weightKg, String heightCm}) p,
  ) => _r.submitBmiMetrics(
    p.slug,
    p.sessionId,
    weightKg: p.weightKg,
    heightCm: p.heightCm,
  );
}

@lazySingleton
class GetAssessmentScoreUseCase
    implements UseCase<AssessmentScore, ({String slug, String sessionId})> {
  final AssessmentsRepository _r;
  GetAssessmentScoreUseCase(this._r);
  @override
  Future<Either<Failure, AssessmentScore>> call(
    ({String slug, String sessionId}) p,
  ) => _r.getScore(p.slug, p.sessionId);
}

@lazySingleton
class PreviewBmiUseCase
    implements UseCase<BmiPreview, ({String weightKg, String heightCm})> {
  final AssessmentsRepository _r;
  PreviewBmiUseCase(this._r);
  @override
  Future<Either<Failure, BmiPreview>> call(
    ({String weightKg, String heightCm}) p,
  ) => _r.previewBmi(weightKg: p.weightKg, heightCm: p.heightCm);
}
