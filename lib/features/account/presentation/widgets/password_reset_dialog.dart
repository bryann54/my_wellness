import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_controllers_manager.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({super.key});

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  late final PasswordResetControllersManager _controllersManager;
  bool _isIdentifierValid = false;

  @override
  void initState() {
    super.initState();
    _controllersManager = PasswordResetControllersManager(
      onFormChanged: _validateIdentifier,
    );
  }

  @override
  void dispose() {
    _controllersManager.dispose();
    super.dispose();
  }

  void _validateIdentifier() {
    final isValid =
        _controllersManager.hasIdentifier &&
        AuthValidators.validateIdentifier(
              context,
              _controllersManager.identifier,
            ) ==
            null;

    if (_isIdentifierValid != isValid) {
      setState(() => _isIdentifierValid = isValid);
    }
  }

  void _handleSendReset() {
    if (_controllersManager.validate()) {
      context.read<AuthBloc>().add(
        RequestPasswordResetEvent(identifier: _controllersManager.identifier),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthStatus.passwordResetRequested) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.getString(context, 'auth.resetPasswordSuccessMessage')} '
                  '${_controllersManager.identifier}',
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.getString(context, 'common.error')}: ${state.errorMessage}',
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _isIdentifierValid
                      ? AppColors.dividerColor.withValues(alpha: 0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset,
                  size: 32,
                  color: _isIdentifierValid
                      ? AppColors.primaryColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                child: Text(
                  AppLocalizations.getString(context, 'auth.resetPassword'),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                AppLocalizations.getString(
                  context,
                  'auth.forgotPasswordDescription',
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 28),

              Form(
                key: _controllersManager.formKey,
                child: AuthTextField(
                  controller: _controllersManager.identifierController,
                  label: AppLocalizations.getString(
                    context,
                    'auth.emailOrPhone',
                  ),
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      AuthValidators.validateIdentifier(context, value),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            color: theme.dividerColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.getString(context, 'common.cancel'),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state.status == AuthStatus.loading;
                        return AppPrimaryButton(
                          onPressed: _isIdentifierValid && !isLoading
                              ? _handleSendReset
                              : null,
                          label: AppLocalizations.getString(
                            context,
                            'auth.sendCode',
                          ),
                          isLoading: isLoading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showPasswordResetDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => const PasswordResetDialog(),
  );
}
