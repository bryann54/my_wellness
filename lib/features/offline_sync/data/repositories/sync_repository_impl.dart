import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/offline_sync/data/datasources/sync_local_datasource.dart';
import 'package:my_wellness/features/offline_sync/data/local/app_database.dart';
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

      var successCount = 0;
      var index = 0;

      while (index < actions.length) {
        final action = actions[index];
        final isAssessmentBatch =
            action.actionType == 'assessment_answer' && action.method == 'POST';
        final batch = <PendingSyncAction>[action];
        if (isAssessmentBatch) {
          var next = index + 1;
          while (next < actions.length &&
              actions[next].actionType == action.actionType &&
              actions[next].endpoint == action.endpoint &&
              actions[next].method == action.method) {
            batch.add(actions[next]);
            next++;
          }
        }

        try {
          if (isAssessmentBatch) {
            final answers = batch
                .expand(
                  (PendingSyncAction queued) => _answersFromPayload(
                    jsonDecode(queued.payload) as Map<String, dynamic>,
                  ),
                )
                .toList(growable: false);
            final response = await _apiClient.post<Map<String, dynamic>>(
              url: action.endpoint,
              payload: {'answers': answers},
              options: ApiClient.protected,
            );
            final applied =
                (response['applied_count'] as num?)?.toInt().clamp(
                  0,
                  batch.length,
                ) ??
                0;
            final appliedActions = batch.take(applied).toList();
            await _local.deleteMany(
              appliedActions.map((queued) => queued.id).toList(),
            );
            successCount += appliedActions.length;

            if (applied < batch.length) {
              for (final queued in batch.skip(applied)) {
                await _recordFailure(queued);
              }
              // Preserve answer order: don't send later queue entries until
              // the unapplied prefix has been resolved.
              break;
            }
          } else if (action.method == 'PATCH') {
            final payload = jsonDecode(action.payload) as Map<String, dynamic>;
            await _apiClient.patch(
              url: action.endpoint,
              payload: payload,
              options: ApiClient.protected,
            );
            await _local.delete(action.id);
            successCount++;
          } else if (action.method == 'POST') {
            final payload = jsonDecode(action.payload) as Map<String, dynamic>;
            await _apiClient.post(
              url: action.endpoint,
              payload: payload,
              options: ApiClient.protected,
            );
            await _local.delete(action.id);
            successCount++;
          }
        } catch (e) {
          for (final queued in batch) {
            await _recordFailure(queued);
          }
          if (isAssessmentBatch) break;
        }
        index += batch.length;
      }

      return Right(successCount);
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  List<Map<String, dynamic>> _answersFromPayload(Map<String, dynamic> payload) {
    final answers = payload['answers'];
    if (answers is List) {
      return answers
          .whereType<Map>()
          .map((answer) => Map<String, dynamic>.from(answer))
          .toList(growable: false);
    }
    // Migrate actions queued by the earlier single-answer payload format.
    if (payload['question_index'] != null && payload['answer'] != null) {
      return [
        {
          'question_index': payload['question_index'],
          'answer': payload['answer'],
        },
      ];
    }
    throw const FormatException('Queued assessment answer is invalid');
  }

  Future<void> _recordFailure(PendingSyncAction action) async {
    if (action.retryCount + 1 >= 3) {
      await _local.markFailed(action.id);
    } else {
      await _local.incrementRetry(action.id);
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
