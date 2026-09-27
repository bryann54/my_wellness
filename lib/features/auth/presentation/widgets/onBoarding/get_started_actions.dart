import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/terms_privacy_text.dart';

class GetStartedActions extends StatelessWidget {
  const GetStartedActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPrimaryButton(
          label: AppLocalizations.getString(context, 'auth.signUpLink'),
          onPressed: () => context.router.push(const RegisterRoute()),
          color: AppColors.primaryColor,
          borderRadius: 12,
          height: 52,
        ),
        const SizedBox(height: 12),
        AppPrimaryButton(
          label: AppLocalizations.getString(context, 'auth.signInLink'),
          onPressed: () => context.router.push(const LoginRoute()),
          color: AppColors.textPrimaryDark,
          textColor: cs.primary,
          borderRadius: 12,
          height: 52,
        ),
        const SizedBox(height: 16),
        const TermsPrivacyText(),
      ],
    );
  }
}
