import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

class LanguageSelectorRow extends StatelessWidget {
  final String? titleOverride;
  final String? subtitleOverride;
  final double iconContainerSize;

  const LanguageSelectorRow({
    super.key,
    this.titleOverride,
    this.subtitleOverride,
    this.iconContainerSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryColorDark
        : AppColors.primaryColor;
    final currentLocale = Localizations.localeOf(context);

    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        final isUpdating = state.status == AccountStatus.updating;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.language,
                  size: iconContainerSize * 0.5,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleOverride ??
                          AppLocalizations.getString(
                            context,
                            'settings.language',
                          ),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleOverride ??
                          AppLocalizations.getString(
                            context,
                            'settings.changeLanguage',
                          ),
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: DropDownWidget<Locale>(
                  label: '',
                  selectedItem: currentLocale,
                  items: DropDownWidget.languageItems(context),
                  onChanged: isUpdating
                      ? null
                      : (locale) {
                          if (locale != null &&
                              locale.languageCode !=
                                  currentLocale.languageCode) {
                            context.read<AccountBloc>().add(
                              ChangeLanguageEvent(
                                langCode: locale.languageCode,
                              ),
                            );
                          }
                        },
                  hintText: AppLocalizations.getString(
                    context,
                    'language.selectLanguage',
                  ),
                  isEnabled: !isUpdating,
                  showLabel: false,
                  filled: false,
                  isDense: true,
                  borderRadius: 5,
                  borderColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A compact language selector for tight rows
class LanguageSelectorCompact extends StatelessWidget {
  const LanguageSelectorCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = Localizations.localeOf(context);

    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        final isUpdating = state.status == AccountStatus.updating;

        return SizedBox(
          width: 130,
          child: DropDownWidget<Locale>(
            label: '',
            selectedItem: currentLocale,
            items: DropDownWidget.languageItems(context),
            onChanged: isUpdating
                ? null
                : (locale) {
                    if (locale != null &&
                        locale.languageCode != currentLocale.languageCode) {
                      context.read<AccountBloc>().add(
                        ChangeLanguageEvent(langCode: locale.languageCode),
                      );
                    }
                  },
            hintText: AppLocalizations.getString(
              context,
              'language.selectLanguage',
            ),
            isEnabled: !isUpdating,
            showLabel: false,
            filled: false,
            isDense: true,
            borderRadius: 5,
            borderColor: Colors.transparent,
            padding: EdgeInsets.zero,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: Icon(
                Icons.language,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
