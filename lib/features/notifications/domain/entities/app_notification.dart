import 'package:equatable/equatable.dart';

/// A notification as the app understands it.
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationRoute route;
  final DateTime receivedAt;
  final bool openedByUser;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    required this.receivedAt,
    this.openedByUser = false,
  });

  @override
  List<Object?> get props => [id, title, body, route, receivedAt, openedByUser];
}

/// Where a tapped notification should send the user.
///
/// Sealed so the host's dispatcher can be exhaustively switched.
sealed class NotificationRoute extends Equatable {
  const NotificationRoute();

  @override
  List<Object?> get props => const [];
}

class NotificationRouteNone extends NotificationRoute {
  const NotificationRouteNone();
}

class NotificationRouteAppointments extends NotificationRoute {
  const NotificationRouteAppointments();
}

class NotificationRouteAppointment extends NotificationRoute {
  final String id;
  const NotificationRouteAppointment(this.id);

  @override
  List<Object?> get props => [id];
}

class NotificationRouteMedications extends NotificationRoute {
  const NotificationRouteMedications();
}

class NotificationRouteAssessments extends NotificationRoute {
  const NotificationRouteAssessments();
}

class NotificationRouteAssessment extends NotificationRoute {
  final String slug;
  const NotificationRouteAssessment(this.slug);

  @override
  List<Object?> get props => [slug];
}

class NotificationRouteAssessmentResult extends NotificationRoute {
  final String slug;
  const NotificationRouteAssessmentResult(this.slug);

  @override
  List<Object?> get props => [slug];
}

class NotificationRouteVitals extends NotificationRoute {
  const NotificationRouteVitals();
}

class NotificationRouteAccount extends NotificationRoute {
  const NotificationRouteAccount();
}

/// Parses the `additional_data` map sent by the backend into a route.
///
/// Free function, not a factory method, so the sealed hierarchy has no
/// name collision. Returns [NotificationRouteNone] for unknown or missing
/// targets — the host treats that as "show the snackbar, don't navigate".
NotificationRoute parseNotificationRoute(Map<String, dynamic> data) {
  final target = (data['target'] as String?)?.trim();
  if (target == null || target.isEmpty) return const NotificationRouteNone();

  final id = (data['target_id'] as String?)?.trim();
  final slug = (data['slug'] as String?)?.trim();

  switch (target) {
    case 'appointment':
      return id == null || id.isEmpty
          ? const NotificationRouteAppointments()
          : NotificationRouteAppointment(id);

    case 'medication':
      return const NotificationRouteMedications();

    case 'assessment':
      return slug == null || slug.isEmpty
          ? const NotificationRouteAssessments()
          : NotificationRouteAssessment(slug);

    case 'assessment_result':
      return slug == null || slug.isEmpty
          ? const NotificationRouteAssessments()
          : NotificationRouteAssessmentResult(slug);

    case 'vitals':
      return const NotificationRouteVitals();

    case 'account':
      return const NotificationRouteAccount();

    default:
      return const NotificationRouteNone();
  }
}
