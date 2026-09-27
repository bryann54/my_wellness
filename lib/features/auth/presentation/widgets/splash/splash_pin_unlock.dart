import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/biometrics/biometrics_bloc.dart';

class SplashPinUnlock extends StatefulWidget {
  const SplashPinUnlock({super.key});

  @override
  State<SplashPinUnlock> createState() => _SplashPinUnlockState();
}

class _SplashPinUnlockState extends State<SplashPinUnlock> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.length >= 4) {
      context.read<BiometricsBloc>().add(VerifyPin(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final error = context.select<BiometricsBloc, String?>(
      (b) => b.state.errorMessage,
    );
    final busy = context.select<BiometricsBloc, bool>(
      (b) => b.state.status == BiometricsStatus.pinVerifying,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lock,
                size: 28,
                color: cs.onPrimaryContainer,
              ),
            ),
          ).animate().scale(duration: 320.ms, curve: Curves.elasticOut),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.getString(context, 'auth.enterPin'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.getString(context, 'auth.tryPinFallback'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            height: 1.5,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          focusNode: _focus,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(fontSize: 26, letterSpacing: 10),
          decoration: InputDecoration(
            counterText: '',
            hintText: '······',
            hintStyle: GoogleFonts.inter(
              fontSize: 22,
              letterSpacing: 8,
              color: cs.onSurface.withValues(alpha: 0.18),
            ),
            filled: true,
            fillColor: cs.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorText: error,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 20),
        AppPrimaryButton(
          onPressed: busy ? null : _submit,
          label: AppLocalizations.getString(context, 'auth.biometrics'),
          isLoading: busy,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () =>
              context.read<BiometricsBloc>().add(AuthenticateWithBiometrics()),
          child: Text(
            AppLocalizations.getString(context, 'auth.biometrics'),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.45),
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
