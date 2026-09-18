import 'package:equatable/equatable.dart';

enum SignupChannel { email, phone }

class SignupPendingEntity extends Equatable {
  /// Which channel received the verification code.
  final SignupChannel channel;

  /// The email or phone the code was sent to (masked for display if desired).
  final String destination;

  /// Optional server-provided message to show the user.
  final String? message;

  const SignupPendingEntity({
    required this.channel,
    required this.destination,
    this.message,
  });

  @override
  List<Object?> get props => [channel, destination, message];
}
