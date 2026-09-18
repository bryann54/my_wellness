import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

class DeleteAccountDialog {
  static Future<void> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(AppLocalizations.getString(ctx, 'settings.deleteAccount')),
        content: Text(
          AppLocalizations.getString(ctx, 'settings.deleteAccountWarning'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.getString(ctx, 'common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.getString(ctx, 'common.delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AccountBloc>().add(const DeleteAccountEvent());
    }
  }
}
