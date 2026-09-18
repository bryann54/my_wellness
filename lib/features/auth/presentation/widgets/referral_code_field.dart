// lib/features/auth/presentation/widgets/referral_code_field.dart

import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

class ReferralCodeField extends StatelessWidget {
  final TextEditingController controller;

  const ReferralCodeField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: AppLocalizations.getString(context, 'auth.referralCode'),
      icon: Icons.card_giftcard_outlined,
      validator: (_) => null,
    );
  }
}
