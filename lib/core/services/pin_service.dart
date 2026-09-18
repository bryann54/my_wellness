// lib/core/services/pin_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PinService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _pinKey = 'user_pin';
  static const _pinSetupDoneKey = 'pin_setup_done';

  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _pinSetupDoneKey, value: 'true');
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored == pin;
  }

  Future<bool> hasPin() async {
    final done = await _storage.read(key: _pinSetupDoneKey);
    return done == 'true';
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinSetupDoneKey);
  }
}
