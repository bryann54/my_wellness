import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/offline_sync/data/datasources/sync_local_datasource.dart';
import 'package:my_wellness/features/offline_sync/domain/repositories/sync_repository.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {
  final SyncLocalDataSource _local;
  final ApiClient _apiClient;

  SyncRepositoryImpl(this._local, this._apiClient);

  @override
  Future<Either<Failure, void>> enqueueAction({
    required String actionType,
    required String endpoint,
    required Map<String, dynamic> payload,
    String method = 'POST',
  }) async {
    try {
      await _local.enqueue(
        actionType: actionType,
        endpoint: endpoint,
        payload: payload,
        method: method,
      );
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> processQueue() async {
    try {
      final actions = await _local.getPending();
      if (actions.isEmpty) return const Right(0);

      int successCount = 0;

      for (final action in actions) {
        try {
          final payload = jsonDecode(action.payload) as Map<String, dynamic>;

          if (action.method == 'POST') {
            await _apiClient.post(
              url: action.endpoint,
              payload: payload,
              options: ApiClient.protected,
            );
          } else if (action.method == 'PATCH') {
            await _apiClient.patch(
              url: action.endpoint,
              payload: payload,
              options: ApiClient.protected,
            );
          }

          await _local.delete(action.id);
          successCount++;
        } catch (e) {
          if (action.retryCount + 1 >= 3) {
            await _local.markFailed(action.id);
          } else {
            await _local.incrementRetry(action.id);
          }
        }
      }

      return Right(successCount);
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      final count = await _local.getPendingCount();
      return Right(count);
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }
}
