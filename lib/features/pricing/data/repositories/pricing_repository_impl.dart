import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/data/datasources/pricing_remote_data_source.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/repositories/pricing_repository.dart';

@LazySingleton(as: PricingRepository)
class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource _remoteDataSource;

  PricingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<PricingPackage>>> getPackages() async {
    try {
      final packages = await _remoteDataSource.getPackages();
      return Right(
        packages.map((package) => package.toEntity()).toList(growable: false),
      );
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on NotFoundException catch (error) {
      return Left(NotFoundFailure(error: error.message));
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error: error.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on Exception catch (error) {
      return Left(GeneralFailure(error: error.toString()));
    }
  }
}
