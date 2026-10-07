import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/notifications/domain/repositories/notifications_repository.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  @override
  Future<Either<Failure, NotificationsPage>> list({String? cursor}) async {
    // TODO: wire the API call once the endpoint contract is finalized.
    // Until then, return an empty page so the UI renders its empty state.
    return const Right(NotificationsPage(items: []));
  }
}
