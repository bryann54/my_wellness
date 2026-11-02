import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';

abstract class PricingRepository {
  Future<Either<Failure, List<PricingPackage>>> getPackages({
    String? category,
    bool refresh = false,
  });

  Future<Either<Failure, PricingCatalog>> getServiceCatalog({
    bool refresh = false,
  });

  Future<Either<Failure, PricingQuote>> quote(Map<String, dynamic> selection);

  Future<Either<Failure, PricingPayment>> checkout({
    required Map<String, dynamic> selection,
    required String phone,
    String? idempotencyKey,
  });

  Future<Either<Failure, PricingPayment>> stkPush({
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
  Future<Either<Failure, List<PricingPayment>>> getMyPayments({String? cursor});
  Future<Either<Failure, Set<String>>> getUnlockedCategories();

  Future<Either<Failure, bool>> hasVitalsLoggingAccess();

  Future<Either<Failure, List<Map<String, dynamic>>>> getReceipts({
    String? cursor,
  });
  Future<Either<Failure, Uint8List>> getReceiptPdf(String id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getInvoices({
    String? cursor,
  });
  Future<Either<Failure, Uint8List>> getInvoicePdf(String id);
}
