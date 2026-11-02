import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/counter/data/counter_table.dart';

part 'app_database.g.dart';

/// The app's single on-device database. Lives in the composition root so that
/// every feature's tables register here without features importing each other.
@DriftDatabase(tables: [Counters])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database file.
  factory AppDatabase.onDevice() =>
      AppDatabase(driftDatabase(name: 'zikirmatik'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Spec 0002: rounds, total and target. The count kept from spec 0001
        // becomes the starting total (spec 0002, G6).
        await m.addColumn(counters, counters.rounds);
        await m.addColumn(counters, counters.total);
        await m.addColumn(counters, counters.target);
        await customStatement('UPDATE counters SET total = count');
      }
    },
  );
}
