import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';

class AuthSessionEntity extends Equatable {
  final String access;
  final String refresh;
  final UserEntity user;
  final bool shrLinkagePending;

  const AuthSessionEntity({
    required this.access,
    required this.refresh,
    required this.user,
    this.shrLinkagePending = false,
  });

  @override
  List<Object?> get props => [access, refresh, user, shrLinkagePending];
}
