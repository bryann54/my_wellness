import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';

class AssessmentToastListener extends StatelessWidget {
  final Widget child;
  const AssessmentToastListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssessmentsBloc, AssessmentsState>(
      listenWhen: (p, c) => p.toastNonce != c.toastNonce,
      listener: (context, state) {
        final raw = state.toastMessage;
        if (raw == null) return;

        final msg = AppLocalizations.getString(context, raw);

        switch (state.toastType) {
          case ToastType.success:
            AppSnackbar.success(context, msg);
          case ToastType.error:
            AppSnackbar.error(context, msg);
          case ToastType.warning:
            AppSnackbar.warning(context, msg);
          case ToastType.info:
          case null:
            AppSnackbar.info(context, msg);
        }
      },
      child: child,
    );
  }
}
