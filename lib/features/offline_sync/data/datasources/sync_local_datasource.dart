import 'package:injectable/injectable.dart';
import 'package:my_wellness/features/offline_sync/data/local/app_database.dart';

@lazySingleton
class SyncLocalDataSource {
  final AppDatabase _db;
  SyncLocalDataSource(this._db);

  Future<void> enqueue({
    required String actionType,
    required String endpoint,
    required Map<String, dynamic> payload,
    String method = 'POST',
  }) {
    return _db.enqueueAction(
      actionType: actionType,
      endpoint: endpoint,
      payload: payload,
      method: method,
    );
  }

  Future<List<PendingSyncAction>> getPending() => _db.getPendingActions();
  Future<void> delete(int id) => _db.deleteAction(id);
  Future<void> deleteMany(List<int> ids) => _db.deleteActions(ids);
  Future<void> incrementRetry(int id) => _db.incrementRetry(id);
  Future<void> markFailed(int id) => _db.markFailed(id);
  Future<int> getPendingCount() => _db.getPendingCount();
}
