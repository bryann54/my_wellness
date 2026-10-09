import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_controllers_manager.dart';
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
  late final PasswordResetControllersManager _manager;
  bool _isIdentifierValid = false;

  @override
  void initState() {
    super.initState();
    _manager = PasswordResetControllersManager(
      onFormChanged: _validateIdentifier,
    );
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  void _validateIdentifier() {
    final isValid =
        _manager.hasIdentifier &&
        AuthValidators.validateIdentifier(context, _manager.identifier) == null;
    if (_isIdentifierValid != isValid) {
      setState(() => _isIdentifierValid = isValid);
    }
  }

  void _handleSubmit() {
    if (_manager.validate()) {
      context.read<AuthBloc>().add(
        RequestPasswordResetEvent(identifier: _manager.identifier),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthStatus.passwordResetRequested) {
            AppSnackbar.success(
              context,
              '${AppLocalizations.getString(context, 'auth.resetPasswordSuccessMessage')} '
              '${_manager.identifier}',
            );
            context.router.maybePop();
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
                    key: _manager.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: AnimatedContainer(
                            duration: AppDurations.medium,
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _isIdentifierValid
                                  ? cs.primaryContainer
                                  : cs.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 32,
                              color: _isIdentifierValid
                                  ? cs.onPrimaryContainer
                                  : cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          AppLocalizations.getString(
                            context,
                            'auth.resetPassword',
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppLocalizations.getString(
                            context,
                            'auth.forgotPasswordDescription',
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.65),
                            height: 1.5,
                          ),
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
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleSubmit(),
                          validator: (value) =>
                              AuthValidators.validateIdentifier(context, value),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == AuthStatus.loading;
                            return AuthButton(
                              text: AppLocalizations.getString(
                                context,
                                'auth.sendCode',
                              ),
                              enabled: _isIdentifierValid,
                              isLoading: isLoading,
                              onPressed: _handleSubmit,
                            );
                          },
                        ),
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
