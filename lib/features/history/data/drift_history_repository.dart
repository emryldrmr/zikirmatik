import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../domain/daily_history.dart';
import '../domain/history_repository.dart';

/// [HistoryRepository] backed by the `daily_counts` table (see
/// `daily_counts_table.dart`).
///
/// Each change is one atomic statement, so rapid taps never overwrite each
/// other (plan 0014, R2). Takes any [GeneratedDatabase] that registers the
/// table (docs/architecture.md, FD-2).
final class DriftHistoryRepository implements HistoryRepository {
  DriftHistoryRepository(this._db);

  final GeneratedDatabase _db;

  @override
  Future<Result<DailyHistory>> load() => _guard(() async {
    final rows = await _db
        .customSelect('SELECT day, count FROM daily_counts WHERE count > 0')
        .get();
    return DailyHistory({
      for (final row in rows)
        if (Day.tryParse(row.read<String>('day')) case final Day day)
          day: row.read<int>('count'),
    });
  });

  @override
  Future<Result<void>> add(Day day) => _guard(
    () => _db.customStatement(
      'INSERT INTO daily_counts (day, count) VALUES (?, 1) '
      'ON CONFLICT(day) DO UPDATE SET count = count + 1',
      [day.iso],
    ),
  );

  @override
  Future<Result<void>> remove(Day day) => _guard(
    () => _db.customStatement(
      'UPDATE daily_counts SET count = count - 1 WHERE day = ? AND count > 0',
      [day.iso],
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
