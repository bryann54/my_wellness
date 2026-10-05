import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/identity/update_identity_sheet.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/profile_read_only_row.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/profile_section_card.dart';

class VerifiedIdentitySection extends StatelessWidget {
  final HealthProfile profile;
  const VerifiedIdentitySection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {

    return ProfileSectionCard(
      icon: Icons.verified_user_outlined,
      title: AppLocalizations.getString(context, 'profile.verifiedIdentity'),
      subtitle: AppLocalizations.getString(
        context,
        'profile.verifiedIdentityHelp',
      ),
      children: [
        ProfileReadOnlyRow(
          label: AppLocalizations.getString(context, 'profile.fullName'),
          value: profile.fullName,
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProfileReadOnlyRow(
                label: AppLocalizations.getString(context, 'profile.gender'),
                value: _genderLabel(context, profile.gender),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileReadOnlyRow(
                label: AppLocalizations.getString(
                  context,
                  'profile.dateOfBirth',
                ),
                value: profile.dateOfBirth ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ProfileReadOnlyRow(
          label: AppLocalizations.getString(context, 'profile.nationalId'),
          value: profile.nationalIdNumber ?? '—',
        ),
        const SizedBox(height: 18),
     AppPrimaryButton(
        onPressed: () => UpdateIdentitySheet.show(context),
        label: AppLocalizations.getString(context, 'profile.updateIdentity'),
        borderRadius: 12,
        color:AppColors.primaryColor,
      ),
      ],
    );
  }

  static String _genderLabel(BuildContext context, String raw) {
    if (raw.isEmpty) return '—';
    final key = 'profile.gender.$raw';
    final localized = AppLocalizations.getString(context, key);
    return localized == key ? raw : localized;
  }
}
