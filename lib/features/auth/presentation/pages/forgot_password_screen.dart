import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 0;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _identifierController,
      _codeController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String get _identifier => _identifierController.text.trim();

  bool get _canSubmit {
    switch (_step) {
      case 0:
        return _identifier.isNotEmpty;
      case 1:
        return AuthValidators.isValidPasscode(_codeController.text.trim());
      case 2:
        return AuthValidators.isValidPasscode(_passwordController.text) &&
            _passwordController.text == _confirmPasswordController.text;
      default:
        return true;
    }
  }

  void _submit() {
    if (_step == 3) {
      context.router.maybePop();
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_step == 0) {
      context.read<AuthBloc>().add(
        RequestPasswordResetEvent(identifier: _identifier),
      );
    } else if (_step == 1) {
      setState(() => _step = 2);
    } else {
      context.read<AuthBloc>().add(
        ConfirmPasswordResetEvent(
          identifier: _identifier,
          code: _codeController.text.trim(),
          newPassword: _passwordController.text,
        ),
      );
    }
  }

  void _resendCode() {
    context.read<AuthBloc>().add(
      RequestPasswordResetEvent(identifier: _identifier),
    );
  }

  String _title(BuildContext context) {
    if (_step == 1) {
      return AppLocalizations.getString(context, 'auth.verifyCode');
    }
    if (_step == 3) {
      return AppLocalizations.getString(context, 'auth.passwordResetSuccess');
    }
    return AppLocalizations.getString(context, 'auth.resetPassword');
  }

  String _description(BuildContext context) {
    switch (_step) {
      case 0:
        return AppLocalizations.getString(
          context,
          'auth.forgotPasswordDescription',
        );
      case 1:
        return AppLocalizations.t(context, 'auth.resetCodeSent', {
          'identifier': _identifier,
        });
      case 2:
        return AppLocalizations.getString(
          context,
          'auth.resetPasscodeDescription',
        );
      default:
        return AppLocalizations.getString(
          context,
          'auth.passwordResetSuccessMessage',
        );
    }
  }

  String _buttonText(BuildContext context) {
    switch (_step) {
      case 0:
        return AppLocalizations.getString(context, 'auth.sendCode');
      case 1:
        return AppLocalizations.getString(context, 'common.continue');
      case 2:
        return AppLocalizations.getString(context, 'auth.resetPassword');
      default:
        return AppLocalizations.getString(context, 'auth.backToSignIn');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.passwordResetRequested) {
            setState(() => _step = 1);
            AppSnackbar.success(
              context,
              AppLocalizations.t(context, 'auth.resetCodeSent', {
                'identifier': _identifier,
              }),
            );
          } else if (state.status == AuthStatus.passwordResetCompleted) {
            setState(() => _step = 3);
          } else if (state.status == AuthStatus.error) {
            AppSnackbar.error(
              context,
              state.errorMessage ??
                  AppLocalizations.getString(context, 'common.error'),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'auth.resetPassword'),
              isHome: false,
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: AnimatedContainer(
                            duration: AppDurations.medium,
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _step > 0
                                  ? cs.primaryContainer
                                  : cs.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _step == 3
                                  ? Icons.check_rounded
                                  : Icons.lock_reset_rounded,
                              size: 32,
                              color: _step > 0
                                  ? cs.onPrimaryContainer
                                  : cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          _title(context),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _description(context),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.65),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (_step == 0)
                          AuthTextField(
                            controller: _identifierController,
                            label: AppLocalizations.getString(
                              context,
                              'auth.emailOrPhone',
                            ),
                            icon: Icons.person_outline,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            validator: (value) =>
                                AuthValidators.validateIdentifier(
                                  context,
                                  value,
                                ),
                          ),
                        if (_step == 1)
                          AuthTextField(
                            controller: _codeController,
                            label: AppLocalizations.getString(
                              context,
                              'auth.enterCode',
                            ),
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onSubmitted: (_) => _submit(),
                            validator: (value) =>
                                AuthValidators.validatePasscode(context, value),
                          ),
                        if (_step == 2) ...[
                          AuthTextField(
                            controller: _passwordController,
                            label: AppLocalizations.getString(
                              context,
                              'auth.newPassword',
                            ),
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isPasswordVisible: _passwordVisible,
                            onVisibilityToggle: () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            validator: (value) =>
                                AuthValidators.validatePasscode(context, value),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            label: AppLocalizations.getString(
                              context,
                              'auth.confirmPassword',
                            ),
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isPasswordVisible: _confirmPasswordVisible,
                            onVisibilityToggle: () => setState(
                              () => _confirmPasswordVisible =
                                  !_confirmPasswordVisible,
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onSubmitted: (_) => _submit(),
                            validator: (value) =>
                                AuthValidators.validateConfirmPassword(
                                  context,
                                  value,
                                  _passwordController.text,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == AuthStatus.loading;
                            return AuthButton(
                              text: _buttonText(context),
                              enabled: _canSubmit,
                              isLoading: isLoading,
                              onPressed: _submit,
                            );
                          },
                        ),
                        if (_step == 1) ...[
                          const SizedBox(height: AppSpacing.sm),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) => AuthButton(
                              text: AppLocalizations.getString(
                                context,
                                'auth.resendCode',
                              ),
                              variant: AuthButtonVariant.outlined,
                              enabled: state.status != AuthStatus.loading,
                              onPressed: _resendCode,
                            ),
                          ),
                        ],
                        if (_step == 2) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AuthButton(
                            text: AppLocalizations.getString(
                              context,
                              'auth.enterCode',
                            ),
                            variant: AuthButtonVariant.outlined,
                            onPressed: () => setState(() => _step = 1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
