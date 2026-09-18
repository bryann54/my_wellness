// lib/core/di/register_module.dart

import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModules {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @Named('BaseUrl')
  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @Named('rcApiKey')
  String get rcApiKey => Platform.isIOS
      ? (dotenv.env['PUBLIC_REVENUECAT_API_KEY_IOS'] ?? '')
      : (dotenv.env['PUBLIC_REVENUECAT_API_KEY_ANDROID'] ?? '');
}
