import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInEvent extends AuthEvent {
  final String identifier;
  final String password;

  const SignInEvent({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
}

class VerifyMfaEvent extends AuthEvent {
  final String value;
  final bool useBackupCode;

  const VerifyMfaEvent({required this.value, this.useBackupCode = false});

  @override
  List<Object?> get props => [value, useBackupCode];
}

class CancelMfaEvent extends AuthEvent {
  const CancelMfaEvent();
}

class SignUpEvent extends AuthEvent {
  final SignupRequestModel request;
  const SignUpEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ConfirmSignupEmailEvent extends AuthEvent {
  final String email;
  final String code;
  const ConfirmSignupEmailEvent({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class ConfirmSignupPhoneEvent extends AuthEvent {
  final String phone;
  final String code;
  const ConfirmSignupPhoneEvent({required this.phone, required this.code});

  @override
  List<Object?> get props => [phone, code];
}

class VerifyIdentityEvent extends AuthEvent {
  final String idType;
  final String idNumber;
  const VerifyIdentityEvent({required this.idType, required this.idNumber});

  @override
  List<Object?> get props => [idType, idNumber];
}

class ResetIdentityVerificationEvent extends AuthEvent {
  const ResetIdentityVerificationEvent();
}

class ResendSignupEmailEvent extends AuthEvent {
  final String email;
  const ResendSignupEmailEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResendSignupPhoneEvent extends AuthEvent {
  final String phone;
  const ResendSignupPhoneEvent({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class SignOutEvent extends AuthEvent {
  final bool allDevices;
  const SignOutEvent({this.allDevices = false});

  @override
  List<Object?> get props => [allDevices];
}

class RequestPasswordResetEvent extends AuthEvent {
  final String identifier;
  final String? channel;
  const RequestPasswordResetEvent({required this.identifier, this.channel});

  @override
  List<Object?> get props => [identifier, channel];
}

class ConfirmPasswordResetEvent extends AuthEvent {
  final String identifier;
  final String code;
  final String newPassword;
  const ConfirmPasswordResetEvent({
    required this.identifier,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [identifier, code, newPassword];
}
