import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

class DeleteAccountDialog {
  static Future<void> show(BuildContext context) async {
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog.adaptive(
          title: Text(
            AppLocalizations.getString(ctx, 'settings.deleteAccount'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.getString(
                  ctx,
                  'settings.deleteAccountWarning',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: true,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.getString(ctx, 'common.cancel')),
            ),
            TextButton(
              onPressed: controller.text.isEmpty
                  ? null
                  : () => Navigator.pop(ctx, controller.text),
              child: Text(
                'Confirm deletion',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (password != null && password.isNotEmpty && context.mounted) {
      context.read<AccountBloc>().add(DeleteAccountEvent(password));
    }
  }
}
