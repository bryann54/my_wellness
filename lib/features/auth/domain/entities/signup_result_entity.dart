import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/domain/entities/auth_session_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';

class SignupResultEntity extends Equatable {
  final SignupPendingEntity? pending;
  final AuthSessionEntity? session;

  const SignupResultEntity({this.pending, this.session});

  @override
  List<Object?> get props => [pending, session];
}
