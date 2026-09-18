import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  awaitingSignupConfirmation,
  passwordResetRequested,
  passwordResetCompleted,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final SignupPendingEntity? pendingSignup;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.pendingSignup,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    SignupPendingEntity? pendingSignup,
    bool clearUser = false,
    bool clearError = false,
    bool clearPending = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingSignup: clearPending
          ? null
          : (pendingSignup ?? this.pendingSignup),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, pendingSignup];
}
