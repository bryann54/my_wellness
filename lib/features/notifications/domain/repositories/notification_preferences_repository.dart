import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/notifications/domain/entities/notification_preference.dart';

abstract class NotificationPreferencesRepository {
  Future<Either<Failure, List<NotificationPreference>>> getPreferences();
  Future<Either<Failure, List<NotificationPreference>>> savePreferences(
    List<NotificationPreference> preferences,
  );
}
