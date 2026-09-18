import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';

class LogoutDialog {
  static Future<void> show(BuildContext context) async {
    final confirmed = await AppDialogs.ask(
      context,
      title: AppLocalizations.getString(context, 'settings.logOut'),
      message: AppLocalizations.getString(context, 'settings.logoutMessage'),
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const SignOutEvent());
      context.router.pushAndPopUntil(
        const LoginRoute(),
        predicate: (route) => false,
      );
    }
  }
}
