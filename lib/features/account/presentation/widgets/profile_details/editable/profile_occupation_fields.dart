import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/profile_read_only_row.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/profile_section_label.dart';

class ProfileOccupationFields extends StatelessWidget {
  final HealthProfile profile;
  final TextEditingController occupationController;

  const ProfileOccupationFields({
    super.key,
    required this.profile,
    required this.occupationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(
          AppLocalizations.getString(context, 'profile.occupationSection'),
        ),
        const SizedBox(height: 10),
        SoftInput(
          controller: occupationController,
          label: AppLocalizations.getString(context, 'profile.occupation'),
          hint: AppLocalizations.getString(context, 'profile.occupationHint'),
        ),
        const SizedBox(height: 12),
        ProfileReadOnlyRow(
          label: AppLocalizations.getString(context, 'profile.memberCode'),
          value: profile.memberCode,
          helper: AppLocalizations.getString(
            context,
            'profile.memberCodeLocked',
          ),
        ),
      ],
    );
  }
}
