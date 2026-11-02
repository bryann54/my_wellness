import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/pricing/data/models/pricing_catalog_model.dart';
import 'package:my_wellness/features/pricing/data/models/pricing_package_model.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';

abstract class PricingRemoteDataSource {
  Future<List<PricingPackageModel>> getPackages({String? category});
  Future<PricingCatalogModel> getServiceCatalog();
  Future<PricingQuoteModel> quote(Map<String, dynamic> selection);
  Future<PricingPayment> checkout({
    required Map<String, dynamic> selection,
    required String phone,
    String? idempotencyKey,
  });
  Future<PricingPayment> stkPush({
    required String phone,
    required int amount,
    required String serviceType,
    required String idempotencyKey,
    String? sessionId,
    String? bookingId,
    String? invoiceId,
    String? packageId,
    int? age,
  });
  Future<List<PricingPayment>> getMyPayments({String? cursor});
  Future<Set<String>> getUnlockedCategories();
  Future<bool> hasVitalsLoggingAccess();
  Future<List<Map<String, dynamic>>> getReceipts({String? cursor});
  Future<Uint8List> getReceiptPdf(String id);
  Future<List<Map<String, dynamic>>> getInvoices({String? cursor});
  Future<Uint8List> getInvoicePdf(String id);
}

@LazySingleton(as: PricingRemoteDataSource)
class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final ApiClient _apiClient;

  PricingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PricingPackageModel>> getPackages({String? category}) async {
    final response = await _apiClient.get<List<dynamic>>(
      url: ApiEndpoints.paymentsPackages,
      query: category == null ? null : {'category': category},
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
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      url: ApiEndpoints.paymentsCustomQuoteCheckout,
      payload: {'phone': phone, ...selection},
      options: Options(
        headers: {
          'requiresToken': true,
          'Idempotency-Key': idempotencyKey ?? const Uuid().v4(),
        },
      ),
    );
    return paymentFromJson(response);
  }

  @override
  Future<PricingPayment> stkPush({
    required String phone,
    required int amount,
    required String serviceType,
    required String idempotencyKey,
    String? sessionId,
    String? bookingId,
    String? invoiceId,
    String? packageId,
    int? age,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      url: ApiEndpoints.paymentsStkPush,
      payload: {
        'phone': phone,
        'amount': amount,
        'service_type': serviceType,
        'session_id': ?sessionId,
        'booking_id': ?bookingId,
        'invoice_id': ?invoiceId,
        'package_id': ?packageId,
        'age': ?age,
      },
      options: Options(
        headers: {'requiresToken': true, 'Idempotency-Key': idempotencyKey},
      ),
    );
    return paymentFromJson(response);
  }

  @override
  Future<List<PricingPayment>> getMyPayments({String? cursor}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.paymentsMine,
      query: cursor == null ? null : {'cursor': cursor},
      options: ApiClient.protected,
    );
    final results = response['results'];
    if (results is! List) return const [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(paymentFromJson)
        .toList(growable: false);
  }

  @override
  Future<Set<String>> getUnlockedCategories() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.paymentsModuleAccess,
      options: ApiClient.protected,
    );
    final unlocked = response['unlocked'];
    if (unlocked is! Map) return const {};
    return unlocked.keys.map((k) => k.toString()).toSet();
  }

  @override
  Future<bool> hasVitalsLoggingAccess() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.vitalsAccess,
      options: ApiClient.protected,
    );
    return response['has_access'] == true;
  }

  @override
  Future<List<Map<String, dynamic>>> getReceipts({String? cursor}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.receiptsMine,
      query: cursor == null ? null : {'cursor': cursor},
      options: ApiClient.protected,
    );
    final results = response['results'];
    if (results is! List) return const [];
    return results.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  @override
  Future<Uint8List> getReceiptPdf(String id) async {
    final stream = await _apiClient.postStream(
      url: ApiEndpoints.receiptPdf(id),
      options: ApiClient.protected,
    );
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  @override
  Future<List<Map<String, dynamic>>> getInvoices({String? cursor}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      url: ApiEndpoints.invoicesMine,
      query: cursor == null ? null : {'cursor': cursor},
      options: ApiClient.protected,
    );
    final results = response['results'];
    if (results is! List) return const [];
    return results.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  @override
  Future<Uint8List> getInvoicePdf(String id) async {
    final stream = await _apiClient.postStream(
      url: ApiEndpoints.invoicePdf(id),
      options: ApiClient.protected,
    );
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }
}
