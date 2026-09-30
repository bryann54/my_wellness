import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final base = GoogleFonts.inter(
      fontSize: 12,
      height: 1.5,
      color: cs.onSurface.withValues(alpha: 0.55),
    );
    final link = base.copyWith(color: cs.primary, fontWeight: FontWeight.w600);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: base,
        children: [
          TextSpan(
            text: AppLocalizations.getString(
              context,
              'auth.byContinuingYouAgree',
            ),
          ),
          TextSpan(
            text: AppLocalizations.getString(context, 'auth.termsOfService'),
            style: link,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openTerms(context),
          ),
          TextSpan(text: AppLocalizations.getString(context, 'auth.andOur')),
          TextSpan(
            text: AppLocalizations.getString(context, 'auth.privacyPolicy'),
            style: link,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openPrivacy(context),
          ),
        ],
      ),
    );
  }
}
