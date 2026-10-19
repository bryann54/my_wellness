import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/app_lock/domain/entities/app_lock_status.dart';
import 'package:my_wellness/features/app_lock/domain/repositories/app_lock_repository.dart';

@lazySingleton
class GetAppLockStatusUseCase {
  final AppLockRepository repository;
  GetAppLockStatusUseCase(this.repository);

  Future<Either<Failure, AppLockStatus>> call() => repository.getStatus();
}

@lazySingleton
class AuthenticateAppLockUseCase {
  final AppLockRepository repository;
  AuthenticateAppLockUseCase(this.repository);

  Future<Either<Failure, UnlockOutcome>> call({required String reason}) =>
      repository.authenticate(reason: reason);
}

@lazySingleton
class SetAppLockEnabledUseCase {
  final AppLockRepository repository;
  SetAppLockEnabledUseCase(this.repository);

  Future<Either<Failure, void>> call(bool enabled) =>
      repository.setEnabled(enabled);
}

@lazySingleton
class MarkAppLockPromptedUseCase {
  final AppLockRepository repository;
  MarkAppLockPromptedUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.markPrompted();
}

@lazySingleton
class ClearAppLockUseCase {
  final AppLockRepository repository;
  ClearAppLockUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.clear();
}
