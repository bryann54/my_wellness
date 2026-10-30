import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';

abstract class PricingRepository {
  Future<Either<Failure, List<PricingPackage>>> getPackages();
}
