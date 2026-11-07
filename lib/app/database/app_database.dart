import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/counter/data/counter_table.dart';
import '../../features/counter/data/dhikr_tables.dart';
import '../../features/counter/data/tesbihat_table.dart';
import '../../features/settings/data/settings_table.dart';

part 'app_database.g.dart';

/// The app's single on-device database. Lives in the composition root so that
/// every feature's tables register here without features importing each other.
@DriftDatabase(
  tables: [Counters, Dhikrs, DhikrSelections, Settings, TesbihatProgress],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database file.
  factory AppDatabase.onDevice() =>
      AppDatabase(driftDatabase(name: 'zikirmatik'));

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedFirstDhikr();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Spec 0002: rounds, total and target. The count kept from spec 0001
        // becomes the starting total (spec 0002, G6).
        await m.addColumn(counters, counters.rounds);
        await m.addColumn(counters, counters.total);
        await m.addColumn(counters, counters.target);
        await customStatement('UPDATE counters SET total = count');
      }
      if (from < 3) {
        // Spec 0003: named dhikrs. The existing counter (id 1) becomes the
        // first dhikr with all its values (spec 0003, AC-1).
        await m.createTable(dhikrs);
        await m.createTable(dhikrSelections);
        await _seedFirstDhikr();
      }
      if (from < 4) {
        // Spec 0004: preferences. No row means the defaults, so nothing is
        // seeded and the dhikrs are untouched.
        await m.createTable(settings);
      }
      if (from < 5) {
        // Spec 0006: the tesbihat. No row means it has not started and is not
        // selected, so nothing is seeded; dhikrs and settings are untouched.
        await m.createTable(tesbihatProgress);
      }
      if (from >= 4 && from < 6) {
        // Spec 0009: vibration per count, off for kept settings (AC-1). Before
        // v4 the table is created above with the column already in it.
        await m.addColumn(settings, settings.tapVibration);
      }
      if (from >= 4 && from < 7) {
        // Spec 0010: keep the screen on, off for kept settings (AC-8).
        await m.addColumn(settings, settings.keepScreenOn);
      }
      if (from >= 4 && from < 8) {
        // Spec 0011: normal digits and the centre layout for kept settings
        // (AC-1).
        await m.addColumn(settings, settings.largeCount);
        await m.addColumn(settings, settings.handLayout);
      }
    },
  );

  /// The first dhikr "Zikir" (spec 0003, G1/G2): id 1, its counter row (kept
  /// if it already exists), selected.
  Future<void> _seedFirstDhikr() async {
    await customStatement("INSERT INTO dhikrs (id, name) VALUES (1, 'Zikir')");
    await customStatement(
      'INSERT OR IGNORE INTO counters (id, count) VALUES (1, 0)',
    );
    await customStatement(
      'INSERT INTO dhikr_selections (id, dhikr_id) VALUES (1, 1)',
    );
  }
}
