import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../domain/dhikr_list.dart';
import '../domain/dhikr_list_repository.dart';
import '../domain/dhikr_name.dart';
import '../domain/target.dart';

/// [DhikrListRepository] backed by the `dhikrs`, `dhikr_selections` and
/// `counters` tables (see `dhikr_tables.dart`, `counter_table.dart`).
///
/// Takes any [GeneratedDatabase] that registers those tables, so the feature
/// does not depend on the app's database class (docs/architecture.md, FD-2).
final class DriftDhikrListRepository implements DhikrListRepository {
  DriftDhikrListRepository(this._db);

  final GeneratedDatabase _db;

  @override
  Future<Result<DhikrList>> load() => _guard(() async {
    final rows = await _db
        .customSelect('SELECT id, name FROM dhikrs ORDER BY id')
        .get();
    final selection = await _db
        .customSelect('SELECT dhikr_id FROM dhikr_selections WHERE id = 1')
        .getSingleOrNull();
    return DhikrList([
      for (final r in rows)
        DhikrEntry(r.read<int>('id'), DhikrName.stored(r.read<String>('name'))),
    ], selectedId: selection?.read<int?>('dhikr_id'));
  });

  @override
  Future<Result<DhikrEntry>> add(DhikrName name, Target? target) => _guard(
    () => _db.transaction(() async {
      final id = await _db.customInsert(
        'INSERT INTO dhikrs (name) VALUES (?)',
        variables: [Variable.withString(name.value)],
      );
      await _db.customStatement(
        'INSERT OR REPLACE INTO counters (id, count, rounds, total, target) '
        'VALUES (?, 0, 0, 0, ?)',
        [id, target?.value],
      );
      await _writeSelection(id);
      return DhikrEntry(id, name);
    }),
  );

  @override
  Future<Result<void>> rename(int id, DhikrName name) => _guard(
    () => _db.customStatement('UPDATE dhikrs SET name = ? WHERE id = ?', [
      name.value,
      id,
    ]),
  );

  @override
  Future<Result<void>> delete(int id) => _guard(
    () => _db.transaction(() async {
      // Foreign keys are not enforced; both rows go in one transaction (plan 0003, R3).
      await _db.customStatement('DELETE FROM counters WHERE id = ?', [id]);
      await _db.customStatement('DELETE FROM dhikrs WHERE id = ?', [id]);
    }),
  );

  @override
  Future<Result<void>> select(int? id) => _guard(() => _writeSelection(id));

  Future<void> _writeSelection(int? id) => _db.customStatement(
    'INSERT INTO dhikr_selections (id, dhikr_id) VALUES (1, ?) '
    'ON CONFLICT(id) DO UPDATE SET dhikr_id = excluded.dhikr_id',
    [id],
  );

  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Ok(await body());
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }
}
