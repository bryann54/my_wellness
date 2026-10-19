import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/app_lock/data/datasources/app_lock_datasource.dart';
import 'package:my_wellness/features/app_lock/domain/entities/app_lock_status.dart';
import 'package:my_wellness/features/app_lock/domain/repositories/app_lock_repository.dart';

@LazySingleton(as: AppLockRepository)
class AppLockRepositoryImpl implements AppLockRepository {
  final AppLockDataSource _source;

  AppLockRepositoryImpl(this._source);

  @override
  Future<Either<Failure, AppLockStatus>> getStatus() async {
    try {
      final enabled = await _source.isEnabled();
      final prompted = await _source.isPrompted();
      return Right(
        AppLockStatus(
          enabled: enabled,
          prompted: prompted,
          security: await _security(),
        ),
      );
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UnlockOutcome>> authenticate({
    required String reason,
  }) async {
    try {
      final ok = await _source.authenticate(reason);
      return Right(ok ? UnlockOutcome.success : UnlockOutcome.cancelled);
    } on LocalAuthException catch (e) {
      return Right(_outcomeFor(e.code));
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setEnabled(bool enabled) =>
      _guard(() => _source.setEnabled(enabled));

  @override
  Future<Either<Failure, void>> markPrompted() => _guard(_source.markPrompted);

  @override
  Future<Either<Failure, void>> clear() => _guard(_source.clear);

  Future<DeviceSecurity> _security() async {
    try {
      return await _source.isDeviceSecured()
          ? DeviceSecurity.secured
          : DeviceSecurity.unsecured;
    } catch (_) {
      return DeviceSecurity.unsecured;
    }
  }

  UnlockOutcome _outcomeFor(LocalAuthExceptionCode code) => switch (code) {
    LocalAuthExceptionCode.userCanceled ||
    LocalAuthExceptionCode.systemCanceled => UnlockOutcome.cancelled,
    LocalAuthExceptionCode.temporaryLockout ||
    LocalAuthExceptionCode.biometricLockout => UnlockOutcome.lockedOut,
    LocalAuthExceptionCode.noBiometricHardware ||
    LocalAuthExceptionCode.noBiometricsEnrolled ||
    LocalAuthExceptionCode.noCredentialsSet => UnlockOutcome.unavailable,
    _ => UnlockOutcome.failed,
  };

  Future<Either<Failure, void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
