import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key, this.mode = LanguageSelectorMode.compact});

  final LanguageSelectorMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (p, c) =>
          p.currentLang != c.currentLang || p.status != c.status,
      builder: (context, state) {
        final current = Localizations.localeOf(context);
        final isBusy = state.status == AccountStatus.updating;

        return switch (mode) {
          LanguageSelectorMode.compact => _Compact(
            current: current,
            isBusy: isBusy,
          ),
          LanguageSelectorMode.inline => _Inline(
            current: current,
            isBusy: isBusy,
          ),
        };
      },
    );
  }
}

enum LanguageSelectorMode { compact, inline }

class _Compact extends StatelessWidget {
  const _Compact({required this.current, required this.isBusy});
  final Locale current;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopupMenuButton<Locale>(
      enabled: !isBusy,
      tooltip: AppLocalizations.getString(context, 'language.selectLanguage'),
      position: PopupMenuPosition.under,
      onSelected: (locale) => _setLang(context, locale),
      itemBuilder: (context) => _menuItems(context, current),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              current.languageCode.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Inline extends StatelessWidget {
  const _Inline({required this.current, required this.isBusy});
  final Locale current;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: isBusy ? null : () => _openPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(Icons.language, size: 20, color: cs.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                AppLocalizations.getString(context, 'language.selectLanguage'),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Text(
              current.languageCode.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(color: cs.primary),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            for (final locale in const [Locale('en'), Locale('sw')])
              ListTile(
                title: Text(_label(locale)),
                trailing:
                    locale.languageCode ==
                        Localizations.localeOf(context).languageCode
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  _setLang(context, locale);
                },
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

List<PopupMenuEntry<Locale>> _menuItems(BuildContext context, Locale current) {
  return [
    for (final locale in const [Locale('en'), Locale('sw')])
      PopupMenuItem<Locale>(
        value: locale,
        child: Row(
          children: [
            Expanded(child: Text(_label(locale))),
            if (locale.languageCode == current.languageCode)
              Icon(
                Icons.check,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
  ];
}

String _label(Locale locale) => switch (locale.languageCode) {
  'sw' => 'Kiswahili',
  _ => 'English',
};

void _setLang(BuildContext context, Locale locale) {
  if (locale.languageCode == Localizations.localeOf(context).languageCode) {
    return;
  }
  context.read<AccountBloc>().add(
    ChangeLanguageEvent(langCode: locale.languageCode),
  );
}
