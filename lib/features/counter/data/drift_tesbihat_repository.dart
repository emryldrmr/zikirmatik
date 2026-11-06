import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../domain/dhikr_count.dart';
import '../domain/tesbihat.dart';
import '../domain/tesbihat_repository.dart';
import '../domain/tesbihat_state.dart';

/// [TesbihatRepository] backed by the `tesbihat_progress` table (see
/// `tesbihat_table.dart`).
///
/// Takes any [GeneratedDatabase] that registers that table, so the feature
/// does not depend on the app's database class (docs/architecture.md, FD-2).
final class DriftTesbihatRepository implements TesbihatRepository {
  DriftTesbihatRepository(this._db);

  final GeneratedDatabase _db;

  @override
  Future<Result<TesbihatState>> load() => _guard(() async {
    final row = await _db
        .customSelect(
          'SELECT step, count, finished, completions, selected '
          'FROM tesbihat_progress WHERE id = 1',
        )
        .getSingleOrNull();
    if (row == null) return TesbihatState.initial;
    final state = TesbihatState(
      step: row.read<int>('step'),
      count: DhikrCount(row.read<int>('count')),
      finished: row.read<bool>('finished'),
      completions: row.read<int>('completions'),
      selected: row.read<bool>('selected'),
    );
    // A row that does not fit the steps (never written by this app) starts
    // the tesbihat again; completions and the selection stay.
    return state.fits(namazSonrasiTesbihat) ? state : state.restart();
  });

  @override
  Future<Result<void>> save(TesbihatState state) => _guard(
    () => _db.customStatement(
      'INSERT INTO tesbihat_progress '
      '(id, step, count, finished, completions, selected) '
      'VALUES (1, ?, ?, ?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET step = excluded.step, '
      'count = excluded.count, finished = excluded.finished, '
      'completions = excluded.completions, selected = excluded.selected',
      [
        state.step,
        state.count.value,
        state.finished ? 1 : 0,
        state.completions,
        state.selected ? 1 : 0,
      ],
    ),
  );

  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Ok(await body());
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }
}
