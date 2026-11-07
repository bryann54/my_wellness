import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/domain/entities/auth_session_entity.dart';

class SignInResultEntity extends Equatable {
  final AuthSessionEntity? session;
  final String? mfaToken;

  const SignInResultEntity({this.session, this.mfaToken})
    : assert((session == null) != (mfaToken == null));

  bool get requiresMfa => mfaToken != null;

  @override
  List<Object?> get props => [session, mfaToken];
}
