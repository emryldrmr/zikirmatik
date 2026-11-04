import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../domain/counter_repository.dart';
import '../domain/counter_state.dart';
import '../domain/dhikr_count.dart';
import '../domain/target.dart';

/// [CounterRepository] backed by the `counters` table (see `counter_table.dart`).
///
/// Takes any [GeneratedDatabase] that registers that table, so the feature does
/// not depend on the app's database class (docs/architecture.md, FD-2).
final class DriftCounterRepository implements CounterRepository {
  /// [dhikrId] is the dhikr whose counter this is (spec 0003); 1 is the first
  /// dhikr, the single counter of specs 0001 and 0002.
  DriftCounterRepository(this._db, {this.dhikrId = 1});

  final int dhikrId;

  final GeneratedDatabase _db;

  @override
  Future<Result<CounterState>> load() async {
    try {
      final row = await _db
          .customSelect(
            'SELECT count, rounds, total, target FROM counters WHERE id = ?',
            variables: [Variable.withInt(dhikrId)],
          )
          .getSingleOrNull();
      if (row == null) return const Ok(CounterState.initial);
      final target = row.read<int?>('target');
      return Ok(
        CounterState(
          count: DhikrCount(row.read<int>('count')),
          rounds: row.read<int>('rounds'),
          total: row.read<int>('total'),
          target: target == null ? null : Target.of(target),
        ),
      );
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }

  @override
  Future<Result<void>> save(CounterState state) async {
    try {
      await _db.customStatement(
        'INSERT INTO counters (id, count, rounds, total, target) '
        'VALUES (?, ?, ?, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET count = excluded.count, '
        'rounds = excluded.rounds, total = excluded.total, '
        'target = excluded.target',
        [
          dhikrId,
          state.count.value,
          state.rounds,
          state.total,
          state.target?.value,
        ],
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }
}
