import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/pricing/data/models/pricing_package_model.dart';

abstract class PricingRemoteDataSource {
  Future<List<PricingPackageModel>> getPackages();
}

@LazySingleton(as: PricingRemoteDataSource)
class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final ApiClient _apiClient;

  PricingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PricingPackageModel>> getPackages() async {
    final response = await _apiClient.get<List<dynamic>>(
      url: ApiEndpoints.paymentsPackages,
      options: ApiClient.protected,
    );

    return response
        .whereType<Map<String, dynamic>>()
        .map(PricingPackageModel.fromJson)
        .toList(growable: false);
  }
}
