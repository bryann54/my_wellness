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
}
