import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/geography/data/datasources/geography_remote_datasource.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';
import 'package:my_wellness/features/geography/domain/repositories/geography_repository.dart';

@LazySingleton(as: GeographyRepository)
class GeographyRepositoryImpl implements GeographyRepository {
  final GeographyRemoteDataSource _remote;

  List<County>? _countiesCache;
  List<SubCounty>? _subCountiesCache;
  List<Constituency>? _constituenciesCache;
  List<Ward>? _wardsCache;

  GeographyRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<County>>> getCounties() async {
    if (_countiesCache != null) return Right(_countiesCache!);
    try {
      final data = await _remote.getCounties();
      _countiesCache = data;
      return Right(data);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<SubCounty>>> getSubCounties() async {
    if (_subCountiesCache != null) return Right(_subCountiesCache!);
    try {
      final data = await _remote.getSubCounties();
      _subCountiesCache = data;
      return Right(data);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<Constituency>>> getConstituencies() async {
    if (_constituenciesCache != null) return Right(_constituenciesCache!);
    try {
      final data = await _remote.getConstituencies();
      _constituenciesCache = data;
      return Right(data);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<Ward>>> getWards() async {
    if (_wardsCache != null) return Right(_wardsCache!);
    try {
      final data = await _remote.getWards();
      _wardsCache = data;
      return Right(data);
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  Failure _map(Exception e) {
    if (e is NetworkException) return const NetworkFailure();
    if (e is ServerException) return const ServerFailure();
    if (e is UnauthorizedException) return const UnauthorizedFailure();
    if (e is ValidationException) return ValidationFailure(error: e.message);
    return GeneralFailure(error: e.toString());
  }
}
