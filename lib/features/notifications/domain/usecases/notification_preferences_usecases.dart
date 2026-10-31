import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/notifications/domain/entities/notification_preference.dart';
import 'package:my_wellness/features/notifications/domain/repositories/notification_preferences_repository.dart';

@lazySingleton
class NotificationPreferencesUseCases {
  final NotificationPreferencesRepository _repository;
  NotificationPreferencesUseCases(this._repository);

  Future<Either<Failure, List<NotificationPreference>>> load() =>
      _repository.getPreferences();

  Future<Either<Failure, List<NotificationPreference>>> save(
    List<NotificationPreference> preferences,
  ) => _repository.savePreferences(preferences);
}
