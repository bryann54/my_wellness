import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/notifications/data/datasources/notification_preferences_remote_datasource.dart';
import 'package:my_wellness/features/notifications/data/models/notification_preference_model.dart';
import 'package:my_wellness/features/notifications/domain/entities/notification_preference.dart';
import 'package:my_wellness/features/notifications/domain/repositories/notification_preferences_repository.dart';

@LazySingleton(as: NotificationPreferencesRepository)
class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  final NotificationPreferencesRemoteDataSource _remote;
  NotificationPreferencesRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<NotificationPreference>>> getPreferences() async {
    try {
      return Right(await _remote.getPreferences());
    } on Exception catch (error) {
      return Left(_map(error));
    }
  }

  @override
  Future<Either<Failure, List<NotificationPreference>>> savePreferences(
    List<NotificationPreference> preferences,
  ) async {
    try {
      final models = preferences
          .map(
            (preference) => NotificationPreferenceModel(
              category: preference.category,
              label: preference.label,
              required: preference.required,
              push: preference.push,
              email: preference.email,
              sms: preference.sms,
              whatsapp: preference.whatsapp,
            ),
          )
          .toList(growable: false);
      return Right(await _remote.savePreferences(models));
    } on Exception catch (error) {
      return Left(_map(error));
    }
  }

  Failure _map(Exception error) {
    if (error is UnauthorizedException) return const UnauthorizedFailure();
    if (error is ValidationException) {
      return ValidationFailure(error: error.message);
    }
    if (error is NetworkException) return const NetworkFailure();
    if (error is ServerException) return const ServerFailure();
    return GeneralFailure(error: error.toString());
  }
}
