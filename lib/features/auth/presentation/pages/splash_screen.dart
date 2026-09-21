// lib/features/auth/presentation/pages/splash_screen.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/core/services/pin_service.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/bloc/biometrics/biometrics_bloc.dart';
import 'package:my_wellness/features/auth/presentation/widgets/security_setup_sheet.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash_content.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _sheetShown = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  void _onAuthStateChanged(AuthState state) {
    if (state.status == AuthStatus.authenticated && !_sheetShown) {
      _sheetShown = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          // Fire biometrics silently — NO sheet yet, just the system prompt
          context.read<BiometricsBloc>().add(CheckBiometrics());
        }
      });
    } else if (state.status == AuthStatus.unauthenticated ||
        state.status == AuthStatus.error) {
      // LanguageSelectionRoute
      // context.router.replace(const LoginRoute());
      context.router.replace(const AuthRoute());
    }
  }

  // Only shown on failure — retry or PIN
  void _showFailureSheet() {
    final username = context.read<AccountBloc>().state.profile?.displayName;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<BiometricsBloc>(),
        child: _FailureSheet(username: username),
      ),
    );
  }

  Future<void> _postAuthNavigation() async {
    // 1. Check for PIN
    final hasPin = await PinService().hasPin();
    if (!mounted) return;
    if (!hasPin) await SecuritySetupSheet.show(context);
    if (!mounted) return;
    context.read<AccountBloc>().add(const FetchProfileEvent());
    await Future.wait([Future.delayed(const Duration(milliseconds: 1500))]);

    if (!mounted) return;

    // 4. Navigate
    context.router.replace(const MainRoute());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (_, state) => _onAuthStateChanged(state),
        ),
        BlocListener<BiometricsBloc, BiometricsState>(
          listener: (_, state) async {
            if (state.isAuthenticated && mounted) {
              await _postAuthNavigation();
            } else if (state.status == BiometricsStatus.error && mounted) {
              // Silent attempt failed — now show the sheet
              _showFailureSheet();
            } else if (state.status == BiometricsStatus.pinFallback &&
                mounted) {
              // No biometrics on device — show sheet directly on PIN
              _showFailureSheet();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackgroundColor
            : AppColors.lightBackgroundColor,
        body: const Center(child: SplashContent()),
      ),
    );
  }
}

// ── Failure sheet — shown only after silent biometric attempt fails ────────────

class _FailureSheet extends StatelessWidget {
  final String? username;
  const _FailureSheet({this.username});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<BiometricsBloc, BiometricsState>(
      listener: (context, state) async {
        if (state.isAuthenticated) {
          // Authenticated via PIN — close sheet and proceed
          Navigator.pop(context);
          final splashState = context
              .findAncestorStateOfType<_SplashScreenState>();
          await splashState?._postAuthNavigation();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Greeting
              if (username != null) ...[
                Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.syne(
                            fontSize: 22,
                            color: cs.onSurface,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Hello, ',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            TextSpan(
                              text: '$username 👋',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.05, curve: Curves.easeOut),
                const SizedBox(height: 16),
                Divider(color: cs.outlineVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 8),

              // Content switches between error and PIN
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: state.status == BiometricsStatus.pinFallback
                    ? const _PinFallback()
                    : _ErrorPrompt(state: state),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Error prompt — retry biometrics or fall back to PIN ───────────────────────

class _ErrorPrompt extends StatelessWidget {
  final BiometricsState state;
  const _ErrorPrompt({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading =
        state.status == BiometricsStatus.authenticating ||
        state.status == BiometricsStatus.checking;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: cs.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                  )
                : FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 30,
                    color: cs.onErrorContainer,
                  ),
          ),
        ).animate().scale(duration: 350.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Text(
          'Authentication Failed',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We couldn\'t verify your identity.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 32),
        AppPrimaryButton(
          onPressed: isLoading
              ? null
              : () => context.read<BiometricsBloc>().add(
                  AuthenticateWithBiometrics(),
                ),
          label: 'Try Again',
          icon: Icons.fingerprint_rounded,
          isLoading: isLoading,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => context.read<BiometricsBloc>().add(FallbackToPin()),
          child: Text(
            'Use PIN instead',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(const SignOutEvent());
          },
          child: Text(
            'Sign in with a different account',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }
}

// ── PIN fallback ──────────────────────────────────────────────────────────────

class _PinFallback extends StatefulWidget {
  const _PinFallback();

  @override
  State<_PinFallback> createState() => _PinFallbackState();
}

class _PinFallbackState extends State<_PinFallback> {
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
    final error = context.select((BiometricsBloc b) => b.state.errorMessage);
    final isLoading = context.select(
      (BiometricsBloc b) => b.state.status == BiometricsStatus.pinVerifying,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter Your PIN',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your PIN to access your account.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: cs.onSurface.withValues(alpha: 0.55),
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
          style: GoogleFonts.inter(fontSize: 24, letterSpacing: 8),
          decoration: InputDecoration(
            counterText: '',
            hintText: '······',
            hintStyle: GoogleFonts.inter(
              fontSize: 24,
              letterSpacing: 8,
              color: cs.onSurface.withValues(alpha: 0.2),
            ),
            filled: true,
            fillColor: cs.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorText: error,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 20),
        AppPrimaryButton(
          onPressed: _submit,
          label: 'Verify',
          isLoading: isLoading,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(const SignOutEvent());
          },
          child: Text(
            'Sign in with a different account',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}
