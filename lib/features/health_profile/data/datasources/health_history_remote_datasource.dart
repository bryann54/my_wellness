import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';

abstract class HealthHistoryRemoteDataSource {
  Future<Map<String, dynamic>> load();
}

@LazySingleton(as: HealthHistoryRemoteDataSource)
class HealthHistoryRemoteDataSourceImpl
    implements HealthHistoryRemoteDataSource {
  const HealthHistoryRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> load() => _apiClient.get<Map<String, dynamic>>(
    url: ApiEndpoints.clinicalMedicalHistory,
    options: ApiClient.protected,
  );
}
