import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';

class BookingToastListener extends StatelessWidget {
  final Widget child;
  const BookingToastListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingsBloc, BookingsState>(
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
      },
      child: child,
    );
  }
}
