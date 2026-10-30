import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';
import 'package:my_wellness/features/offline_sync/data/local/app_database.dart';

abstract class HomeDashboardRemoteDataSource {
  bool get lastLoadWasFromCache;
  Future<List<DashboardSession>> loadRelevantSessions();
}

@LazySingleton(as: HomeDashboardRemoteDataSource)
class HomeDashboardRemoteDataSourceImpl
    implements HomeDashboardRemoteDataSource {
  HomeDashboardRemoteDataSourceImpl(this._apiClient, this._database);

  final ApiClient _apiClient;
  final AppDatabase _database;
  @override
  bool lastLoadWasFromCache = false;

  @override
  Future<List<DashboardSession>> loadRelevantSessions() async {
    late final Map<String, dynamic> response;
    try {
      lastLoadWasFromCache = false;
      response = await _apiClient.get<Map<String, dynamic>>(
        url: ApiEndpoints.dashboard,
        options: ApiClient.protected,
      );
      await _database.cachePayload('dashboard', jsonEncode(response));
      await _precacheActiveAssessmentData(response);
    } on NetworkException {
      final cached = await _database.getCachedPayload('dashboard');
      if (cached == null) rethrow;
      response = jsonDecode(cached) as Map<String, dynamic>;
      lastLoadWasFromCache = true;
    }
    final assessments = response['assessments'];
    if (assessments is! List) {
      throw const FormatException('Dashboard assessments are missing');
    }

    return assessments
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final status = AssessmentSession.parseStatus(
            item['status']?.toString() ?? '',
          );
          if (status == AssessmentSessionStatus.inProgress) {
            return (item: item, status: DashboardSessionStatus.inProgress);
          }
          if (status == AssessmentSessionStatus.awaitingPayment) {
            return (item: item, status: DashboardSessionStatus.pending);
          }
          return null;
        })
        .whereType<
          ({Map<String, dynamic> item, DashboardSessionStatus status})
        >()
        .map((item) {
          final data = item.item;
          final id = data['id'];
          final slug = data['assessment_slug'];
          final currentIndex = data['current_index'];
          final totalQuestions = data['total_questions'];
          final progress = data['completion_pct'];
          if (id == null || slug is! String || slug.isEmpty) {
            return null;
          }
          final isInProgress = item.status == DashboardSessionStatus.inProgress;
          final hasResumablePosition =
              currentIndex is num &&
              totalQuestions is num &&
              totalQuestions > 0 &&
              currentIndex >= 0 &&
              currentIndex < totalQuestions;
          if (isInProgress && (!hasResumablePosition || progress is! num)) {
            return null;
          }
          return DashboardSession(
            id: id.toString(),
            assessmentSlug: slug,
            currentIndex: hasResumablePosition ? currentIndex.toInt() : 0,
            totalQuestions: totalQuestions is num && totalQuestions > 0
                ? totalQuestions.toInt()
                : 1,
            completionPercent: progress is num
                ? progress.round().clamp(0, 100).toInt()
                : 0,
            status: item.status,
          );
        })
        .whereType<DashboardSession>()
        .toList(growable: false);
  }

  Future<void> _precacheActiveAssessmentData(
    Map<String, dynamic> response,
  ) async {
    final rawSessions = response['assessments'];
    if (rawSessions is! List) return;

    final sessions = rawSessions.whereType<Map<String, dynamic>>().where((
      item,
    ) {
      return AssessmentSession.parseStatus(item['status']?.toString() ?? '') ==
              AssessmentSessionStatus.inProgress &&
          item['id'] != null &&
          item['assessment_slug'] is String;
    });

    final sessionList = sessions.toList(growable: false);
    for (var i = 0; i < sessionList.length; i += 3) {
      final batch = sessionList.skip(i).take(3);
      await Future.wait(
        batch.map((session) async {
          final slug = session['assessment_slug'] as String;
          final sessionId = session['id'].toString();
          await Future.wait([
            () async {
              try {
                final definition = await _apiClient.get<Map<String, dynamic>>(
                  url: ApiEndpoints.assessmentOffline(slug),
                  options: ApiClient.protected,
                );
                await _database.cacheAssessment(slug, jsonEncode(definition));
              } on Exception {
                // Keep the dashboard available if an assessment cannot be warmed.
              }
            }(),
            () async {
              try {
                final answers = await _apiClient.get<List<dynamic>>(
                  url: ApiEndpoints.assessmentAnswers(slug, sessionId),
                  options: ApiClient.protected,
                );
                await _database.cachePayload(
                  AppDatabase.assessmentAnswersCacheKey(slug, sessionId),
                  jsonEncode(answers),
                );
              } on Exception {
                // Keep the dashboard available if answers cannot be warmed.
              }
            }(),
          ]);
        }),
      );
    }
  }
}
