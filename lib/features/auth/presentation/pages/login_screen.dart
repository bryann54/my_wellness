import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_controllers_manager.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_state_listener.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_bottom_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/language_selector.dart';

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
      HapticFeedback.lightImpact(); 
      context.read<AuthBloc>().add(
        SignInEvent(
          identifier: _manager.identifier,
          password: _manager.password,
        ),
      );
    }
  }

  void _handleAccountState(BuildContext context, AccountState state) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (state.currentLang != localeProvider.locale.languageCode) {
      localeProvider.setLocale(Locale(state.currentLang));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AccountBloc, AccountState>(
        listenWhen: (prev, curr) => prev.currentLang != curr.currentLang,
        listener: _handleAccountState,
        child: AuthStateListener(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Form(
                key: _manager.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: const LanguageSelector(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AuthHeader(
                      title: AppLocalizations.getString(
                        context,
                        'auth.welcomeBack',
                      ),
                      subtitle: AppLocalizations.getString(
                        context,
                        'auth.signIn',
                      ),
                      heroTag: HeroTags.authLogo,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AuthTextField(
                      controller: _manager.identifierController,
                      label: AppLocalizations.getString(
                        context,
                        'auth.emailOrPhone',
                      ),
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: (v) =>
                          AuthValidators.validateIdentifier(context, v),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AuthTextField(
                      controller: _manager.passwordController,
                      label: AppLocalizations.getString(
                        context,
                        'auth.password',
                      ),
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onVisibilityToggle: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                      onSubmitted: (_) => _handleLogin(),
                      validator: (v) => AuthValidators.validatePassword(
                        context,
                        v,
                        isStrict: true,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.router.push(const ForgotPasswordRoute()),
                        child: Text(
                          AppLocalizations.getString(
                            context,
                            'auth.forgotPassword',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final ready =
                            _manager.canAttemptLogin &&
                            state.status != AuthStatus.loading;
                        return AuthButton(
                          text: AppLocalizations.getString(
                            context,
                            'auth.signInLink',
                          ),
                          heroTag: HeroTags.authPrimaryCta,
                          enabled: ready,
                          isLoading: state.status == AuthStatus.loading,
                          onPressed: _handleLogin,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AuthBottomBar(
        promptText: AppLocalizations.getString(context, 'auth.dontHaveAccount'),
        actionText: AppLocalizations.getString(context, 'auth.signUpLink'),
        heroTag: HeroTags.authToggle,
        onActionPressed: () => context.router.push(const RegisterRoute()),
      ),
    );
  }
}
