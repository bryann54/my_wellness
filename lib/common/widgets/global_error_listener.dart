// lib/common/widgets/global_error_listener.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';

class GlobalErrorListener extends StatelessWidget {
  final Widget child;

  const GlobalErrorListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        //just inase the interceptor doest work or the refresh token expired, we want to make sure the user is logged out and sent to the login screen
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
        // Auth Errors
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
