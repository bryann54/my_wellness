import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/appointments/presentation/bloc/appointments_bloc.dart';

class AppointmentsToastListener extends StatelessWidget {
  const AppointmentsToastListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocListener<AppointmentsBloc, AppointmentsState>(
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
          context.read<AppointmentsBloc>().add(
            const ClearAppointmentsToastEvent(),
          );
        },
        child: child,
      );
}
