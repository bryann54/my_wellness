import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/common/widgets/language_selector_row.dart';
import 'package:my_wellness/features/account/presentation/widgets/menu_item_tile.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';

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
                context.router.push(EditProfileRoute(profile: profile));
              }
            },
          ),
          _buildDivider(context),
          const LanguageSelectorRow(),
          _buildDivider(context),
          MenuItemTile(
            icon: Icons.payment_outlined,
            title: AppLocalizations.getString(context, 'settings.subscription'),
            subtitle: AppLocalizations.getString(
              context,
              'subscription.manage',
            ),
            onTap: () {
              context.router.push(SubscriptionsRoute());
            },
          ),
          _buildDivider(context),
          MenuItemTile(
            icon: Icons.contact_phone_outlined,
            title: AppLocalizations.getString(
              context,
              'profile.emergencyContacts',
            ),
            subtitle: AppLocalizations.getString(
              context,
              'profile.editEmergencyContact',
            ),
            onTap: () {
              final userId = context.read<AuthBloc>().state.user?.id;
              if (userId != null && userId.isNotEmpty) {
                // TODO: push EmergencyContactsRoute(userId: userId)
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('User profile not loaded'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
          ),
          _buildDivider(context),
          MenuItemTile(
            icon: Icons.description_outlined,
            title: AppLocalizations.getString(context, 'documents.myDocuments'),
            subtitle: AppLocalizations.getString(
              context,
              'documents.myDocuments',
            ),
            onTap: () {
              // TODO: push MyDocumentsRoute
            },
          ),
          _buildDivider(context),
          MenuItemTile(
            icon: Icons.settings_outlined,
            title: AppLocalizations.getString(context, 'settings.title'),
            subtitle: AppLocalizations.getString(
              context,
              'settings.alertPreferences',
            ),
            onTap: () {
              // TODO: navigate to notification settings
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
