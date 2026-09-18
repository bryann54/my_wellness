// lib/features/auth/presentation/widgets/splash_auth_listener.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';

class SplashAuthListener extends StatelessWidget {
  final VoidCallback onAuthCheckComplete;
  final Widget child;

  const SplashAuthListener({
    super.key,
    required this.onAuthCheckComplete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _handleAuthState(context, state);
      },
      child: child,
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    // Navigate as soon as auth state changes
    if (state.status != AuthStatus.initial &&
        state.status != AuthStatus.loading) {
      onAuthCheckComplete();
    }
  }
}
