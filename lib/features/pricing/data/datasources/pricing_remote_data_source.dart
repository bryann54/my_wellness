import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/pricing/data/models/pricing_package_model.dart';
import 'package:my_wellness/features/pricing/data/models/pricing_catalog_model.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';

abstract class PricingRemoteDataSource {
  Future<List<PricingPackageModel>> getPackages();
  Future<PricingCatalogModel> getServiceCatalog();
  Future<PricingQuoteModel> quote(Map<String, dynamic> selection);
  Future<PricingPayment> checkout({
    required Map<String, dynamic> selection,
    required String phone,
  });
}

@LazySingleton(as: PricingRemoteDataSource)
class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final ApiClient _apiClient;

  PricingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PricingPackageModel>> getPackages() async {
    final response = await _apiClient.get<List<dynamic>>(
      url: ApiEndpoints.paymentsPackages,
      options: ApiClient.open,
    );

    return response
        .whereType<Map<String, dynamic>>()
        .map(PricingPackageModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<PricingCatalogModel> getServiceCatalog() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.paymentsServiceCatalog,
      options: ApiClient.open,
    );
    return PricingCatalogModel.fromJson(response);
  }

  @override
  Future<PricingQuoteModel> quote(Map<String, dynamic> selection) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      url: ApiEndpoints.paymentsCustomQuote,
      payload: selection,
      options: ApiClient.protected,
    );
    return PricingQuoteModel.fromJson(response);
  }

  @override
  Future<PricingPayment> checkout({
    required Map<String, dynamic> selection,
    required String phone,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      url: ApiEndpoints.paymentsCustomQuoteCheckout,
      payload: {'phone': phone, ...selection},
      options: Options(
        headers: {'requiresToken': true, 'Idempotency-Key': const Uuid().v4()},
      ),
    );
    return paymentFromJson(response);
  }
}
