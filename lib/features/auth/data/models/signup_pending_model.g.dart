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
    );

Map<String, dynamic> _$SignupPendingModelToJson(SignupPendingModel instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'destination': instance.destination,
      'message': instance.message,
    };
