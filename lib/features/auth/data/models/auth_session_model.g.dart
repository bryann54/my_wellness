// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSessionModel _$AuthSessionModelFromJson(Map<String, dynamic> json) =>
    AuthSessionModel(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      clinician: json['clinician'] as Map<String, dynamic>?,
      profile: json['profile'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AuthSessionModelToJson(AuthSessionModel instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
      'user': instance.user?.toJson(),
      'clinician': instance.clinician,
      'profile': instance.profile,
    };
