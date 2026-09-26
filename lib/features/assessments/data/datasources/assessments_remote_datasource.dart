import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/features/assessments/data/models/assessment_answer_model.dart';
import 'package:my_wellness/features/assessments/data/models/assessment_definition_model.dart';
import 'package:my_wellness/features/assessments/data/models/assessment_score_model.dart';
import 'package:my_wellness/features/assessments/data/models/assessment_session_model.dart';
import 'package:my_wellness/features/assessments/data/models/assessment_summary_model.dart';
import 'package:my_wellness/features/assessments/data/models/bmi_preview_model.dart';
import 'package:my_wellness/features/assessments/data/models/referral_model.dart';
import 'package:my_wellness/features/assessments/data/models/vitals_access_model.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_answer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/domain/entities/bmi_preview.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/domain/entities/vitals_access.dart';
import 'package:my_wellness/features/assessments/domain/repositories/assessments_repository.dart';

abstract class AssessmentsRemoteDataSource {
  Future<VitalsAccess> getVitalsAccess();
  Future<List<AssessmentSummary>> listAssessments();
  Future<CanStartResult> canStart(String slug);
  Future<AssessmentDefinition> getDefinition(String slug);
  Future<AssessmentSession> startSession(String slug);
  Future<List<AssessmentAnswer>> getAnswers(String slug, String sessionId);
  Future<Referral?> getReferralForSession(String sessionId);
  Future<SubmitAnswerResult> submitAnswer(
    String slug,
    String sessionId, {
    required String questionKey,
    required int questionIndex,
    required String answer,
  });
  Future<bool> submitBmiMetrics(
    String slug,
    String sessionId, {
    required String weightKg,
    required String heightCm,
  });
  Future<AssessmentScore> getScore(String slug, String sessionId);
  Future<BmiPreview> previewBmi({
    required String weightKg,
    required String heightCm,
  });
}

@LazySingleton(as: AssessmentsRemoteDataSource)
class AssessmentsRemoteDataSourceImpl implements AssessmentsRemoteDataSource {
  final ApiClient _api;
  AssessmentsRemoteDataSourceImpl(this._api);

  @override
  Future<VitalsAccess> getVitalsAccess() async {
    final res = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.vitalsAccess,
      options: ApiClient.protected,
    );
    return VitalsAccessModel.fromJson(res).toEntity();
  }
  @override
  Future<Referral?> getReferralForSession(String sessionId) async {
    try {
      final res = await _api.get<Map<String, dynamic>>(
        url: ApiEndpoints.referralFromSession(sessionId),
        options: ApiClient.protected,
      );
      return ReferralModel.fromJson(res).toEntity();
    } on NotFoundException {
      return null;
    } on ValidationException {
      return null;
    }
  }
  @override
  Future<List<AssessmentSummary>> listAssessments() async {
    final res = await _api.get<List<dynamic>>(
      url: ApiEndpoints.assessments,
      options: ApiClient.protected,
    );
    return res
        .map(
          (e) => AssessmentSummaryModel.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList(growable: false);
  }

  @override
  Future<CanStartResult> canStart(String slug) async {
    final res = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.assessmentCanStart(slug),
      options: ApiClient.protected,
    );
    return CanStartResult(
      allowed: res['allowed'] as bool? ?? false,
      lastCompletedAt: res['last_completed_at'] as String?,
      nextEligibleAt: res['next_eligible_at'] as String?,
    );
  }

  @override
  Future<AssessmentDefinition> getDefinition(String slug) async {
    final res = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.assessmentDetail(slug),
      options: ApiClient.protected,
    );
    return AssessmentDefinitionModel.fromJson(res).toEntity();
  }

  @override
  Future<AssessmentSession> startSession(String slug) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.assessmentStartSession(slug),
      payload: const {},
      options: ApiClient.protected,
    );
    return AssessmentSessionModel.fromJson(res).toEntity();
  }

  @override
  Future<List<AssessmentAnswer>> getAnswers(
    String slug,
    String sessionId,
  ) async {
    final res = await _api.get<List<dynamic>>(
      url: ApiEndpoints.assessmentAnswers(slug, sessionId),
      options: ApiClient.protected,
    );
    return res
        .map(
          (e) => AssessmentAnswerModel.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList(growable: false);
  }

  @override
  Future<SubmitAnswerResult> submitAnswer(
    String slug,
    String sessionId, {
    required String questionKey,
    required int questionIndex,
    required String answer,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.assessmentAnswers(slug, sessionId),
      payload: {
        'question_key': questionKey,
        'question_index': questionIndex,
        'answer': answer,
      },
      options: ApiClient.protected,
    );
    return SubmitAnswerResult(
      nextIndex: res['next_index'] as int? ?? questionIndex + 1,
      terminate: res['terminate'] as bool? ?? false,
      completed: res['completed'] as bool? ?? false,
      reference: res['reference'] as String?,
    );
  }

  @override
  Future<bool> submitBmiMetrics(
    String slug,
    String sessionId, {
    required String weightKg,
    required String heightCm,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.assessmentBmiMetrics(slug, sessionId),
      payload: {'weight_kg': weightKg, 'height_cm': heightCm},
      options: ApiClient.protected,
    );
    return res['ok'] as bool? ?? false;
  }

  @override
  Future<AssessmentScore> getScore(String slug, String sessionId) async {
    final res = await _api.get<Map<String, dynamic>>(
      url: ApiEndpoints.assessmentScore(slug, sessionId),
      options: ApiClient.protected,
    );
    return AssessmentScoreModel.fromJson(res).toEntity();
  }

  @override
  Future<BmiPreview> previewBmi({
    required String weightKg,
    required String heightCm,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.vitalsClassifyPreview,
      payload: {'weight_kg': weightKg, 'height_cm': heightCm},
      options: ApiClient.protected,
    );
    return BmiPreviewModel.fromJson(res).toEntity();
  }
}
