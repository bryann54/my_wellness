import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, dynamic> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static String getString(BuildContext context, String key) {
    return AppLocalizations.of(context)?.translate(key) ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/lang/${locale.languageCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap;
      return true;
    } catch (e) {
      print('Error loading translations: $e');
      return false;
    }
  }

  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key;
      }
    }

    return value?.toString() ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'sw'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
