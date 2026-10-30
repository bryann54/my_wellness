import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/repositories/pricing_repository.dart';

@lazySingleton
class GetPricingPackagesUseCase
    implements UseCase<List<PricingPackage>, NoParams> {
  final PricingRepository _repository;

  GetPricingPackagesUseCase(this._repository);

  @override
  Future<Either<Failure, List<PricingPackage>>> call(NoParams params) =>
      _repository.getPackages();
}
