import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// [SettingsRepository] backed by the single-row `settings` table (see
/// `settings_table.dart`).
///
/// Takes any [GeneratedDatabase] that registers that table, so the feature does
/// not depend on the app's database class (docs/architecture.md, FD-2).
final class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final GeneratedDatabase _db;

  @override
  Future<Result<AppSettings>> load() async {
    try {
      final row = await _db
          .customSelect(
            'SELECT vibration, theme, tap_vibration, keep_screen_on '
            'FROM settings WHERE id = 1',
          )
          .getSingleOrNull();
      if (row == null) return const Ok(AppSettings.defaults);
      final theme = ThemeChoice.byName(row.read<String>('theme'));
      if (theme == null) {
        return Err(
          StorageFailure('unknown theme ${row.read<String>('theme')}'),
        );
      }
      return Ok(
        AppSettings(
          vibration: row.read<bool>('vibration'),
          theme: theme,
          tapVibration: row.read<bool>('tap_vibration'),
          keepScreenOn: row.read<bool>('keep_screen_on'),
        ),
      );
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }

  @override
  Future<Result<void>> save(AppSettings settings) async {
    try {
      await _db.customStatement(
        'INSERT INTO settings '
        '(id, vibration, theme, tap_vibration, keep_screen_on) '
        'VALUES (1, ?, ?, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET vibration = excluded.vibration, '
        'theme = excluded.theme, tap_vibration = excluded.tap_vibration, '
        'keep_screen_on = excluded.keep_screen_on',
        [
          if (settings.vibration) 1 else 0,
          settings.theme.name,
          if (settings.tapVibration) 1 else 0,
          if (settings.keepScreenOn) 1 else 0,
        ],
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }
}
