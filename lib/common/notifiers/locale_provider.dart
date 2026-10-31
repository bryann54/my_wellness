import 'dart:async';
import 'dart:developer';

import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/core/storage/storage_preference_manager.dart';
import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = Locale('en');
  Locale get locale => _locale;

  void loadLocale() {
    final String langCode =
        getIt<SharedPreferencesManager>().getString(
          SharedPreferencesManager.language,
        ) ??
        'en';
    log('LangCode: $langCode');
    _locale = Locale(langCode);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    unawaited(
      getIt<SharedPreferencesManager>().putString(
        SharedPreferencesManager.language,
        locale.languageCode,
      ),
    );
  }
}
