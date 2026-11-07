import 'package:drift/drift.dart';

import '../../../core/hand_layout.dart';
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
            'SELECT vibration, theme, tap_vibration, keep_screen_on, '
            'large_count, hand_layout FROM settings WHERE id = 1',
          )
          .getSingleOrNull();
      if (row == null) return const Ok(AppSettings.defaults);
      final theme = ThemeChoice.byName(row.read<String>('theme'));
      if (theme == null) {
        return Err(
          StorageFailure('unknown theme ${row.read<String>('theme')}'),
        );
      }
      final hand = HandLayout.byName(row.read<String>('hand_layout'));
      if (hand == null) {
        return Err(
          StorageFailure(
            'unknown hand layout ${row.read<String>('hand_layout')}',
          ),
        );
      }
      return Ok(
        AppSettings(
          vibration: row.read<bool>('vibration'),
          theme: theme,
          tapVibration: row.read<bool>('tap_vibration'),
          keepScreenOn: row.read<bool>('keep_screen_on'),
          largeCount: row.read<bool>('large_count'),
          handLayout: hand,
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
        '(id, vibration, theme, tap_vibration, keep_screen_on, large_count, '
        'hand_layout) VALUES (1, ?, ?, ?, ?, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET vibration = excluded.vibration, '
        'theme = excluded.theme, tap_vibration = excluded.tap_vibration, '
        'keep_screen_on = excluded.keep_screen_on, '
        'large_count = excluded.large_count, '
        'hand_layout = excluded.hand_layout',
        [
          if (settings.vibration) 1 else 0,
          settings.theme.name,
          if (settings.tapVibration) 1 else 0,
          if (settings.keepScreenOn) 1 else 0,
          if (settings.largeCount) 1 else 0,
          settings.handLayout.name,
        ],
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }
}
