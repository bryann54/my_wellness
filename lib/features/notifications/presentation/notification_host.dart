import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/notifications/domain/entities/app_notification.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';

class NotificationHost extends StatelessWidget {
  final Widget child;
  const NotificationHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.status != c.status || p.user?.id != c.user?.id,
      listener: (context, state) {
        final bloc = context.read<NotificationsBloc>();
        if (state.status == AuthStatus.authenticated) {
          final userId = state.user?.id;
          if (userId == null || userId.isEmpty) return;
          final memberCode = context
              .read<AccountBloc>()
              .state
              .profile
              ?.memberCode;
          bloc.add(
            RegisterIdentityEvent(userId: userId, memberCode: memberCode),
          );
        } else if (state.status == AuthStatus.unauthenticated) {
          bloc.add(const ClearIdentityEvent());
        }
      },
      child: BlocListener<NotificationsBloc, NotificationsState>(
        listenWhen: (p, c) => p.pending != c.pending,
        listener: (context, state) {
          final n = state.pending;
          if (n == null) return;
          _present(context, n);
        },
        child: child,
      ),
    );
  }

  void _present(BuildContext context, AppNotification n) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(n.body.isEmpty ? n.title : '${n.title}\n${n.body}'),
          behavior: SnackBarBehavior.floating,
          action: n.route is NotificationRouteNone
              ? null
              : SnackBarAction(
                  label: 'Open',
                  onPressed: () => _route(context, n.route),
                ),
        ),
      );

    // If the app was opened by a tap (cold start), route immediately
    // rather than waiting for the snackbar action. The snackbar is
    // dismissed because the user is being taken to the destination.
    _route(context, n.route);
    context.read<NotificationsBloc>().add(const NotificationTappedEvent());
  }

  void _route(BuildContext context, NotificationRoute route) {
    final router = context.router;

    switch (route) {
      case NotificationRouteNone():
        return;

      case NotificationRouteAppointments():
        router.push(const AppointmentsRoute());

      case NotificationRouteAppointment():
        // No per-appointment route yet. Land on the list.
        router.push(const AppointmentsRoute());

      case NotificationRouteMedications():
        router.push(const MedicationsRoute());

      case NotificationRouteAssessments():
        router.push(const AssessmentsListRoute());

      case NotificationRouteAssessment(:final slug):
        router.push(AssessmentIntroRoute(slug: slug));

      case NotificationRouteAssessmentResult(:final slug):
        router.push(AssessmentResultRoute(slug: slug));

      case NotificationRouteVitals():
        router.push(VitalsRoute());

      case NotificationRouteAccount():
        router.push(const SettingsRoute());
    }
  }
}
