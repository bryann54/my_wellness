// lib/features/account/data/repositories/account_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import '../../domain/entities/health_profile.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../datasources/account_remote_datasource.dart';

@LazySingleton(as: AccountRepository)
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remote;
  final AccountLocalDatasource _local;

  AccountRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, HealthProfile>> getProfile() async {
    try {
      final remoteProfile = await _remote.getProfile();
      await _local.cacheHealthProfile(remoteProfile);
      return Right(remoteProfile);
    } on NetworkException {
      final localProfile = _local.getCachedProfile();
      if (localProfile != null) return Right(localProfile);
      return Left(NetworkFailure());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, HealthProfile>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final profile = await _remote.updateProfile(data);
      await _local.cacheHealthProfile(profile);
      return Right(profile);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, NoParams>> changeLanguage(String code) async {
    try {
      await _local.cacheLanguage(code);
      return Right(NoParams());
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remote.requestAccountDeletion();
      await _local.clearAllData();
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAccountDeletion() async {
    try {
      await _remote.cancelAccountDeletion();
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> exportData() async {
    try {
      await _remote.exportData();
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(Exception e) {
    if (e is UnauthorizedException) return const UnauthorizedFailure();
    if (e is ValidationException) return ValidationFailure(error: e.message);
    if (e is NotFoundException) return NotFoundFailure(error: e.message);
    if (e is NetworkException) return const NetworkFailure();
    if (e is ServerException) return const ServerFailure();
    return GeneralFailure(error: e.toString());
  }
}
