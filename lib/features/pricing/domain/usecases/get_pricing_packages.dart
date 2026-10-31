import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
import 'package:my_wellness/features/pricing/domain/repositories/pricing_repository.dart';

@lazySingleton
class GetPricingPackagesUseCase {
  final PricingRepository _repository;

  GetPricingPackagesUseCase(this._repository);

  Future<Either<Failure, List<PricingPackage>>> call({bool refresh = false}) =>
      _repository.getPackages(refresh: refresh);
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
  }) => _repository.checkout(selection: selection, phone: phone);
}
