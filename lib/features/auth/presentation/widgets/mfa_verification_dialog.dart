import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if ((_useBackupCode && value.isEmpty) ||
        (!_useBackupCode && value.length != 6)) {
      return;
    }
    context.read<AuthBloc>().add(
      VerifyMfaEvent(value: value, useBackupCode: _useBackupCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.authenticated,
      listener: (context, _) => Navigator.of(context).pop(true),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final loading = state.status == AuthStatus.loading;
          return AlertDialog(
            title: const Text('Two-factor verification'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _useBackupCode
                      ? 'Enter one of your unused backup codes.'
                      : 'Enter the 6-digit code from your authenticator app.',
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
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: _useBackupCode
                        ? 'Backup code'
                        : 'Authenticator code',
                    errorText: state.status == AuthStatus.mfaRequired
                        ? state.errorMessage
                        : null,
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
                    _useBackupCode
                        ? 'Use authenticator code'
                        : 'Use a backup code',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Back to sign in'),
              ),
              FilledButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const ShimmerBox(width: 42, height: 10, radius: 5)
                    : const Text('Verify and continue'),
              ),
            ],
          );
        },
      ),
    );
  }
}
