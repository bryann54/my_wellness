import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  static final Map<String, AppLocalizations> _cache = {};
  final Locale locale;
  Map<String, dynamic> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Legacy lookup. Prefer [t] for new code.
  static String getString(BuildContext context, String key) {
    return AppLocalizations.of(context)?.translate(key) ?? key;
  }

  /// Preferred API. Supports `{placeholder}` interpolation:
  ///
  ///   AppLocalizations.t(context, 'assessment.searchResultCountMany',
  ///       {'count': '4', 'query': 'breast'});
  static String t(
    BuildContext context,
    String key, [
    Map<String, String>? params,
  ]) {
    return AppLocalizations.of(context)?.translate(key, params) ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Future<void> preloadSupportedLocales() async {
    await Future.wait([
      for (final locale in const [Locale('en'), Locale('sw')])
        _loadAndCache(locale),
    ]);
  }

  static Future<AppLocalizations> _loadAndCache(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    _cache[locale.languageCode] = localizations;
    return localizations;
  }

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

  String translate(String key, [Map<String, String>? params]) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key;
      }
    }

    var out = value?.toString() ?? key;

    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) {
        out = out.replaceAll('{$k}', v);
      });
    }

    return out;
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
    final cached = AppLocalizations._cache[locale.languageCode];
    if (cached != null) return SynchronousFuture(cached);
    return AppLocalizations._loadAndCache(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
