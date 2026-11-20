import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../../counter/counter.dart';
import '../../history/history.dart';
import '../../settings/settings.dart';
import '../domain/backup_ports.dart';
import '../domain/backup_snapshot.dart';

/// [BackupStore] over the six tables that hold the user's data (plan 0018,
/// R1): `dhikrs`, `counters`, `dhikr_selections`, `tesbihat_progress`,
/// `daily_counts`, `settings`. Reads and replaces them in one transaction, so
/// a restore is all or nothing (spec 0018, Req. 5). Raw SQL on any
/// [GeneratedDatabase] that registers those tables, like the features' own
/// repositories (docs/architecture.md, FD-2); the round-trip test on the real
/// schema turns red when a column is added.
final class DriftBackupStore implements BackupStore {
  DriftBackupStore(this._db);

  final GeneratedDatabase _db;

  @override
  Future<Result<BackupData>> read() => _guard(
    () => _db.transaction(() async {
      final dhikrs = [
        for (final r
            in await _db
                .customSelect(
                  'SELECT d.id, d.name, c.target, '
                  'COALESCE(c.count, 0) AS count, '
                  'COALESCE(c.rounds, 0) AS rounds, '
                  'COALESCE(c.total, 0) AS total '
                  'FROM dhikrs d LEFT JOIN counters c ON c.id = d.id '
                  'ORDER BY d.id',
                )
                .get())
          BackupDhikr(
            id: r.read<int>('id'),
            name: r.read<String>('name'),
            target: r.read<int?>('target'),
            count: r.read<int>('count'),
            rounds: r.read<int>('rounds'),
            total: r.read<int>('total'),
          ),
      ];
      final selection =
          (await _db
                  .customSelect(
                    'SELECT dhikr_id FROM dhikr_selections WHERE id = 1',
                  )
                  .getSingleOrNull())
              ?.read<int?>('dhikr_id');
      return BackupData(
        dhikrs: dhikrs,
        // A selection that points nowhere opens on the first dhikr, as no
        // selection does (spec 0003), so the backup holds none.
        selectedDhikrId: dhikrs.any((d) => d.id == selection)
            ? selection
            : null,
        tesbihat: await _readTesbihat(),
        days: [
          for (final r
              in await _db
                  .customSelect(
                    'SELECT day, count FROM daily_counts WHERE count > 0 '
                    'ORDER BY day',
                  )
                  .get())
            if (Day.tryParse(r.read<String>('day')) != null)
              BackupDay(r.read<String>('day'), r.read<int>('count')),
        ],
        settings: await _readSettings(),
      );
    }),
  );

  /// As the tesbihat's own load: a row that does not fit the steps starts
  /// again, keeping completions and the selection.
  Future<BackupTesbihat> _readTesbihat() async {
    final r = await _db
        .customSelect(
          'SELECT step, count, finished, completions, selected '
          'FROM tesbihat_progress WHERE id = 1',
        )
        .getSingleOrNull();
    if (r == null) return const BackupTesbihat();
    final state = TesbihatState(
      step: r.read<int>('step'),
      count: DhikrCount(r.read<int>('count')),
      finished: r.read<bool>('finished'),
      completions: r.read<int>('completions'),
      selected: r.read<bool>('selected'),
    );
    final fit = state.fits(namazSonrasiTesbihat) ? state : state.restart();
    return BackupTesbihat(
      step: fit.step,
      count: fit.count.value,
      finished: fit.finished,
      completions: fit.completions,
      selected: fit.selected,
    );
  }

  Future<BackupSettings> _readSettings() async {
    final r = await _db
        .customSelect(
          'SELECT vibration, theme, tap_vibration, keep_screen_on, '
          'large_count, hand_layout, continue_notification FROM settings '
          'WHERE id = 1',
        )
        .getSingleOrNull();
    if (r == null) {
      const d = AppSettings.defaults;
      return BackupSettings(
        vibration: d.vibration,
        theme: d.theme.name,
        tapVibration: d.tapVibration,
        keepScreenOn: d.keepScreenOn,
        largeCount: d.largeCount,
        handLayout: d.handLayout.name,
        continueNotification: d.continueNotification,
      );
    }
    return BackupSettings(
      vibration: r.read<bool>('vibration'),
      theme: r.read<String>('theme'),
      tapVibration: r.read<bool>('tap_vibration'),
      keepScreenOn: r.read<bool>('keep_screen_on'),
      largeCount: r.read<bool>('large_count'),
      handLayout: r.read<String>('hand_layout'),
      continueNotification: r.read<bool>('continue_notification'),
    );
  }

  @override
  Future<Result<void>> replaceAll(BackupData data) => _guard(
    () => _db.transaction(() async {
      for (final table in const [
        'counters',
        'dhikrs',
        'dhikr_selections',
        'tesbihat_progress',
        'daily_counts',
        'settings',
      ]) {
        await _db.customStatement('DELETE FROM $table');
      }
      for (final d in data.dhikrs) {
        await _db.customStatement(
          'INSERT INTO dhikrs (id, name) VALUES (?, ?)',
          [d.id, d.name],
        );
        await _db.customStatement(
          'INSERT INTO counters (id, count, rounds, total, target) '
          'VALUES (?, ?, ?, ?, ?)',
          [d.id, d.count, d.rounds, d.total, d.target],
        );
      }
      await _db.customStatement(
        'INSERT INTO dhikr_selections (id, dhikr_id) VALUES (1, ?)',
        [data.selectedDhikrId],
      );
      final t = data.tesbihat;
      await _db.customStatement(
        'INSERT INTO tesbihat_progress '
        '(id, step, count, finished, completions, selected) '
        'VALUES (1, ?, ?, ?, ?, ?)',
        [t.step, t.count, _bit(t.finished), t.completions, _bit(t.selected)],
      );
      for (final d in data.days) {
        await _db.customStatement(
          'INSERT INTO daily_counts (day, count) VALUES (?, ?)',
          [d.day, d.count],
        );
      }
      final s = data.settings;
      await _db.customStatement(
        'INSERT INTO settings '
        '(id, vibration, theme, tap_vibration, keep_screen_on, large_count, '
        'hand_layout, continue_notification) VALUES (1, ?, ?, ?, ?, ?, ?, ?)',
        [
          _bit(s.vibration),
          s.theme,
          _bit(s.tapVibration),
          _bit(s.keepScreenOn),
          _bit(s.largeCount),
          s.handLayout,
          _bit(s.continueNotification),
        ],
      );
    }),
  );

  static int _bit(bool value) => value ? 1 : 0;

  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Ok(await body());
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }
}
