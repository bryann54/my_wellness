import 'package:flutter/material.dart';

import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/core/storage/storage_preference_manager.dart';

class ThemeProvider with ChangeNotifier {
  static const String _key = 'themeMode';

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;
  void load() {
    final stored = getIt<SharedPreferencesManager>().getString(_key);
    _mode = _decode(stored);
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await getIt<SharedPreferencesManager>().putString(_key, _encode(mode));
  }

  static String _encode(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _decode(String? raw) => switch (raw) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };
}
