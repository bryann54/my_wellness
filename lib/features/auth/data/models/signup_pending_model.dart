import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';

part 'signup_pending_model.g.dart';

@JsonSerializable()
class SignupPendingModel {
  final String? channel;
  final String? destination;
  final String? message;

  const SignupPendingModel({this.channel, this.destination, this.message});

  factory SignupPendingModel.fromJson(Map<String, dynamic> json) =>
      _$SignupPendingModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupPendingModelToJson(this);

  SignupPendingEntity toEntity({required String fallbackDestination}) {
    final isPhone = channel?.toLowerCase() == 'phone';
    return SignupPendingEntity(
      channel: isPhone ? SignupChannel.phone : SignupChannel.email,
      destination: destination ?? fallbackDestination,
      message: message,
    );
  }
}
