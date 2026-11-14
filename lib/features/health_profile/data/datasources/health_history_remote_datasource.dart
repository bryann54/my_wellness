import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';

abstract class HealthHistoryRemoteDataSource {
  Future<({Map<String, dynamic> clinical, List<dynamic> journey})> load();
}

@LazySingleton(as: HealthHistoryRemoteDataSource)
class HealthHistoryRemoteDataSourceImpl
    implements HealthHistoryRemoteDataSource {
  const HealthHistoryRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({Map<String, dynamic> clinical, List<dynamic> journey})>
  load() async {
    final responses = await Future.wait<dynamic>([
      _apiClient.get<Map<String, dynamic>>(
        url: ApiEndpoints.clinicalMedicalHistory,
        options: ApiClient.protected,
      ),
      _apiClient.get<List<dynamic>>(
        url: ApiEndpoints.healthJourney,
        options: ApiClient.protected,
      ),
    ]);
    return (
      clinical: responses[0] as Map<String, dynamic>,
      journey: responses[1] as List<dynamic>,
    );
  }
}
