// lib/features/auth/presentation/widgets/onboarding_language_selector.dart

import 'package:flutter/material.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool isDark;

  const LanguageSelector({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: provider.locale,
          icon: Icon(
            Icons.language,
            size: 18,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          dropdownColor: isDark ? AppColors.primaryColor : AppColors.cardColor,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: [
            DropdownMenuItem(
              value: const Locale('en'),
              child: Text(
                AppLocalizations.getString(context, 'language.english'),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            DropdownMenuItem(
              value: const Locale('es'),
              child: Text(
                AppLocalizations.getString(context, 'language.spanish'),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
          onChanged: (locale) {
            if (locale != null) {
              provider.setLocale(locale);
            }
          },
        ),
      ),
    );
  }
}
