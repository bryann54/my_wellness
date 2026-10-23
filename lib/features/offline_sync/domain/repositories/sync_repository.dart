import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';

abstract class SyncRepository {
  Future<Either<Failure, void>> enqueueAction({
    required String actionType,
    required String endpoint,
    required Map<String, dynamic> payload,
    String method = 'POST',
  });

  Future<Either<Failure, int>> processQueue();
  Future<Either<Failure, int>> getPendingCount();
}
