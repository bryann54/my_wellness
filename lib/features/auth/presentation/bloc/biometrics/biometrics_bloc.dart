// lib/features/auth/presentation/bloc/biometrics/biometrics_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/services/biometric_service.dart';
import 'package:my_wellness/core/services/pin_service.dart';

part 'biometrics_event.dart';
part 'biometrics_state.dart';

@injectable
class BiometricsBloc extends Bloc<BiometricsEvent, BiometricsState> {
  final BiometricService _biometricService;
  final PinService _pinService;

  BiometricsBloc(this._biometricService, this._pinService)
    : super(const BiometricsState()) {
    on<CheckBiometrics>(_onCheck);
    on<AuthenticateWithBiometrics>(_onAuthenticate);
    on<BiometricsAuthenticated>(_onBiometricsAuthenticated);
    on<BiometricsFailed>(_onBiometricsFailed);
    on<FallbackToPin>(_onFallbackToPin);
    on<VerifyPin>(_onVerifyPin);
    on<PinVerified>(_onPinVerified);
    on<PinFailed>(_onPinFailed);
    on<Logout>(_onLogout);
  }

  Future<void> _onCheck(
    CheckBiometrics event,
    Emitter<BiometricsState> emit,
  ) async {
    emit(state.copyWith(status: BiometricsStatus.checking));
    final available = await _biometricService.isBiometricAvailable();
    if (available) {
      add(AuthenticateWithBiometrics());
    } else {
      // No biometrics — check if PIN exists before showing PIN screen
      add(FallbackToPin());
    }
  }

  Future<void> _onAuthenticate(
    AuthenticateWithBiometrics event,
    Emitter<BiometricsState> emit,
  ) async {
    emit(state.copyWith(status: BiometricsStatus.authenticating));
    final success = await _biometricService.authenticate(
      reason: 'Verify your identity to access mywellness',
    );
    if (success) {
      add(BiometricsAuthenticated());
    } else {
      add(const BiometricsFailed('Could not verify your identity.'));
    }
  }

  void _onBiometricsAuthenticated(
    BiometricsAuthenticated event,
    Emitter<BiometricsState> emit,
  ) {
    emit(
      state.copyWith(
        status: BiometricsStatus.authenticated,
        isAuthenticated: true,
      ),
    );
  }

  void _onBiometricsFailed(
    BiometricsFailed event,
    Emitter<BiometricsState> emit,
  ) {
    emit(
      state.copyWith(
        status: BiometricsStatus.error,
        errorMessage: event.error ?? 'Biometric authentication failed.',
      ),
    );
  }

  Future<void> _onFallbackToPin(
    FallbackToPin event,
    Emitter<BiometricsState> emit,
  ) async {
    // ── KEY FIX ──────────────────────────────────────────────────────────────
    // If no PIN has been set yet (pre-existing account or simulator),
    // treat as authenticated so the splash triggers SecuritySetupSheet.
    // The user will set their PIN there before reaching MainRoute.
    final hasPin = await _pinService.hasPin();
    if (!hasPin) {
      emit(
        state.copyWith(
          status: BiometricsStatus.authenticated,
          isAuthenticated: true,
        ),
      );
      return;
    }
    // PIN exists — show the PIN entry screen
    emit(
      state.copyWith(status: BiometricsStatus.pinFallback, errorMessage: null),
    );
  }

  Future<void> _onVerifyPin(
    VerifyPin event,
    Emitter<BiometricsState> emit,
  ) async {
    emit(state.copyWith(status: BiometricsStatus.pinVerifying));
    final valid = await _pinService.verifyPin(event.pin);
    if (valid) {
      add(PinVerified());
    } else {
      add(PinFailed());
    }
  }

  void _onPinVerified(PinVerified event, Emitter<BiometricsState> emit) {
    emit(
      state.copyWith(
        status: BiometricsStatus.authenticated,
        isAuthenticated: true,
      ),
    );
  }

  void _onPinFailed(PinFailed event, Emitter<BiometricsState> emit) {
    emit(
      state.copyWith(
        status: BiometricsStatus.pinFallback,
        errorMessage: 'Incorrect PIN. Please try again.',
      ),
    );
  }

  void _onLogout(Logout event, Emitter<BiometricsState> emit) {
    emit(const BiometricsState());
  }
}
