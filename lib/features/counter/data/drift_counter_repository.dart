import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../domain/counter_repository.dart';
import '../domain/dhikr_count.dart';

/// [CounterRepository] backed by the `counters` table (see `counter_table.dart`).
///
/// Takes any [GeneratedDatabase] that registers that table, so the feature does
/// not depend on the app's database class (docs/architecture.md, FD-2).
final class DriftCounterRepository implements CounterRepository {
  DriftCounterRepository(this._db);

  static const int _skeletonCounterId = 1;

  final GeneratedDatabase _db;

  @override
  Future<Result<DhikrCount>> load() async {
    try {
      final row = await _db
          .customSelect(
            'SELECT count FROM counters WHERE id = ?',
            variables: [Variable.withInt(_skeletonCounterId)],
          )
          .getSingleOrNull();
      return Ok(DhikrCount(row?.read<int>('count') ?? 0));
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }

  @override
  Future<Result<void>> save(DhikrCount count) async {
    try {
      await _db.customStatement(
        'INSERT INTO counters (id, count) VALUES (?, ?) '
        'ON CONFLICT(id) DO UPDATE SET count = excluded.count',
        [_skeletonCounterId, count.value],
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }
}
