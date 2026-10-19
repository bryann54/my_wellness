import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/app_lock/domain/entities/app_lock_status.dart';

abstract class AppLockRepository {
  Future<Either<Failure, AppLockStatus>> getStatus();

  Future<Either<Failure, UnlockOutcome>> authenticate({required String reason});

  Future<Either<Failure, void>> setEnabled(bool enabled);

  Future<Either<Failure, void>> markPrompted();

  Future<Either<Failure, void>> clear();
}
