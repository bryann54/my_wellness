import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:my_wellness/features/app_lock/presentation/widgets/app_lock_setup_sheet.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/widgets/mfa_verification_dialog.dart';

class AuthStateListener extends StatelessWidget {
  const AuthStateListener({
    super.key,
    required this.child,
    this.successMessage,
    this.isRegistration = false,
  });

  final Widget child;
  final String? successMessage;
  final bool isRegistration;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status ||
              prev.errorMessage != curr.errorMessage,
          listener: _handleAuthState,
        ),
        BlocListener<AppLockBloc, AppLockState>(
          listenWhen: (prev, curr) => prev.signIn != curr.signIn,
          listener: _handleSignIn,
        ),
      ],
      child: child,
    );
  }

  Future<void> _handleAuthState(BuildContext context, AuthState state) async {
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    switch (state.status) {
      case AuthStatus.authenticated:
        _showSuccess(context);
        context.read<AppLockBloc>().add(const AppLockSignedIn());

      case AuthStatus.awaitingSignupConfirmation:
        if (state.pendingSignup == null) return;
        final message = state.pendingSignup?.message;
        if (message != null && message.isNotEmpty) {
          AppSnackbar.error(context, message);
        }
        await context.router.push(
          VerificationRoute(pending: state.pendingSignup),
        );

      case AuthStatus.mfaRequired:
        final verified = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: const MfaVerificationDialog(),
          ),
        );
        if (!context.mounted) return;
        if (verified == true) {
          _showSuccess(context);
          context.read<AppLockBloc>().add(const AppLockSignedIn());
        } else {
          context.read<AuthBloc>().add(const CancelMfaEvent());
        }

      case AuthStatus.mfaExpired:
        AppSnackbar.error(
          context,
          state.errorMessage ?? _genericError(context),
        );

      case AuthStatus.passwordResetRequested:
      case AuthStatus.passwordResetCompleted:
        _showSuccess(context);
        if (context.mounted) context.router.replace(const LoginRoute());

      case AuthStatus.error:
        AppSnackbar.error(
          context,
          state.errorMessage ?? _genericError(context),
        );

      case AuthStatus.unauthenticated:
      case AuthStatus.initial:
      case AuthStatus.loading:
        break;
    }
  }

  Future<void> _handleSignIn(BuildContext context, AppLockState state) async {
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    switch (state.signIn) {
      case AppLockSignIn.setupRequired:
        await AppLockSetupSheet.show(context, security: state.security);
        if (context.mounted) {
          context.read<AppLockBloc>().add(const AppLockSetupDismissed());
        }

      case AppLockSignIn.ready:
        context.router.replace(const MainRoute());

      case AppLockSignIn.idle:
        break;
    }
  }

  void _showSuccess(BuildContext context) {
    final message =
        successMessage ??
        (isRegistration
            ? AppLocalizations.getString(context, 'auth.signedIn')
            : AppLocalizations.getString(context, 'auth.welcomeBack'));
    AppSnackbar.success(context, message);
  }

  String _genericError(BuildContext context) =>
      AppLocalizations.getString(context, 'auth.genericError');
}
