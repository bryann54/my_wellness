// lib/features/account/presentation/widgets/account_menu_section.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/drop_down_field.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
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
          _buildLanguageSelector(context, theme.colorScheme.onSurface),
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
              // Identity lives on AuthBloc, not on UserProfile.
              final userId = context.read<AuthBloc>().state.user?.id;
              if (userId != null && userId.isNotEmpty) {
                // context.router.push(EmergencyContactsRoute(userId: userId));
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
              // context.router.push(MyDocumentsRoute());
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
              // Navigate to notifications settings
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

  Widget _buildLanguageSelector(BuildContext context, Color titleColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryColorDark
        : AppColors.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(Icons.language, size: 20, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.getString(context, 'settings.language'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: titleColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.getString(
                    context,
                    'settings.changeLanguage',
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
              onChanged: state.status == AccountStatus.updating
                  ? null
                  : (locale) {
                      if (locale != null) {
                        context.read<AccountBloc>().add(
                          ChangeLanguageEvent(langCode: locale.languageCode),
                        );
                      }
                    },
              hintText: AppLocalizations.getString(
                context,
                'language.selectLanguage',
              ),
              isEnabled: state.status != AccountStatus.updating,
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
  }
}
