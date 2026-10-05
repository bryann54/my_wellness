import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/account/presentation/widgets/dialogs/delete_account_dialog.dart';
import 'package:my_wellness/features/account/presentation/widgets/dialogs/logout_dialog.dart';
import 'package:my_wellness/features/account/presentation/widgets/menu_item_tile.dart';
import 'package:provider/provider.dart';

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
                // ── Preferences ────────────────────────────────────
                _SectionLabel(
                  label: AppLocalizations.getString(
                    context,
                    'settings.sectionPreferences',
                  ),
                ),
                _Card(
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
                    _divider(context),
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
                      onTap: () {
                        // TODO: push NotificationPreferencesRoute()
                      },
                    ),
                    _divider(context),
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

                // ── Account ────────────────────────────────────────
                _SectionLabel(
                  label: AppLocalizations.getString(
                    context,
                    'settings.sectionAccount',
                  ),
                ),
                _Card(
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
                    _divider(context),
                    MenuItemTile(
                      icon: Icons.logout_rounded,
                      title: AppLocalizations.getString(
                        context,
                        'settings.logOut',
                      ),
                      subtitle: AppLocalizations.getString(
                        context,
                        'settings.logOutSub',
                      ),
                      onTap: () => LogoutDialog.show(context),
                    ),
                  ],
                ),

                // ── Support ────────────────────────────────────────
                _SectionLabel(
                  label: AppLocalizations.getString(
                    context,
                    'settings.sectionSupport',
                  ),
                ),
                _Card(
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
                    _divider(context),
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    indent: 60,
    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
  );

  Future<void> _pickLanguage(BuildContext context) async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final current = provider.locale.languageCode;

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.getString(context, 'settings.language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (picked != null && context.mounted) {
      context.read<AccountBloc>().add(ChangeLanguageEvent(langCode: picked));
    }
  }
}

// ── Local widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
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

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }
}
