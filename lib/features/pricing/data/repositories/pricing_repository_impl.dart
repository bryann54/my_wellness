import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/data/datasources/pricing_remote_data_source.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
import 'package:my_wellness/features/pricing/domain/repositories/pricing_repository.dart';

@LazySingleton(as: PricingRepository)
class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource _remoteDataSource;
  Either<Failure, List<PricingPackage>>? _lastResult;
  Either<Failure, PricingCatalog>? _lastCatalog;

  PricingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<PricingPackage>>> getPackages({
    bool refresh = false,
  }) async {
    if (!refresh && _lastResult != null) return _lastResult!;
    try {
      final packages = await _remoteDataSource.getPackages();
      final entities = packages
          .map((package) => package.toEntity())
          .toList(growable: false);
      return _lastResult = Right(entities);
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

  @override
  Future<Either<Failure, PricingCatalog>> getServiceCatalog({
    bool refresh = false,
  }) async {
    if (!refresh && _lastCatalog != null) return _lastCatalog!;
    try {
      return _lastCatalog = Right(
        (await _remoteDataSource.getServiceCatalog()).toEntity(),
      );
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, PricingQuote>> quote(
    Map<String, dynamic> selection,
  ) async {
    try {
      return Right((await _remoteDataSource.quote(selection)).quote);
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, PricingPayment>> checkout({
    required Map<String, dynamic> selection,
    required String phone,
  }) async {
    try {
      return Right(
        await _remoteDataSource.checkout(selection: selection, phone: phone),
      );
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  Failure _mapException(Exception error) => switch (error) {
    UnauthorizedException() => const UnauthorizedFailure(),
    NetworkException() => const NetworkFailure(),
    NotFoundException(:final message) => NotFoundFailure(error: message),
    ValidationException(:final message) => ValidationFailure(error: message),
    ServerException() => const ServerFailure(),
    _ => GeneralFailure(error: error.toString()),
  };
}
