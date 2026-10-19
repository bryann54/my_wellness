import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

abstract class AppLockDataSource {
  /// True when the device has biometrics or a PIN/pattern/password.
  Future<bool> isDeviceSecured();

  /// Throws [LocalAuthException] on cancel, lockout or missing credentials.
  Future<bool> authenticate(String reason);

  Future<bool> isEnabled();
  Future<bool> isPrompted();
  Future<void> setEnabled(bool value);
  Future<void> markPrompted();
  Future<void> clear();
}

@LazySingleton(as: AppLockDataSource)
class AppLockDataSourceImpl implements AppLockDataSource {
  final FlutterSecureStorage _secure;
  final LocalAuthentication _auth;

  static const _enabledKey = 'appLockEnabled';
  static const _promptedKey = 'appLockPrompted';

  AppLockDataSourceImpl(this._secure, this._auth);

  @override
  Future<bool> isDeviceSecured() => _auth.isDeviceSupported();

  @override
  Future<bool> authenticate(String reason) => _auth.authenticate(
    localizedReason: reason,
    biometricOnly: false,
    persistAcrossBackgrounding: true,
  );

  @override
  Future<bool> isEnabled() async =>
      await _secure.read(key: _enabledKey) == 'true';

  @override
  Future<bool> isPrompted() async =>
      await _secure.read(key: _promptedKey) == 'true';

  @override
  Future<void> setEnabled(bool value) =>
      _secure.write(key: _enabledKey, value: value.toString());

  @override
  Future<void> markPrompted() =>
      _secure.write(key: _promptedKey, value: 'true');

  @override
  Future<void> clear() async {
    await Future.wait([
      _secure.delete(key: _enabledKey),
      _secure.delete(key: _promptedKey),
    ]);
  }
}
