// lib/common/widgets/global_error_listener.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';

class GlobalErrorListener extends StatelessWidget {
  final Widget child;

  const GlobalErrorListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Session expiry: force the user back to login.
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != AuthStatus.unauthenticated &&
              c.status == AuthStatus.unauthenticated,
          listener: (context, state) {
            context.router.pushAndPopUntil(
              const LoginRoute(),
              predicate: (route) => false,
            );
            _showError(
              context,
              'Your session has expired. Please log in again.',
            );
          },
        ),
        // Generic auth errors.
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == AuthStatus.error,
          listener: (context, state) {
            _showError(context, state.errorMessage ?? 'Authentication error');
          },
        ),
      ],
      child: child,
    );
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    final navigator = Navigator.maybeOf(context);
    if (navigator == null) return;

    CustomAlertDialog.show(
      context: context,
      dialog: CustomAlertDialog(
        title: 'Error',
        message: message,
        type: DialogType.error,
        showCancelButton: false,
      ),
    );
  }
}
