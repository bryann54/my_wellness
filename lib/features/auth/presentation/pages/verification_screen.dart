import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/otp_input.dart';

@RoutePage()
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, this.pending});

  final SignupPendingEntity? pending;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _otpKey = GlobalKey<OtpInputState>();
  String _code = '';
  String? _errorText;
  Timer? _resendTimer;
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  bool get _isComplete => _code.length == 6;

  void _submit(SignupPendingEntity pending) {
    if (!_isComplete) {
      setState(() => _errorText = 'Enter all 6 digits');
      return;
    }
    setState(() => _errorText = null);

    if (pending.channel == SignupChannel.phone) {
      context.read<AuthBloc>().add(
        ConfirmSignupPhoneEvent(phone: pending.destination, code: _code),
      );
    } else {
      context.read<AuthBloc>().add(
        ConfirmSignupEmailEvent(email: pending.destination, code: _code),
      );
    }
  }

  void _resend(SignupPendingEntity pending) {
    if (_resendSeconds > 0) return;
    _startResendCooldown();
    if (pending.channel == SignupChannel.phone) {
      context.read<AuthBloc>().add(
        ResendSignupPhoneEvent(phone: pending.destination),
      );
    } else {
      context.read<AuthBloc>().add(
        ResendSignupEmailEvent(email: pending.destination),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated &&
              state.pendingSignup == null) {
            AppSnackbar.success(context, 'Verification complete.');
          }
          if (state.status == AuthStatus.authenticated) {
            AppSnackbar.success(context, 'Account verified.');
            context.read<AppLockBloc>().add(const AppLockSignedIn());
            context.router.replaceAll([const MainRoute()]);
          }
          if (state.status == AuthStatus.awaitingSignupConfirmation &&
              state.errorMessage != null) {
            setState(() => _errorText = state.errorMessage);
            _otpKey.currentState?.clear();
            AppSnackbar.error(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          final pending = widget.pending ?? state.pendingSignup;
          if (pending == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final isPhone = pending.channel == SignupChannel.phone;
          final isLoading = state.status == AuthStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeader(
                    title: AppLocalizations.getString(
                      context,
                      'auth.verifyTitle',
                    ),
                    subtitle: AppLocalizations.getString(
                      context,
                      isPhone
                          ? 'auth.verifyPhoneSubtitle'
                          : 'auth.verifyEmailSubtitle',
                    ),
                    showLogo: false,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  OtpInput(
                    key: _otpKey,
                    enabled: !isLoading,
                    hasError: _errorText != null,
                    onChanged: (v) => setState(() {
                      _code = v;
                      if (_errorText != null) _errorText = null;
                    }),
                    onCompleted: (_) {
                      HapticFeedback.lightImpact();
                      _submit(pending);
                    },
                  ),

                  if (_errorText != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  AuthButton(
                    text: AppLocalizations.getString(
                      context,
                      'auth.verifyButton',
                    ),
                    heroTag: HeroTags.verificationCta,
                    enabled: _isComplete,
                    isLoading: isLoading,
                    onPressed: () => _submit(pending),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Center(
                    child: TextButton(
                      onPressed: isLoading || _resendSeconds > 0
                          ? null
                          : () => _resend(pending),
                      child: Text(
                        _resendSeconds > 0
                            ? '${AppLocalizations.getString(context, 'auth.resendCode')} ($_resendSeconds)'
                            : AppLocalizations.getString(
                                context,
                                'auth.resendCode',
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sent to ${pending.destination}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
