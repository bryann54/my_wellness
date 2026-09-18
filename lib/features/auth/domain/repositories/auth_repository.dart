import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/domain/entities/auth_session_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, AuthSessionEntity>> signIn({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, SignupPendingEntity>> signUp(SignupRequestModel req);

  Future<Either<Failure, void>> confirmSignupEmail({
    required String email,
    required String code,
  });

  Future<Either<Failure, void>> confirmSignupPhone({
    required String phone,
    required String code,
  });

  Future<Either<Failure, void>> resendSignupEmail({required String email});
  Future<Either<Failure, void>> resendSignupPhone({required String phone});

  Future<Either<Failure, void>> signOut({bool allDevices = false});

  Future<Either<Failure, void>> requestPasswordReset({
    required String identifier,
  });
  Future<Either<Failure, void>> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
  });

  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, String>> refreshToken();
}
