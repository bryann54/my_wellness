import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/widgets/menu_item_tile.dart';
import 'package:my_wellness/features/account/presentation/widgets/password_reset_dialog.dart';

class SupportMenuSection extends StatelessWidget {
  const SupportMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          MenuItemTile(
            icon: Icons.lock_outline,
            title: AppLocalizations.getString(context, 'auth.forgotPassword'),
            subtitle: AppLocalizations.getString(context, 'auth.resetPassword'),
            onTap: () => showPasswordResetDialog(context),
          ),
          _buildDivider(context),
          MenuItemTile(
            icon: Icons.description_outlined,
            title: AppLocalizations.getString(context, 'profile.eula'),
            subtitle: AppLocalizations.getString(context, 'profile.viewEULA'),
            onTap: () {
              // TODO: open terms webview
            },
          ),
          _buildDivider(context),
          MenuItemTile(
            icon: Icons.help_outline,
            title: AppLocalizations.getString(context, 'profile.getHelp'),
            subtitle: AppLocalizations.getString(context, 'profile.getHelpSub'),
            onTap: () {
              // TODO: open support webview or chat
            },
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
