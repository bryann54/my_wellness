import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/notifications/domain/entities/app_notification.dart';

/// Page of notifications from the API.
class NotificationsPage {
  final List<AppNotification> items;
  final String? nextCursor;

  const NotificationsPage({required this.items, this.nextCursor});
}

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationsPage>> list({String? cursor});
}
