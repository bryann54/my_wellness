// lib/features/auth/presentation/widgets/auth_state_listener.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/core/services/pin_service.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/security_setup_sheet.dart';

class AuthStateListener extends StatelessWidget {
  final Widget child;
  final String? successMessage;
  final bool isRegistration;

  const AuthStateListener({
    super.key,
    required this.child,
    this.successMessage,
    this.isRegistration = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.errorMessage != curr.errorMessage,
      listener: (context, state) => _handleAuthState(context, state),
      child: child,
    );
  }

  Future<void> _handleAuthState(BuildContext context, AuthState state) async {
    switch (state.status) {
      case AuthStatus.authenticated:
        _showSuccessSnackBar(context);
        await _postAuthNavigation(context);

      case AuthStatus.awaitingSignupConfirmation:
        if (state.pendingSignup == null) return;
        // Push the verification screen; it reads pendingSignup from state.
        await context.router.push(
          VerificationRoute(pending: state.pendingSignup),
        );

      case AuthStatus.passwordResetRequested:
      // Caller is expected to show its own "we sent a code" UI; nothing
      // to do globally.

      case AuthStatus.passwordResetCompleted:
        _showSuccessSnackBar(context);
        if (context.mounted) context.router.replace(const LoginRoute());

      case AuthStatus.error:
        _showErrorSnackBar(context, state.errorMessage);

      case AuthStatus.unauthenticated:
      case AuthStatus.initial:
      case AuthStatus.loading:
        break;
    }
  }

  /// Check if first-time security setup is needed, show the sheet, then navigate.
  Future<void> _postAuthNavigation(BuildContext context) async {
    final hasPin = await PinService().hasPin();

    if (!context.mounted) return;

    if (!hasPin) {
      await SecuritySetupSheet.show(context);
    }

    if (!context.mounted) return;
    context.router.replace(const MainRoute());
  }

  void _showSuccessSnackBar(BuildContext context) {
    final message =
        successMessage ??
        (isRegistration
            ? AppLocalizations.getString(context, 'auth.signedIn')
            : AppLocalizations.getString(context, 'auth.welcomeBack'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String? errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage ??
                    AppLocalizations.getString(context, 'auth.genericError'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
