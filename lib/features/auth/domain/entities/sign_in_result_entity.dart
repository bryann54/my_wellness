import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/domain/entities/auth_session_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';

class SignInResultEntity extends Equatable {
  final AuthSessionEntity? session;
  final String? mfaToken;
  final SignupPendingEntity? pendingSignup;

  const SignInResultEntity({this.session, this.mfaToken, this.pendingSignup})
    : assert(
        (session != null ? 1 : 0) +
                (mfaToken != null ? 1 : 0) +
                (pendingSignup != null ? 1 : 0) ==
            1,
      );

  bool get requiresMfa => mfaToken != null;
  bool get requiresSignupConfirmation => pendingSignup != null;

  @override
  List<Object?> get props => [session, mfaToken, pendingSignup];
}
