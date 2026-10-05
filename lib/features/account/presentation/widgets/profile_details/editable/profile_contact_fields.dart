import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/profile_read_only_row.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/profile_section_label.dart';

class ProfileContactFields extends StatelessWidget {
  final HealthProfile profile;
  final TextEditingController phoneController;

  const ProfileContactFields({
    super.key,
    required this.profile,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(
          AppLocalizations.getString(context, 'profile.contactSection'),
        ),
        const SizedBox(height: 10),
        SoftInput(
          controller: phoneController,
          label: AppLocalizations.getString(context, 'profile.phone'),
          hint: '+254 700 000 000',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
          ],
        ),
        const SizedBox(height: 12),
        ProfileReadOnlyRow(
          label: AppLocalizations.getString(context, 'profile.email'),
          value: profile.email,
          helper: AppLocalizations.getString(context, 'profile.emailLocked'),
        ),
      ],
    );
  }
}
