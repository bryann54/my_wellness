// lib/features/auth/presentation/widgets/language_dropdown.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';

enum AppLanguage {
  en('English', Locale('en')),
  es('Swahili', Locale('sw'));

  final String displayName;
  final Locale locale;

  const AppLanguage(this.displayName, this.locale);

  String get apiValue => name;

  // Helper to get enum from Locale
  static AppLanguage fromLocale(Locale locale) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.locale.languageCode == locale.languageCode,
      orElse: () => AppLanguage.en,
    );
  }
}

class LanguageDropdown extends StatelessWidget {
  final AppLanguage? selectedLanguage;
  final ValueChanged<AppLanguage?> onChanged;
  final bool isEnabled;
  final String? errorText;

  const LanguageDropdown({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
    this.isEnabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final items = AppLanguage.values.map((lang) {
      return DropdownMenuItem<AppLanguage>(
        value: lang,
        child: Text(lang.displayName),
      );
    }).toList();

    return DropDownWidget<AppLanguage>(
      label: AppLocalizations.getString(context, 'auth.language'),
      selectedItem: selectedLanguage,
      items: items,
      onChanged: isEnabled
          ? (language) {
              if (language != null) {
                context.read<LocaleProvider>().setLocale(language.locale);
                onChanged(language);
              }
            }
          : null,
      errorText: errorText,
      isRequired: true,
      isDense: true,
      borderColor: Colors.grey[300],
      prefixIcon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FaIcon(
          FontAwesomeIcons.globe,
          size: 16,
          color: Colors.grey[500],
        ),
      ),
      validator: (value) {
        if (value == null) {
          return AppLocalizations.getString(context, 'validation.required');
        }
        return null;
      },
    );
  }
}
