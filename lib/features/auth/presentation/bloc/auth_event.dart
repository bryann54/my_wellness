import 'package:equatable/equatable.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class SignInEvent extends AuthEvent {
  final String identifier; // email or phone
  final String password;

  const SignInEvent({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
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
  const RequestPasswordResetEvent({required this.identifier});
  @override
  List<Object?> get props => [identifier];
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
