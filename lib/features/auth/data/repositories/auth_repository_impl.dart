import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:my_wellness/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/domain/entities/auth_session_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';
import 'package:my_wellness/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Stream<UserEntity?> get authStateChanges =>
      _local.userStream.map((model) => model?.toEntity());

  @override
  Future<Either<Failure, AuthSessionEntity>> signIn({
    required String identifier,
    required String password,
  }) async {
    try {
      final session = await _remote.login(
        identifier: identifier,
        password: password,
      );

      await _local.saveTokens(access: session.access, refresh: session.refresh);

      if (session.user != null) {
        await _local.saveUser(session.user!);
      }

      return Right(session.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(error: e.message));
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(GeneralFailure(error: e.message ?? 'Server error'));
    } catch (e) {
      return Left(
        GeneralFailure(error: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, SignupPendingEntity>> signUp(
    SignupRequestModel req,
  ) async {
    try {
      final pendingModel = await _remote.signup(req);
      final fallbackDestination = req.email ?? req.phone ?? '';
      final pendingEntity = pendingModel.toEntity(
        fallbackDestination: fallbackDestination,
      );

      await _local.savePendingSignup(pendingEntity);

      return Right(pendingEntity);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(error: e.message));
    } on NetworkException catch (e) {
      return Left(GeneralFailure(error: e.message ?? 'Network error'));
    } on ServerException catch (e) {
      return Left(GeneralFailure(error: e.message ?? 'Server error'));
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmSignupEmail({
    required String email,
    required String code,
  }) async {
    try {
      await _remote.confirmSignupEmail(email: email, code: code);
      await _local.clearPendingSignup();
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(error: e.message));
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmSignupPhone({
    required String phone,
    required String code,
  }) async {
    try {
      await _remote.confirmSignupPhone(phone: phone, code: code);
      await _local.clearPendingSignup();
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(error: e.message));
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendSignupEmail({
    required String email,
  }) async {
    try {
      await _remote.resendSignupEmail(email: email);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendSignupPhone({
    required String phone,
  }) async {
    try {
      await _remote.resendSignupPhone(phone: phone);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut({bool allDevices = false}) async {
    try {
      // Best-effort server-side revoke; ignore failure and clear locally.
      try {
        if (allDevices) {
          await _remote.logoutAll();
        } else {
          await _remote.logout();
        }
      } catch (_) {
        /* ignore */
      }
      await _local.clearAuthData();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset({
    required String identifier,
  }) async {
    try {
      await _remote.requestPasswordReset(identifier: identifier);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(error: e.message));
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _remote.confirmPasswordReset(
        identifier: identifier,
        code: code,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(error: e.message));
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _local.getUser();
      return Right(user?.toEntity());
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refresh = await _local.getRefreshToken();
      if (refresh == null) return const Left(UnauthorizedFailure());

      final session = await _remote.refresh(refresh);
      await _local.saveTokens(access: session.access, refresh: session.refresh);
      return Right(session.access);
    } on UnauthorizedException {
      await _local.clearAuthData();
      return const Left(UnauthorizedFailure());
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }
}
