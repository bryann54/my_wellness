import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/notifiers/theme_provider.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/account_section_card.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/account/presentation/widgets/dialogs/delete_account_dialog.dart';
import 'package:my_wellness/features/account/presentation/widgets/dialogs/logout_dialog.dart';
import 'package:my_wellness/features/account/presentation/widgets/menu_item_tile.dart';
import 'package:my_wellness/features/notifications/presentation/widgets/notification_permission_sheet.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'settings.title'),
            isHome: false,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  label: AppLocalizations.getString(
                    context,
                    'settings.sectionPreferences',
                  ),
                ),
                AccountSectionCard(
                  children: [
                    MenuItemTile(
                      icon: Icons.translate_rounded,
                      title: AppLocalizations.getString(
                        context,
                        'settings.language',
                      ),
                      subtitle: AppLocalizations.getString(
                        context,
                        'settings.languageSub',
                      ),
                      onTap: () => _pickLanguage(context),
                    ),
                    const AccountSectionDivider(),
                    Consumer<ThemeProvider>(
                      builder: (context, theme, _) => MenuItemTile(
                        icon: Icons.dark_mode_outlined,
                        title: AppLocalizations.getString(
                          context,
                          'settings.theme',
                        ),
                        subtitle: _themeLabel(context, theme.mode),
                        onTap: () => _pickTheme(context),
                      ),
                    ),
                    const AccountSectionDivider(),
                    MenuItemTile(
                      icon: Icons.notifications_none_rounded,
                      title: AppLocalizations.getString(
                        context,
                        'settings.alertPreferences',
                      ),
                      subtitle: AppLocalizations.getString(
                        context,
                        'settings.alertPreferencesSub',
                      ),
                      onTap: () => NotificationPermissionSheet.show(context),
                    ),
                    const AccountSectionDivider(),
                    MenuItemTile(
                      icon: Icons.lock_outline_rounded,
                      title: AppLocalizations.getString(
                        context,
                        'settings.security',
                      ),
                      subtitle: AppLocalizations.getString(
                        context,
                        'settings.securitySub',
                      ),
                      onTap: () {
                        // TODO: push SecuritySettingsRoute()
                      },
                    ),
                  ],
                ),

                _SectionLabel(
                  label: AppLocalizations.getString(
                    context,
                    'settings.sectionAccount',
                  ),
                ),
                AccountSectionCard(
                  children: [
                    MenuItemTile(
                      icon: Icons.privacy_tip_outlined,
                      title: AppLocalizations.getString(
                        context,
                        'settings.privacy',
                      ),
                      subtitle: AppLocalizations.getString(
                        context,
                        'settings.privacySub',
                      ),
                      onTap: () {
                        // TODO: push PrivacySettingsRoute()
                      },
                    ),
                    const AccountSectionDivider(),
                    MenuItemTile(
                      icon: Icons.logout_rounded,
                      title: AppLocalizations.getString(context, 'auth.logout'),
                      subtitle: AppLocalizations.getString(
                        context,
                        'auth.logOutSub',
                      ),
                      onTap: () => LogoutDialog.show(context),
                    ),
                  ],
                ),

                _SectionLabel(
                  label: AppLocalizations.getString(
                    context,
                    'settings.sectionSupport',
                  ),
                ),
                AccountSectionCard(
                  children: [
                    MenuItemTile(
                      icon: Icons.info_outline_rounded,
                      title: AppLocalizations.getString(
                        context,
                        'settings.about',
                      ),
                      subtitle: AppLocalizations.getString(
                        context,
                        'settings.aboutSub',
                      ),
                      onTap: () {
                        // TODO: push AboutRoute()
                      },
                    ),
                    const AccountSectionDivider(),
                    MenuItemTile(
                      icon: Icons.delete_outline_rounded,
                      title: AppLocalizations.getString(
                        context,
                        'settings.deleteAccount',
                      ),
                      subtitle: AppLocalizations.getString(
                        context,
                        'settings.deleteAccountSub',
                      ),
                      iconColor: cs.error,
                      titleColor: cs.error,
                      onTap: () => DeleteAccountDialog.show(context),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.light => AppLocalizations.getString(
      context,
      'settings.themeLight',
    ),
    ThemeMode.dark => AppLocalizations.getString(context, 'settings.themeDark'),
    ThemeMode.system => AppLocalizations.getString(
      context,
      'settings.themeSystem',
    ),
  };

  Future<void> _pickLanguage(BuildContext context) async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final current = provider.locale.languageCode;

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(context),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.getString(context, 'settings.language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioListTile<String>(
              value: 'en',
              groupValue: current,
              title: Text(
                AppLocalizations.getString(context, 'language.english'),
              ),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
            RadioListTile<String>(
              value: 'sw',
              groupValue: current,
              title: Text(
                AppLocalizations.getString(context, 'language.swahili'),
              ),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );

    if (picked != null && context.mounted) {
      context.read<AccountBloc>().add(ChangeLanguageEvent(langCode: picked));
    }
  }

  Future<void> _pickTheme(BuildContext context) async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    final current = provider.mode;

    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(context),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.getString(context, 'settings.theme'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: current,
              title: Text(
                AppLocalizations.getString(context, 'settings.themeLight'),
              ),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: current,
              title: Text(
                AppLocalizations.getString(context, 'settings.themeDark'),
              ),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: current,
              title: Text(
                AppLocalizations.getString(context, 'settings.themeSystem'),
              ),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );

    if (picked != null && context.mounted) {
      await provider.setMode(picked);
    }
  }

  Widget _sheetHandle(BuildContext context) => Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
