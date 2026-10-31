import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/auth/data/models/auth_session_model.dart';
import 'package:my_wellness/features/auth/data/models/user_model.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';

part 'signup_pending_model.g.dart';

@JsonSerializable()
class SignupPendingModel {
  final String? channel;
  final String? destination;
  final String? message;
  final String? access;
  final String? refresh;
  final UserModel? user;
  @JsonKey(name: 'shr_linkage_pending')
  final bool? shrLinkagePending;
  @JsonKey(name: 'pending_subdomain_claim')
  final Object? pendingSubdomainClaim;

  const SignupPendingModel({
    this.channel,
    this.destination,
    this.message,
    this.access,
    this.refresh,
    this.user,
    this.shrLinkagePending,
    this.pendingSubdomainClaim,
  });

  bool get hasSession => access != null && refresh != null;

  AuthSessionModel toSessionModel() =>
      AuthSessionModel(access: access!, refresh: refresh!, user: user);

  factory SignupPendingModel.fromJson(Map<String, dynamic> json) =>
      _$SignupPendingModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupPendingModelToJson(this);

  SignupPendingEntity toEntity({required String fallbackDestination}) {
    final normalizedChannel = channel?.toLowerCase();
    final isPhone = normalizedChannel == 'phone' || normalizedChannel == 'sms';
    return SignupPendingEntity(
      channel: isPhone ? SignupChannel.phone : SignupChannel.email,
      destination: destination ?? fallbackDestination,
      message: message,
    );
  }
}
