import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/notifications/domain/entities/app_notification.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';

class NotificationHost extends StatefulWidget {
  final Widget child;
  const NotificationHost({super.key, required this.child});

  @override
  State<NotificationHost> createState() => _NotificationHostState();
}

class _NotificationHostState extends State<NotificationHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationsBloc>().add(const RefreshPermissionEvent());
    }
  }

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
        child: widget.child,
      ),
    );
  }

  void _present(BuildContext context, AppNotification n) {
    final bloc = context.read<NotificationsBloc>();

    if (n.openedByUser) {
      _route(context, n.route);
    } else {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              n.body.isEmpty ? n.title : '${n.title}\n${n.body}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            behavior: SnackBarBehavior.floating,
            action: n.route is NotificationRouteNone
                ? null
                : SnackBarAction(
                    label: 'Open',
                    onPressed: () => _route(context, n.route),
                  ),
          ),
        );
    }

    bloc.add(const NotificationTappedEvent());
  }

  void _route(BuildContext context, NotificationRoute route) {
    final router = context.router;

    switch (route) {
      case NotificationRouteNone():
        return;

      case NotificationRouteAppointments():
        router.push(const AppointmentsRoute());

      case NotificationRouteAppointment():
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
