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
  int get schemaVersion => 1;
}
