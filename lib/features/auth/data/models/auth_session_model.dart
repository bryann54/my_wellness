import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/auth/data/models/user_model.dart';
import 'package:my_wellness/features/auth/domain/entities/auth_session_entity.dart';
import 'package:my_wellness/features/auth/domain/entities/user_entity.dart';

part 'auth_session_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthSessionModel {
  final String access;
  final String refresh;
  final UserModel? user;

  final Map<String, dynamic>? clinician;
  final Map<String, dynamic>? profile;

  const AuthSessionModel({
    required this.access,
    required this.refresh,
    this.user,
    this.clinician,
    this.profile,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthSessionModelToJson(this);

  AuthSessionEntity toEntity() => AuthSessionEntity(
    access: access,
    refresh: refresh,
    user:
        user?.toEntity() ??
        const UserEntity(
          id: '',
          email: '',
          firstName: '',
          surname: '',
          phone: '',
          gender: '',
        ),
  );
}
