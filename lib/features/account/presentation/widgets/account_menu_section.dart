import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/account_section_card.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/account/presentation/widgets/menu_item_tile.dart';

class AccountMenuSection extends StatelessWidget {
  const AccountMenuSection({
    super.key,
    required this.state,
    required this.currentLocale,
  });

  final AccountState state;
  final Locale currentLocale;

  @override
  Widget build(BuildContext context) {
    return AccountSectionCard(
      children: [
        MenuItemTile(
          icon: Icons.person_outline_rounded,
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
        const AccountSectionDivider(),
        MenuItemTile(
          icon: Icons.settings_outlined,
          title: AppLocalizations.getString(context, 'settings.title'),
          subtitle: AppLocalizations.getString(context, 'settings.subtitle'),
          onTap: () => context.router.push(const SettingsRoute()),
        ),
      ],
    );
  }
}
