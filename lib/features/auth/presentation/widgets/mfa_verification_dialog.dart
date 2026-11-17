import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';

class MfaVerificationDialog extends StatefulWidget {
  const MfaVerificationDialog({super.key});

  @override
  State<MfaVerificationDialog> createState() => _MfaVerificationDialogState();
}

class _MfaVerificationDialogState extends State<MfaVerificationDialog> {
  final _controller = TextEditingController();
  bool _useBackupCode = false;
  String? _localError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    final valid = _useBackupCode
        ? RegExp(r'^[0-9a-f]{10}$').hasMatch(value)
        : RegExp(r'^\d{6}$').hasMatch(value);
    if (!valid) {
      setState(() {
        _localError = _useBackupCode
            ? 'Enter a valid 10-character backup code.'
            : 'Enter the 6-digit code.';
      });
      return;
    }
    setState(() => _localError = null);
    context.read<AuthBloc>().add(
      VerifyMfaEvent(value: value, useBackupCode: _useBackupCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pop(true);
        } else if (state.status == AuthStatus.mfaExpired) {
          AppSnackbar.error(
            context,
            state.errorMessage ??
                AppLocalizations.getString(context, 'auth.sessionExpired'),
          );
          Navigator.of(context).pop(false);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final loading = state.status == AuthStatus.loading;
          return AlertDialog(
            title: Text(AppLocalizations.getString(context, 'auth.mfaTitle')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.getString(
                    context,
                    _useBackupCode
                        ? 'auth.mfaBackupPrompt'
                        : 'auth.mfaAuthenticatorPrompt',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  enabled: !loading,
                  autofocus: true,
                  obscureText: _useBackupCode,
                  keyboardType: _useBackupCode
                      ? TextInputType.text
                      : TextInputType.number,
                  inputFormatters: _useBackupCode
                      ? const []
                      : [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() => _localError = null),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.getString(
                      context,
                      _useBackupCode
                          ? 'auth.mfaBackupCode'
                          : 'auth.mfaAuthenticatorCode',
                    ),
                    errorText:
                        _localError ??
                        (state.status == AuthStatus.mfaRequired
                            ? state.errorMessage
                            : null),
                  ),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () {
                          setState(() {
                            _useBackupCode = !_useBackupCode;
                            _controller.clear();
                          });
                        },
                  child: Text(
                    AppLocalizations.getString(
                      context,
                      _useBackupCode
                          ? 'auth.mfaUseAuthenticator'
                          : 'auth.mfaUseBackup',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Text(
                  AppLocalizations.getString(context, 'auth.backToSignIn'),
                ),
              ),
              FilledButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const ShimmerBox(width: 42, height: 10, radius: 5)
                    : Text(
                        AppLocalizations.getString(
                          context,
                          'auth.verifyAndContinue',
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
