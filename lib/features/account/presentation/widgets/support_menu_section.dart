import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/account_section_card.dart';
import 'package:my_wellness/features/account/presentation/widgets/menu_item_tile.dart';

class SupportMenuSection extends StatelessWidget {
  const SupportMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountSectionCard(
      children: [
        MenuItemTile(
          icon: Icons.lock_outline_rounded,
          title: AppLocalizations.getString(context, 'auth.forgotPassword'),
          subtitle: AppLocalizations.getString(context, 'auth.resetPassword'),
          onTap: () => context.router.push(const ForgotPasswordRoute()),
        ),
        const AccountSectionDivider(),
        MenuItemTile(
          icon: Icons.description_outlined,
          title: AppLocalizations.getString(context, 'profile.eula'),
          subtitle: AppLocalizations.getString(context, 'profile.viewEULA'),
          onTap: () {
            // TODO: open terms webview
          },
        ),
        const AccountSectionDivider(),
        MenuItemTile(
          icon: Icons.help_outline_rounded,
          title: AppLocalizations.getString(context, 'profile.getHelp'),
          subtitle: AppLocalizations.getString(context, 'profile.getHelpSub'),
          onTap: () {
            // TODO: open support webview or chat
          },
        ),
      ],
    );
  }
}
