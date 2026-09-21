// lib/features/auth/presentation/widgets/language_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/colors.dart'; // Using AppColors as requested
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        // Use the new enum status check
        final bool isLoading = state.status == AccountStatus.loading;
        final currentLocale = Localizations.localeOf(context);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 6),
              DropdownButton<Locale>(
                value: currentLocale,
                underline: const SizedBox(),
                icon: isLoading
                    ? _buildLoader(isDark)
                    : Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                isDense: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: isDark
                    ? AppColors.darkBackgroundColor
                    : Colors.white,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onChanged: isLoading
                    ? null
                    : (locale) {
                        if (locale != null &&
                            locale.languageCode != currentLocale.languageCode) {
                          context.read<AccountBloc>().add(
                            ChangeLanguageEvent(langCode: locale.languageCode),
                          );
                        }
                      },
                items: [
                  _buildDropdownItem(
                    context,
                    const Locale('en'),
                    'english',
                    '🇺🇸',
                  ),
                  _buildDropdownItem(
                    context,
                    const Locale('sw'),
                    'swahili',
                    '🇰🇪',
                  ),
                ],
                selectedItemBuilder: (context) => [
                  _buildSelectedText('EN', isDark),
                  _buildSelectedText('SW', isDark),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  DropdownMenuItem<Locale> _buildDropdownItem(
    BuildContext context,
    Locale locale,
    String labelKey,
    String flag,
  ) {
    return DropdownMenuItem(
      value: locale,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(AppLocalizations.getString(context, labelKey)),
        ],
      ),
    );
  }

  Widget _buildSelectedText(String code, bool isDark) {
    return Center(
      child: Text(
        code,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildLoader(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      width: 12,
      height: 12,
      child: CircularProgressIndicator.adaptive(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(
          isDark ? Colors.white70 : AppColors.primaryColor,
        ),
      ),
    );
  }
}
