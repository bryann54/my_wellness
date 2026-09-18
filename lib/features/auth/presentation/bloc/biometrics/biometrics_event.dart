part of 'biometrics_bloc.dart';

abstract class BiometricsEvent extends Equatable {
  const BiometricsEvent();

  @override
  List<Object?> get props => [];
}

class CheckBiometrics extends BiometricsEvent {}

class AuthenticateWithBiometrics extends BiometricsEvent {}

class BiometricsAuthenticated extends BiometricsEvent {}

class BiometricsFailed extends BiometricsEvent {
  final String? error;
  const BiometricsFailed([this.error]);
}

class FallbackToPin extends BiometricsEvent {}

class VerifyPin extends BiometricsEvent {
  final String pin;
  const VerifyPin(this.pin);
}

class PinVerified extends BiometricsEvent {}

class PinFailed extends BiometricsEvent {}

class Logout extends BiometricsEvent {}
