import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'app_database.g.dart';

class PendingSyncActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()();
  TextColumn get payload => text()();
  TextColumn get endpoint => text()();
  TextColumn get method => text().withDefault(const Constant('POST'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class CachedAssessments extends Table {
  TextColumn get slug => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {slug};
}

@DriftDatabase(tables: [PendingSyncActions, SyncMetadata, CachedAssessments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(cachedAssessments);
      }
    },
  );

  Future<int> enqueueAction({
    required String actionType,
    required String endpoint,
    required Map<String, dynamic> payload,
    String method = 'POST',
  }) {
    return into(pendingSyncActions).insert(
      PendingSyncActionsCompanion.insert(
        actionType: actionType,
        endpoint: endpoint,
        method: Value(method),
        payload: jsonEncode(payload),
      ),
    );
  }

  Future<List<PendingSyncAction>> getPendingActions() {
    return (select(pendingSyncActions)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  Future<void> deleteAction(int id) {
    return (delete(pendingSyncActions)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteActions(List<int> ids) async {
    if (ids.isEmpty) return;
    await (delete(pendingSyncActions)..where((t) => t.id.isIn(ids))).go();
  }

  Future<void> incrementRetry(int id) {
    return customUpdate(
      'UPDATE pending_sync_actions SET retry_count = retry_count + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
    );
  }

  Future<void> markFailed(int id) {
    return customUpdate(
      "UPDATE pending_sync_actions SET status = 'failed' WHERE id = ?",
      variables: [Variable.withInt(id)],
    );
  }

  Future<int> getPendingCount() async {
    final countExp = pendingSyncActions.id.count();
    final query = selectOnly(pendingSyncActions)
      ..addColumns([countExp])
      ..where(pendingSyncActions.status.equals('pending'));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<void> cacheAssessment(String slug, String jsonString) {
    return into(cachedAssessments).insertOnConflictUpdate(
      CachedAssessmentsCompanion.insert(slug: slug, json: jsonString),
    );
  }

  Future<String?> getCachedAssessment(String slug) async {
    final row = await (select(
      cachedAssessments,
    )..where((t) => t.slug.equals(slug))).getSingleOrNull();
    return row?.json;
  }

  Future<String?> getCachedPayload(String key) => getCachedAssessment(key);

  Future<void> cachePayload(String key, String jsonString) =>
      cacheAssessment(key, jsonString);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'my_wellness_offline.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
