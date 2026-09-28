import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/verified_identity.dart';

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

enum KycStatus { idle, verifying, verified, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final SignupPendingEntity? pendingSignup;

  final KycStatus kycStatus;
  final VerifiedIdentity? verifiedIdentity;
  final String? kycError;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.pendingSignup,
    this.kycStatus = KycStatus.idle,
    this.verifiedIdentity,
    this.kycError,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    SignupPendingEntity? pendingSignup,
    KycStatus? kycStatus,
    VerifiedIdentity? verifiedIdentity,
    String? kycError,
    bool clearUser = false,
    bool clearError = false,
    bool clearPending = false,
    bool clearVerifiedIdentity = false,
    bool clearKycError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingSignup: clearPending ? null : pendingSignup ?? this.pendingSignup,
      kycStatus: kycStatus ?? this.kycStatus,
      verifiedIdentity: clearVerifiedIdentity
          ? null
          : verifiedIdentity ?? this.verifiedIdentity,
      kycError: clearKycError ? null : kycError ?? this.kycError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    pendingSignup,
    kycStatus,
    verifiedIdentity,
    kycError,
  ];
}
