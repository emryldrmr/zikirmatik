import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/data/drift_counter_repository.dart';
import 'package:zikirmatik/features/counter/data/drift_dhikr_list_repository.dart';
import 'package:zikirmatik/features/counter/data/drift_tesbihat_repository.dart';
import 'package:zikirmatik/features/counter/domain/counter_state.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat_state.dart';
import 'package:zikirmatik/features/history/data/drift_history_repository.dart';
import 'package:zikirmatik/features/history/domain/daily_history.dart';
import 'package:zikirmatik/features/settings/data/drift_settings_repository.dart';
import 'package:zikirmatik/features/settings/domain/app_settings.dart';

// Spec 0014 — Günlük geçmiş ve seri, storage (AC-2, AC-9).

T _ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  final today = Day(2026, 11, 8);

  File tempDb() {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    return File('${dir.path}${Platform.pathSeparator}db.sqlite');
  }

  test('a new database has no history', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(_ok(await DriftHistoryRepository(db).load()), DailyHistory.empty);
  });

  test('add counts per day, rapid adds are all kept', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftHistoryRepository(db);

    // Not awaited one by one: every add is issued before the first finishes.
    await Future.wait([for (var i = 0; i < 50; i++) repo.add(today)]);
    await repo.add(today.previous);

    final h = _ok(await repo.load());
    expect(h.countOn(today), 50);
    expect(h.countOn(today.previous), 1);
  });

  test('remove stays at zero', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftHistoryRepository(db);

    await repo.add(today);
    expect(await repo.remove(today), isA<Ok<void>>());
    expect(await repo.remove(today), isA<Ok<void>>());
    expect(await repo.remove(today.next), isA<Ok<void>>());
    final h = _ok(await repo.load());
    expect(h, DailyHistory.empty);
  });

  test('days survive reopening', () async {
    final file = tempDb();
    final first = AppDatabase(NativeDatabase(file));
    final repo = DriftHistoryRepository(first);
    for (var i = 0; i < 3; i++) {
      await repo.add(today);
    }
    await repo.add(Day(2025, 12, 31));
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect(
      _ok(await DriftHistoryRepository(second).load()),
      DailyHistory({today: 3, Day(2025, 12, 31): 1}),
    );
  });

  test('the database refuses a negative count', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await expectLater(
      db.customStatement(
        "INSERT INTO daily_counts (day, count) VALUES ('2026-11-08', -1)",
      ),
      throwsA(anything),
    );
  });

  test('migrates a v8 database and keeps the rest', () async {
    // A database as spec 0013 left it: v9 without daily_counts is v8.
    final file = tempDb();
    final v8 = AppDatabase(NativeDatabase(file));
    final counter = DriftCounterRepository(v8, dhikrId: 1);
    const counted = CounterState(count: DhikrCount(7), rounds: 2, total: 73);
    await counter.save(counted);
    const midway = TesbihatState(step: 1, count: DhikrCount(4), selected: true);
    await DriftTesbihatRepository(v8).save(midway);
    const changed = AppSettings(vibration: false, theme: ThemeChoice.dark);
    await DriftSettingsRepository(v8).save(changed);
    await v8.customStatement('DROP TABLE daily_counts');
    await v8.customStatement('PRAGMA user_version = 8');
    await v8.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final history = DriftHistoryRepository(migrated);
    expect(_ok(await history.load()), DailyHistory.empty);
    await history.add(today);
    expect(_ok(await history.load()).countOn(today), 1);

    expect(
      _ok(await DriftCounterRepository(migrated, dhikrId: 1).load()),
      counted,
    );
    final list = _ok(await DriftDhikrListRepository(migrated).load());
    expect(list.entries.map((e) => e.name.value), ['Zikir']);
    expect(_ok(await DriftTesbihatRepository(migrated).load()), midway);
    expect(_ok(await DriftSettingsRepository(migrated).load()), changed);
  });
}
