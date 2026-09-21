// lib/features/auth/presentation/pages/login_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_controllers_manager.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_bottom_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_state_listener.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginControllersManager _manager;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _manager = LoginControllersManager(onFormChanged: () => setState(() {}));
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_manager.validate()) {
      context.read<AuthBloc>().add(
        SignInEvent(
          identifier: _manager.identifier,
          password: _manager.password,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthStateListener(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _manager.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AuthHeader(
                    title: AppLocalizations.getString(
                      context,
                      'auth.welcomeBack',
                    ),
                    subtitle: AppLocalizations.getString(
                      context,
                      'auth.signIn',
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Staggered Animation 1: Email Field
                  AuthTextField(
                        controller: _manager.identifierController,
                        label: AppLocalizations.getString(
                          context,
                          'auth.emailOrPhone',
                        ),
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            AuthValidators.validateIdentifier(context, value),
                      )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.8, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 16),

                  AuthTextField(
                        controller: _manager.passwordController,
                        label: AppLocalizations.getString(
                          context,
                          'auth.password',
                        ),
                        isPassword: true,
                        icon: Icons.lock_outline,
                        isPasswordVisible: _isPasswordVisible,
                        onVisibilityToggle: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                        validator: (value) => AuthValidators.validatePassword(
                          context,
                          value,
                          isStrict: true,
                        ),
                      )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.8, end: 0, curve: Curves.easeOut),

                  Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.router.push(const ForgotPasswordRoute());
                            },
                            child: Text(
                              AppLocalizations.getString(
                                context,
                                'auth.forgotPassword',
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate(delay: 1400.ms)
                      .fadeIn()
                      .slideX(begin: -0.8, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: 100),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isReady =
                          _manager.canAttemptLogin &&
                          state.status != AuthStatus.loading;

                      return AuthButton(
                        text: AppLocalizations.getString(
                          context,
                          'auth.signInLink',
                        ),
                        heroTag: 'login_button',
                        isEnabled: isReady,
                        isLoading: state.status == AuthStatus.loading,
                        onPressed: _handleLogin,
                      );
                    },
                  ),
                  // .animate(delay: 900.ms)
                  // .fadeIn(duration: 400.ms)
                  // .slideX(begin: -0.8, end: 0, curve: Curves.easeOut),
                  // SizedBox(height: 24),
                  // AuthDivider(
                  //   text: AppLocalizations.getString(
                  //     context,
                  //     'common.or',
                  //   ).toUpperCase(),
                  // )
                  //     .animate(delay: 300.ms)
                  //     .fadeIn(duration: 400.ms)
                  //     .slideX(begin: -0.9, curve: Curves.easeOut),
                  // SizedBox(height: 24),
                  // SocialAuthButton(
                  //   provider: SocialAuthProvider.google,
                  //   isLoading: false,
                  //   onPressed: () {},
                  //   // isLoading: state.status == AuthStatus.googleLoading,
                  //   // onPressed: _handleGoogleSignIn,
                  // )
                  //     .animate(delay: 300.ms)
                  //     .fadeIn(duration: 400.ms)
                  //     .slideX(begin: 0.8, end: 0, curve: Curves.easeOut),

                  // const SizedBox(height: 12),
                  // SocialAuthButton(
                  //   provider: SocialAuthProvider.apple,
                  //   isLoading: false,
                  //   onPressed: () {},
                  //   // isLoading: state.status == AuthStatus.appleLoading,
                  //   // onPressed: _handleAppleSignIn,
                  // )
                  //     .animate(delay: 300.ms)
                  //     .fadeIn(duration: 400.ms)
                  //     .slideX(begin: -0.8, end: 0, curve: Curves.easeOut),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AuthBottomBar(
        promptText: AppLocalizations.getString(context, 'auth.dontHaveAccount'),
        actionText: AppLocalizations.getString(context, 'auth.signUpLink'),
        onActionPressed: () {
          context.router.push(const RegisterRoute());
        },
        heroTag: 'auth_toggle_button',
      ),
    );
  }
}
