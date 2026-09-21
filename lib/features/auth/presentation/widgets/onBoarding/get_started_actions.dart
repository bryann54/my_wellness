import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_divider.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/terms_privacy_text.dart';

class GetStartedActions extends StatelessWidget {
  const GetStartedActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPrimaryButton(
          label: AppLocalizations.getString(context, 'auth.signInLink'),
          onPressed: () => context.router.replace(const LoginRoute()),
          color: AppColors.primaryColor,
          borderRadius: 12,
        ),
        const SizedBox(height: 6),
        AuthDivider(text: AppLocalizations.getString(context, 'common.or')),
        AppPrimaryButton(
          label: AppLocalizations.getString(context, 'auth.signUpLink'),
          onPressed: () => context.router.replace(RegisterRoute()),
          color: AppColors.dividerColorDark.withValues(alpha: 0.07),
          textColor: cs.tertiary.withValues(alpha: 0.7),
          borderRadius: 12,
        ),
        const SizedBox(height: 16),
        const TermsPrivacyText(),
      ],
    );
  }
}
