// lib/features/auth/presentation/bloc/biometrics/biometrics_state.dart
part of 'biometrics_bloc.dart';

enum BiometricsStatus {
  initial,
  checking,
  authenticating,
  authenticated,
  error,
  pinFallback,
  pinVerifying,
}

class BiometricsState extends Equatable {
  final BiometricsStatus status;
  final String? errorMessage;
  final bool isAuthenticated;

  const BiometricsState({
    this.status = BiometricsStatus.initial,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  BiometricsState copyWith({
    BiometricsStatus? status,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return BiometricsState(
      status: status ?? this.status,
      // passing null explicitly clears the error
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isAuthenticated];
}
