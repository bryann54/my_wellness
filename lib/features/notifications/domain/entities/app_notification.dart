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

class NotificationRouteBookings extends NotificationRoute {
  const NotificationRouteBookings();
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

/// Parses OneSignal's additional data using the backend's `data.type` contract.
NotificationRoute parseNotificationRoute(Map<String, dynamic> data) {
  final type = data['type']?.toString().trim();
  final assessmentSlug = data['assessment_slug']?.toString().trim();

  switch (type) {
    case 'appointment':
      return const NotificationRouteAppointments();

    case 'booking':
      return const NotificationRouteBookings();

    case 'medication':
    case 'medication_dose':
    case 'medication_refill':
      return const NotificationRouteMedications();

    case 'screening_expiry':
      return const NotificationRouteAssessments();
    case 'screening_eligible':
    case 'corporate_wellbeing_chapter_ready':
      return assessmentSlug == null || assessmentSlug.isEmpty
          ? const NotificationRouteAssessments()
          : NotificationRouteAssessment(assessmentSlug);

    case 'vitals':
    case 'dialysis_reminder':
    case 'vitals_reminder':
      return const NotificationRouteVitals();

    case 'post_visit_followup':
    case 'post_visit_attendance_check':
      return const NotificationRouteAppointments();

    default:
      return const NotificationRouteNone();
  }
}
