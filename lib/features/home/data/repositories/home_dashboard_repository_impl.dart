import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/home/data/datasources/home_dashboard_remote_datasource.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';
import 'package:my_wellness/features/home/domain/repositories/home_dashboard_repository.dart';

@LazySingleton(as: HomeDashboardRepository)
class HomeDashboardRepositoryImpl implements HomeDashboardRepository {
  HomeDashboardRepositoryImpl(this._remoteDataSource);

  final HomeDashboardRemoteDataSource _remoteDataSource;

  @override
  bool get lastLoadWasFromCache => _remoteDataSource.lastLoadWasFromCache;

  @override
  Future<Either<Failure, List<DashboardSession>>> loadRelevantSessions() async {
    try {
      return Right(await _remoteDataSource.loadRelevantSessions());
    } on Exception catch (exception) {
      return Left(_mapException(exception));
    }
  }

  Failure _mapException(Exception exception) => switch (exception) {
    NetworkException() => const NetworkFailure(),
    UnauthorizedException() => const UnauthorizedFailure(),
    ValidationException(:final message) => ValidationFailure(error: message),
    ServerException() => const ServerFailure(),
    _ => const ServerFailure(),
  };
}
