// ═════════════════════════════════════════════════════════════════════════════
// Get started actions — always visible
// ═════════════════════════════════════════════════════════════════════════════

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/getstarted_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/terms_privacy_text.dart';

class GetStartedActions extends StatelessWidget {
  const GetStartedActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GetStartedButton(
          text: AppLocalizations.getString(context, 'auth.signInLink'),
          onPressed: () => context.router.replace(const LoginRoute()),
          backgroundColor: AppColors.primaryColor,
        ),
        const SizedBox(height: 6),
        GetStartedButton(
          text: AppLocalizations.getString(context, 'auth.signUpLink'),
          onPressed: () => context.router.replace( RegisterRoute()),
          backgroundColor: AppColors.dividerColorDark.withValues(alpha: 0.07),
          textColor: cs.tertiary.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 16),
        const TermsPrivacyText(),
      ],
    );
  }
}
