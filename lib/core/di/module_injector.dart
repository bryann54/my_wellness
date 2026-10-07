import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wellness/features/notifications/data/notification_service.dart';

@module
abstract class RegisterModules {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @Named('BaseUrl')
  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  NotificationService get notificationService =>
      NotificationService(dotenv.env['ONESIGNAL_APP_ID'] ?? '');
}
