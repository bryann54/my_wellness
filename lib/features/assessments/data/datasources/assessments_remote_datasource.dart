import 'dart:convert';
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
import 'package:my_wellness/features/offline_sync/data/local/app_database.dart';

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
  Future<AssessmentScore> getScore(String slug, String sessionId);
  Future<BmiPreview> previewBmi({
    required String weightKg,
    required String heightCm,
  });
}

@LazySingleton(as: AssessmentsRemoteDataSource)
class AssessmentsRemoteDataSourceImpl implements AssessmentsRemoteDataSource {
  final ApiClient _api;
  final AppDatabase _database;
  AssessmentsRemoteDataSourceImpl(this._api, this._database);

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
    late final List<dynamic> res;
    try {
      res = await _api.get<List<dynamic>>(
        url: ApiEndpoints.assessments,
        options: ApiClient.protected,
      );
      await _database.cachePayload('assessment_list', jsonEncode(res));
      await _precacheOfflineDefinitions(res);
    } on NetworkException {
      final cached = await _database.getCachedPayload('assessment_list');
      if (cached == null) rethrow;
      res = jsonDecode(cached) as List<dynamic>;
    }
    return res
        .map(
          (e) => AssessmentSummaryModel.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList(growable: false);
  }

  Future<void> _precacheOfflineDefinitions(List<dynamic> summaries) async {
    final slugs = summaries
        .whereType<Map<String, dynamic>>()
        .map((summary) => summary['slug'])
        .whereType<String>()
        .where((slug) => slug.isNotEmpty)
        .toList(growable: false);

    for (var i = 0; i < slugs.length; i += 3) {
      final batch = slugs.skip(i).take(3);
      await Future.wait(
        batch.map((slug) async {
          try {
            final definition = await _api.get<Map<String, dynamic>>(
              url: ApiEndpoints.assessmentOffline(slug),
              options: ApiClient.protected,
            );
            await _database.cacheAssessment(slug, jsonEncode(definition));
          } on Exception {
            // A partial catalog warm-up must not block the online catalog.
          }
        }),
      );
    }
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
    late final Map<String, dynamic> res;
    var loadedRemotely = false;
    try {
      res = await _api.get<Map<String, dynamic>>(
        url: ApiEndpoints.assessmentDetail(slug),
        options: ApiClient.protected,
      );
      loadedRemotely = true;
      await _database.cacheAssessment(slug, jsonEncode(res));
    } on NetworkException {
      final cached = await _database.getCachedAssessment(slug);
      if (cached == null) rethrow;
      res = jsonDecode(cached) as Map<String, dynamic>;
    }

    // Preserve the regular online response above. The offline endpoint adds
    // navigation rules needed by an offline session, so cache its richer
    // catalog separately as the latest definition payload when available.
    if (loadedRemotely) {
      try {
        final offlineDefinition = await _api.get<Map<String, dynamic>>(
          url: ApiEndpoints.assessmentOffline(slug),
          options: ApiClient.protected,
        );
        await _database.cacheAssessment(slug, jsonEncode(offlineDefinition));
      } on Exception {
        // The normal assessment endpoint remains authoritative for online use.
      }
    }
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
    late final List<dynamic> res;
    final cacheKey = AppDatabase.assessmentAnswersCacheKey(slug, sessionId);
    try {
      res = await _api.get<List<dynamic>>(
        url: ApiEndpoints.assessmentAnswers(slug, sessionId),
        options: ApiClient.protected,
      );
      await _database.cachePayload(cacheKey, jsonEncode(res));
    } on NetworkException {
      final cached = await _database.getCachedPayload(cacheKey);
      if (cached == null) rethrow;
      res = jsonDecode(cached) as List<dynamic>;
    }

    final answersByIndex = <int, Map<String, dynamic>>{
      for (final item in res.whereType<Map<String, dynamic>>())
        if (item['question_index'] is int) item['question_index'] as int: item,
    };
    final endpoint = ApiEndpoints.assessmentOfflineBatch(slug, sessionId);
    try {
      final pendingActions = await _database.getPendingActions();
      for (final action in pendingActions) {
        if (action.actionType != 'assessment_answer' ||
            action.endpoint != endpoint ||
            action.method != 'POST') {
          continue;
        }
        final payload = jsonDecode(action.payload) as Map<String, dynamic>;
        final queuedAnswers = payload['answers'];
        if (queuedAnswers is! List) continue;
        for (final queued in queuedAnswers.whereType<Map>()) {
          final answer = Map<String, dynamic>.from(queued);
          final index = answer['question_index'];
          if (index is! int || answer['answer'] == null) continue;
          answersByIndex[index] = {
            'question_key': answer['question_key']?.toString() ?? '',
            'question_index': index,
            'answer': answer['answer'].toString(),
          };
        }
      }
    } on Exception {
      // Cached/server answers remain usable if the pending queue cannot be read.
    }

    return answersByIndex.values
        .map((e) => AssessmentAnswerModel.fromJson(e).toEntity())
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
