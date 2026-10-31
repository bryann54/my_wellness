import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';

abstract class PricingRepository {
  Future<Either<Failure, List<PricingPackage>>> getPackages({
    bool refresh = false,
  });

  Future<Either<Failure, PricingCatalog>> getServiceCatalog({
    bool refresh = false,
  });

  Future<Either<Failure, PricingQuote>> quote(Map<String, dynamic> selection);
  Future<Either<Failure, PricingPayment>> checkout({
    required Map<String, dynamic> selection,
    required String phone,
  });
}
