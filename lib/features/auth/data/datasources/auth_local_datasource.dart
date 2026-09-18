import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/features/auth/data/models/user_model.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';

abstract class AuthLocalDataSource {
  Stream<UserModel?> get userStream;

  Future<void> saveTokens({required String access, required String refresh});
  Future<void> saveUser(UserModel user);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<UserModel?> getUser();

  Future<void> savePendingSignup(SignupPendingEntity pending);
  Future<SignupPendingEntity?> getPendingSignup();
  Future<void> clearPendingSignup();

  Future<void> clearAuthData();
  void dispose();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secure;

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _userKey = 'cachedUser';
  static const _pendingKey = 'pendingSignup';

  final _userStreamController = StreamController<UserModel?>.broadcast();

  AuthLocalDataSourceImpl(this._secure) {
    _init();
  }

  Future<void> _init() async {
    final user = await getUser();
    _userStreamController.add(user);
  }

  @override
  Stream<UserModel?> get userStream => _userStreamController.stream;

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      _secure.write(key: _accessTokenKey, value: access),
      _secure.write(key: _refreshTokenKey, value: refresh),
    ]);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _secure.write(key: _userKey, value: jsonEncode(user.toJson()));
    _userStreamController.add(user);
  }

  @override
  Future<UserModel?> getUser() async {
    final data = await _secure.read(key: _userKey);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (_) {
      await _secure.delete(key: _userKey);
      return null;
    }
  }

  @override
  Future<void> savePendingSignup(SignupPendingEntity pending) async {
    await _secure.write(
      key: _pendingKey,
      value: jsonEncode({
        'channel': pending.channel.name,
        'destination': pending.destination,
        'message': pending.message,
      }),
    );
  }

  @override
  Future<SignupPendingEntity?> getPendingSignup() async {
    final raw = await _secure.read(key: _pendingKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SignupPendingEntity(
        channel: map['channel'] == 'phone'
            ? SignupChannel.phone
            : SignupChannel.email,
        destination: (map['destination'] as String?) ?? '',
        message: map['message'] as String?,
      );
    } catch (_) {
      await _secure.delete(key: _pendingKey);
      return null;
    }
  }

  @override
  Future<void> clearPendingSignup() => _secure.delete(key: _pendingKey);

  @override
  Future<void> clearAuthData() async {
    await Future.wait([
      _secure.delete(key: _accessTokenKey),
      _secure.delete(key: _refreshTokenKey),
      _secure.delete(key: _userKey),
      _secure.delete(key: _pendingKey),
    ]);
    _userStreamController.add(null);
  }

  @override
  Future<String?> getAccessToken() => _secure.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() => _secure.read(key: _refreshTokenKey);

  @override
  @disposeMethod
  void dispose() {
    _userStreamController.close();
  }
}
