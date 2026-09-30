// lib/features/auth/presentation/pages/verification_screen.dart

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_header.dart';

@RoutePage()
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, this.pending});

  /// Optionally supplied by navigation. If null, read from AuthState.
  final SignupPendingEntity? pending;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeCtrl = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _submit(SignupPendingEntity pending) {
    final code = _codeCtrl.text.trim();
    if (code.length < 4) {
      setState(() => _errorText = 'Enter the code we sent you');
      return;
    }
    setState(() => _errorText = null);
    HapticFeedback.lightImpact();

    if (pending.channel == SignupChannel.phone) {
      context.read<AuthBloc>().add(
        ConfirmSignupPhoneEvent(phone: pending.destination, code: code),
      );
    } else {
      context.read<AuthBloc>().add(
        ConfirmSignupEmailEvent(email: pending.destination, code: code),
      );
    }
  }

  void _resend(SignupPendingEntity pending) {
    HapticFeedback.lightImpact();
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
            size: 22,
            color: cs.primary,
          ),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated &&
              state.pendingSignup == null) {
            // Confirmation succeeded — send them to login.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verified — please sign in.')),
            );
            context.router.replaceAll([const LoginRoute()]);
          }
          if (state.errorMessage != null &&
              state.status == AuthStatus.awaitingSignupConfirmation) {
            setState(() => _errorText = state.errorMessage);
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      errorText: _errorText,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _submit(pending),
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: AppLocalizations.getString(
                      context,
                      'auth.verifyButton',
                    ),
                    isLoading: isLoading,
                    borderRadius: 12,
                    onPressed: () => _submit(pending),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : () => _resend(pending),
                    child: Text(
                      AppLocalizations.getString(
                        context,
                        'auth.resendCode',
                        // fallback: 'Resend code',
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
