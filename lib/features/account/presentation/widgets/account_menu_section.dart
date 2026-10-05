import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/account/presentation/widgets/menu_item_tile.dart';

class AccountMenuSection extends StatelessWidget {
  final AccountState state;
  final Locale currentLocale;

  const AccountMenuSection({
    super.key,
    required this.state,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
        MenuItemTile(
            icon: Icons.person_outline,
            title: AppLocalizations.getString(context, 'profile.editProfile'),
            subtitle: AppLocalizations.getString(
              context,
              'profile.accountDetails',
            ),
            onTap: () {
              final profile = state.profile;
              if (profile != null) {
                context.router.push(ProfileDetailsRoute(profile: profile));
              }
            },
          ),
          _buildDivider(context),
          MenuItemTile(
            icon: Icons.settings_outlined,
            title: AppLocalizations.getString(context, 'settings.title'),
            subtitle: AppLocalizations.getString(
              context,
              'settings.subtitle', 
            ),
            onTap: () => context.router.push(const SettingsRoute()),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 60,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
    );
  }
}
