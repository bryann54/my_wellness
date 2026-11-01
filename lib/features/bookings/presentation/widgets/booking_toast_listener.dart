import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';

class BookingsToastListener extends StatelessWidget {
  final Widget child;

  const BookingsToastListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingsBloc, BookingsState>(
      listenWhen: (p, c) => p.toastNonce != c.toastNonce,
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        final raw = state.toastMessage;
        if (raw == null) return;
        final msg = state.toastIsKey
            ? AppLocalizations.getString(context, raw)
            : raw;

        switch (state.toastType) {
          case BookingToastType.success:
            AppSnackbar.success(context, msg);
          case BookingToastType.error:
            AppSnackbar.error(context, msg);
          case BookingToastType.warning:
            AppSnackbar.warning(context, msg);
          case BookingToastType.info:
          case null:
            AppSnackbar.info(context, msg);
        }
      },
      child: child,
    );
  }
}
