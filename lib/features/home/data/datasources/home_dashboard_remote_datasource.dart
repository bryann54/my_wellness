import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';

abstract class HomeDashboardRemoteDataSource {
  bool get lastLoadWasFromCache;
  Future<List<DashboardSession>> loadRelevantSessions();
}

@LazySingleton(as: HomeDashboardRemoteDataSource)
class HomeDashboardRemoteDataSourceImpl
    implements HomeDashboardRemoteDataSource {
  HomeDashboardRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;
  @override
  bool lastLoadWasFromCache = false;

  @override
  Future<List<DashboardSession>> loadRelevantSessions() async {
    lastLoadWasFromCache = false;
    final response = await _apiClient.get<List<dynamic>>(
      url: ApiEndpoints.assessmentHealthChecks,
      options: ApiClient.protected,
    );
    return parseDashboardHealthChecks(response);
  }
}

List<DashboardSession> parseDashboardHealthChecks(List<dynamic> response) {
  return response
      .whereType<Map<String, dynamic>>()
      .map((data) {
        final id = data['id'];
        final slug = data['assessment_slug'];
        final name = data['name'];
        final progress = data['progress'];
        final status = switch (data['status']?.toString()) {
          'not_started' => DashboardSessionStatus.notStarted,
          'in_progress' => DashboardSessionStatus.inProgress,
          'awaiting_call' => DashboardSessionStatus.pending,
          'completed' => DashboardSessionStatus.completed,
          _ => null,
        };
        if (id == null ||
            slug is! String ||
            slug.isEmpty ||
            name is! String ||
            name.isEmpty ||
            progress is! num ||
            status == null) {
          return null;
        }

        final sessionId = data['session_id']?.toString();
        if (status == DashboardSessionStatus.inProgress &&
            (sessionId == null || sessionId.isEmpty)) {
          return null;
        }

        final percent = progress.round().clamp(0, 100).toInt();
        return DashboardSession(
          id: id.toString(),
          sessionId: sessionId,
          assessmentSlug: slug,
          title: name,
          family: data['family']?.toString() ?? '',
          currentIndex: percent,
          totalQuestions: 100,
          completionPercent: percent,
          status: status,
        );
      })
      .whereType<DashboardSession>()
      .toList(growable: false);
}
