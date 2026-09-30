import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/biometrics/biometrics_bloc.dart';

class SplashBiometricPrompt extends StatelessWidget {
  final BiometricsState state;
  const SplashBiometricPrompt({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final busy =
        state.status == BiometricsStatus.authenticating ||
        state.status == BiometricsStatus.checking;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2.5,
                      ),
                    )
                  : FaIcon(
                      FontAwesomeIcons.fingerprint,
                      size: 30,
                      color: cs.primary,
                    ),
            ),
          ).animate().scale(duration: 320.ms, curve: Curves.elasticOut),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.getString(context, 'auth.biometricsPrompt'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.errorMessage ??
              AppLocalizations.getString(context, 'auth.tryPinFallback'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            height: 1.5,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 28),
        AppPrimaryButton(
          borderRadius: 12,
          color: AppColors.primaryColor,
          onPressed: busy
              ? null
              : () => context.read<BiometricsBloc>().add(
                  AuthenticateWithBiometrics(),
                ),
          label: AppLocalizations.getString(context, 'auth.biometrics'),
          icon: Icons.fingerprint_rounded,
          isLoading: busy,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => context.read<BiometricsBloc>().add(FallbackToPin()),
          child: Text(
            AppLocalizations.getString(context, 'auth.tryPinFallback'),
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => context.read<AuthBloc>().add(const SignOutEvent()),
          child: Text(
            AppLocalizations.getString(context, 'auth.logout'),
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }
}
