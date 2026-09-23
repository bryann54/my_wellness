
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
class VitalsToastListener extends StatelessWidget {
  final Widget child;
  const VitalsToastListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VitalsBloc, VitalsState>(
      listenWhen: (p, c) => p.toastNonce != c.toastNonce,
      listener: (context, state) {
        final msg = state.toastMessage;
        if (msg == null) return;

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

        context.read<VitalsBloc>().add(const ClearToastEvent());
      },
      child: child,
    );
  }
}
