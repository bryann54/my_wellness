import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/domain/entities/auth_session_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';
import 'package:my_wellness/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<Either<Failure, AuthSessionEntity>> call({
    required String identifier,
    required String password,
  }) => repository.signIn(identifier: identifier, password: password);
}

@lazySingleton
class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<Either<Failure, SignupPendingEntity>> call(SignupRequestModel req) =>
      repository.signUp(req);
}

@lazySingleton
class ConfirmSignupEmailUseCase {
  final AuthRepository repository;
  ConfirmSignupEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String code,
  }) => repository.confirmSignupEmail(email: email, code: code);
}

@lazySingleton
class ConfirmSignupPhoneUseCase {
  final AuthRepository repository;
  ConfirmSignupPhoneUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String phone,
    required String code,
  }) => repository.confirmSignupPhone(phone: phone, code: code);
}

@lazySingleton
class ResendSignupEmailUseCase {
  final AuthRepository repository;
  ResendSignupEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({required String email}) =>
      repository.resendSignupEmail(email: email);
}

@lazySingleton
class ResendSignupPhoneUseCase {
  final AuthRepository repository;
  ResendSignupPhoneUseCase(this.repository);

  Future<Either<Failure, void>> call({required String phone}) =>
      repository.resendSignupPhone(phone: phone);
}

@lazySingleton
class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call({bool allDevices = false}) =>
      repository.signOut(allDevices: allDevices);
}

@lazySingleton
class GetAuthStateUseCase {
  final AuthRepository repository;
  GetAuthStateUseCase(this.repository);

  Stream<UserEntity?> call() => repository.authStateChanges;
}

@lazySingleton
class RequestPasswordResetUseCase {
  final AuthRepository repository;
  RequestPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call({required String identifier}) =>
      repository.requestPasswordReset(identifier: identifier);
}

@lazySingleton
class ConfirmPasswordResetUseCase {
  final AuthRepository repository;
  ConfirmPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String identifier,
    required String code,
    required String newPassword,
  }) => repository.confirmPasswordReset(
    identifier: identifier,
    code: code,
    newPassword: newPassword,
  );
}

@lazySingleton
class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() => repository.getCurrentUser();
}
