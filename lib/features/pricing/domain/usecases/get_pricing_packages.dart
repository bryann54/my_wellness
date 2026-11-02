import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/repositories/pricing_repository.dart';

@lazySingleton
class GetPricingPackagesUseCase {
  final PricingRepository _repository;
  GetPricingPackagesUseCase(this._repository);

  Future<Either<Failure, List<PricingPackage>>> call({
    String? category,
    bool refresh = false,
  }) => _repository.getPackages(category: category, refresh: refresh);
}

@lazySingleton
class GetPricingCatalogUseCase {
  final PricingRepository _repository;
  GetPricingCatalogUseCase(this._repository);
  Future<Either<Failure, PricingCatalog>> call({bool refresh = false}) =>
      _repository.getServiceCatalog(refresh: refresh);
}

@lazySingleton
class GetPricingQuoteUseCase {
  final PricingRepository _repository;
  GetPricingQuoteUseCase(this._repository);
  Future<Either<Failure, PricingQuote>> call(Map<String, dynamic> selection) =>
      _repository.quote(selection);
}

@lazySingleton
class CheckoutPricingSelectionUseCase {
  final PricingRepository _repository;
  CheckoutPricingSelectionUseCase(this._repository);
  Future<Either<Failure, PricingPayment>> call({
    required Map<String, dynamic> selection,
    required String phone,
    String? idempotencyKey,
  }) => _repository.checkout(
    selection: selection,
    phone: phone,
    idempotencyKey: idempotencyKey,
  );
}

@lazySingleton
class StkPushUseCase {
  final PricingRepository _repository;
  StkPushUseCase(this._repository);
  Future<Either<Failure, PricingPayment>> call({
    required String phone,
    required int amount,
    required String serviceType,
    required String idempotencyKey,
    String? sessionId,
    String? bookingId,
    String? invoiceId,
    String? packageId,
    int? age,
  }) => _repository.stkPush(
    phone: phone,
    amount: amount,
    serviceType: serviceType,
    idempotencyKey: idempotencyKey,
    sessionId: sessionId,
    bookingId: bookingId,
    invoiceId: invoiceId,
    packageId: packageId,
    age: age,
  );
}

@lazySingleton
class GetMyPaymentsUseCase {
  final PricingRepository _repository;
  GetMyPaymentsUseCase(this._repository);
  Future<Either<Failure, List<PricingPayment>>> call({String? cursor}) =>
      _repository.getMyPayments(cursor: cursor);
}

@lazySingleton
class GetUnlockedCategoriesUseCase {
  final PricingRepository _repository;
  GetUnlockedCategoriesUseCase(this._repository);
  Future<Either<Failure, Set<String>>> call() =>
      _repository.getUnlockedCategories();
}

@lazySingleton
class HasVitalsLoggingAccessUseCase {
  final PricingRepository _repository;
  HasVitalsLoggingAccessUseCase(this._repository);
  Future<Either<Failure, bool>> call() => _repository.hasVitalsLoggingAccess();
}

@lazySingleton
class GetReceiptsUseCase {
  final PricingRepository _repository;
  GetReceiptsUseCase(this._repository);
  Future<Either<Failure, List<Map<String, dynamic>>>> call({String? cursor}) =>
      _repository.getReceipts(cursor: cursor);
}

@lazySingleton
class DownloadReceiptPdfUseCase {
  final PricingRepository _repository;
  DownloadReceiptPdfUseCase(this._repository);
  Future<Either<Failure, Uint8List>> call(String id) =>
      _repository.getReceiptPdf(id);
}

@lazySingleton
class GetInvoicesUseCase {
  final PricingRepository _repository;
  GetInvoicesUseCase(this._repository);
  Future<Either<Failure, List<Map<String, dynamic>>>> call({String? cursor}) =>
      _repository.getInvoices(cursor: cursor);
}

@lazySingleton
class DownloadInvoicePdfUseCase {
  final PricingRepository _repository;
  DownloadInvoicePdfUseCase(this._repository);
  Future<Either<Failure, Uint8List>> call(String id) =>
      _repository.getInvoicePdf(id);
}
