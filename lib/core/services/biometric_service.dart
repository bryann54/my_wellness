// lib/core/services/biometric_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

@lazySingleton
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();
  static const _kBiometricEnabledKey = 'biometric_enabled';

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to access your account',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled() async {
    final val = await _storage.read(key: _kBiometricEnabledKey);
    return val == 'true';
  }

  Future<void> setEnabled(bool value) async {
    await _storage.write(key: _kBiometricEnabledKey, value: value.toString());
  }
}
