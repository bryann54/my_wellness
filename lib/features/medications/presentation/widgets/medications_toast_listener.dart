import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/medications/presentation/bloc/medications_bloc.dart';

class MedicationsToastListener extends StatelessWidget {
  const MedicationsToastListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocListener<MedicationsBloc, MedicationsState>(
        listenWhen: (previous, current) =>
            previous.toastNonce != current.toastNonce,
        listener: (context, state) {
          final message = state.toastMessage;
          if (message == null) return;
          if (state.toastType == ToastType.success) {
            AppSnackbar.success(context, message);
          } else {
            AppSnackbar.error(context, message);
          }
          context.read<MedicationsBloc>().add(
            const ClearMedicationsToastEvent(),
          );
        },
        child: child,
      );
}
