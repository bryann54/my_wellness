// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_pending_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupPendingModel _$SignupPendingModelFromJson(Map<String, dynamic> json) =>
    SignupPendingModel(
      channel: json['channel'] as String?,
      destination: json['destination'] as String?,
      message: json['message'] as String?,
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      shrLinkagePending: json['shr_linkage_pending'] as bool?,
      pendingSubdomainClaim: json['pending_subdomain_claim'],
    );

Map<String, dynamic> _$SignupPendingModelToJson(SignupPendingModel instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'destination': instance.destination,
      'message': instance.message,
      'access': instance.access,
      'refresh': instance.refresh,
      'user': instance.user,
      'shr_linkage_pending': instance.shrLinkagePending,
      'pending_subdomain_claim': instance.pendingSubdomainClaim,
    };
