import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/storage/storage_preference_manager.dart';

/// Stores non-sensitive display preferences only.
///
/// Profile and health fields intentionally remain in memory; offline PHI
/// persistence has not been approved.
@lazySingleton
class AccountLocalDatasource {
  final SharedPreferencesManager _prefs;

  AccountLocalDatasource(this._prefs);

  Future<void> cacheLanguage(String code) =>
      _prefs.putString(SharedPreferencesManager.language, code);

  String getLanguage() =>
      _prefs.getString(SharedPreferencesManager.language) ?? 'en';

  Future<void> clearAllData() => _prefs.clearKey(SharedPreferencesManager.user);
}
