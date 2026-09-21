// lib/features/auth/presentation/widgets/terms_privacy_text.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';

class TermsPrivacyText extends StatelessWidget {
  const TermsPrivacyText({super.key});

  void _openTerms(BuildContext context) {
    context.router.push(
      WebViewRoute(
        url: 'https://staging.mywellnesshealth.co.ke/terms',
        title: AppLocalizations.getString(context, 'auth.termsOfService'),
      ),
    );
  }

  void _openPrivacy(BuildContext context) {
    context.router.push(
      WebViewRoute(
        url: 'https://staging.mywellnesshealth.co.ke/data-protection',
        title: AppLocalizations.getString(context, 'auth.privacyPolicy'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: cs.onSurface.withValues(alpha: 0.5),
      height: 1.5,
    );
    final linkStyle = baseStyle?.copyWith(
      color: cs.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: cs.primary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(
              text: AppLocalizations.getString(
                context,
                'auth.byContinuingYouAgree',
              ),
            ),
            TextSpan(
              text: AppLocalizations.getString(context, 'auth.termsOfService'),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openTerms(context),
            ),
            TextSpan(text: AppLocalizations.getString(context, 'auth.andOur')),
            TextSpan(
              text: AppLocalizations.getString(context, 'auth.privacyPolicy'),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openPrivacy(context),
            ),
          ],
        ),
      ),
    );
  }
}
