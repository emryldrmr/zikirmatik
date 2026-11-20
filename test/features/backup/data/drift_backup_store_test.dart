import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/core/hand_layout.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/backup/data/drift_backup_store.dart';
import 'package:zikirmatik/features/backup/domain/backup_snapshot.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/history/domain/badges.dart';
import 'package:zikirmatik/features/history/history.dart';
import 'package:zikirmatik/features/settings/settings.dart';

// Spec 0018 — JSON yedekleme, storage on the real schema (AC-3, AC-5, AC-7).

T _ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

const _changedSettings = AppSettings(
  vibration: false,
  theme: ThemeChoice.dark,
  tapVibration: true,
  keepScreenOn: true,
  largeCount: true,
  handLayout: HandLayout.left,
  continueNotification: true,
);

final _today = Day(2026, 11, 19);

/// Everything the app reads at start, through the features' own repositories.
typedef _Seen = ({
  DhikrList list,
  Map<int, CounterState> counters,
  TesbihatState tesbihat,
  DailyHistory history,
  AppSettings settings,
});

Future<_Seen> _see(AppDatabase db) async {
  final list = _ok(await DriftDhikrListRepository(db).load());
  return (
    list: list,
    counters: {
      for (final e in list.entries)
        e.id: _ok(await DriftCounterRepository(db, dhikrId: e.id).load()),
    },
    tesbihat: _ok(await DriftTesbihatRepository(db).load()),
    history: _ok(await DriftHistoryRepository(db).load()),
    settings: _ok(await DriftSettingsRepository(db).load()),
  );
}

/// The AC-3 data: dhikrs with and without a target (count, rounds, total,
/// order), a selected dhikr, the tesbihat part way, three days, every
/// setting changed from its default.
Future<void> _seed(AppDatabase db) async {
  final dhikrs = DriftDhikrListRepository(db);
  // Dhikr 1 "Zikir" exists on a new database.
  final second = _ok(
    await dhikrs.add(DhikrName.stored('Sübhânallah'), Target.of(33)),
  );
  final third = _ok(
    await dhikrs.add(DhikrName.stored('Estağfirullah'), null, select: false),
  );
  await DriftCounterRepository(
    db,
    dhikrId: 1,
  ).save(const CounterState(count: DhikrCount(7), total: 7));
  await DriftCounterRepository(db, dhikrId: second.id).save(
    CounterState(
      count: const DhikrCount(12),
      rounds: 4,
      total: 144,
      target: Target.of(33),
    ),
  );
  await DriftCounterRepository(
    db,
    dhikrId: third.id,
  ).save(const CounterState(count: DhikrCount(250), total: 250));
  await DriftTesbihatRepository(
    db,
  ).save(const TesbihatState(step: 1, count: DhikrCount(5), completions: 3));
  final history = DriftHistoryRepository(db);
  for (final (day, n) in [
    (_today, 3),
    (_today.previous, 2),
    (_today.previous.previous.previous, 1),
  ]) {
    for (var i = 0; i < n; i++) {
      await history.add(day);
    }
  }
  await DriftSettingsRepository(db).save(_changedSettings);
}

/// The AC-3 changes after the backup: delete, add, count, settings, days.
Future<void> _change(AppDatabase db) async {
  final dhikrs = DriftDhikrListRepository(db);
  await dhikrs.delete(2);
  final added = _ok(await dhikrs.add(DhikrName.stored('Yeni'), null));
  await DriftCounterRepository(
    db,
    dhikrId: added.id,
  ).save(const CounterState(count: DhikrCount(9), total: 9));
  await DriftCounterRepository(
    db,
    dhikrId: 1,
  ).save(const CounterState(count: DhikrCount(70), total: 70));
  await DriftTesbihatRepository(
    db,
  ).save(const TesbihatState(finished: true, step: 2, completions: 4));
  await DriftHistoryRepository(db).add(_today.next);
  await DriftHistoryRepository(db).add(Day(2026, 1, 1));
  await DriftSettingsRepository(db).save(AppSettings.defaults);
}

AppDatabase _memory() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('round trip restores every table', () async {
    final db = _memory();
    await _seed(db);
    final before = await _see(db);
    final store = DriftBackupStore(db);
    final data = _ok(await store.read());

    await _change(db);
    expect((await _see(db)).list, isNot(before.list));

    _ok(await store.replaceAll(data));
    final after = await _see(db);
    expect(after.list, before.list);
    expect(after.list.selectedId, 2);
    expect(after.counters, before.counters);
    expect(after.tesbihat, before.tesbihat);
    expect(after.history, before.history);
    expect(after.settings, _changedSettings);
    expect(_ok(await store.read()), data);
  });

  test('streak and badges match', () async {
    final db = _memory();
    await _seed(db);
    final store = DriftBackupStore(db);
    final data = _ok(await store.read());
    final before = (await _see(db)).history;

    await _change(db);
    _ok(await store.replaceAll(data));
    final after = (await _see(db)).history;

    expect(after.streak(_today), before.streak(_today));
    expect(after.streak(_today), 2);
    expect(after.longestStreak(_today), before.longestStreak(_today));
    final badges = BadgeProgress(
      longest: after.longestStreak(_today),
      current: after.streak(_today),
    );
    expect(badges.latestEarned, StreakBadge.firstDay);
    expect(badges.daysToNext, 5);
  });

  test('replace leaves no extra dhikrs or days', () async {
    final db = _memory();
    await _seed(db);
    final store = DriftBackupStore(db);
    final data = BackupData(
      dhikrs: const [
        BackupDhikr(
          id: 2,
          name: 'Sübhânallah',
          target: 33,
          count: 1,
          rounds: 0,
          total: 1,
        ),
      ],
      selectedDhikrId: 2,
      tesbihat: const BackupTesbihat(),
      days: const [BackupDay('2026-11-01', 5)],
      settings: _ok(await store.read()).settings,
    );

    _ok(await store.replaceAll(data));
    final seen = await _see(db);
    expect(seen.list.entries.map((e) => e.id), [2]);
    expect(seen.counters.keys, [2]);
    expect(seen.history, DailyHistory({Day(2026, 11, 1): 5}));
    // No counter row is left behind for a dhikr that is gone.
    final rows = await db.customSelect('SELECT id FROM counters').get();
    expect(rows.map((r) => r.read<int>('id')), [2]);
  });

  test('empty backup leaves my dhikrs empty', () async {
    final db = _memory();
    await _seed(db);
    final store = DriftBackupStore(db);
    _ok(
      await store.replaceAll(
        BackupData(
          dhikrs: const [],
          selectedDhikrId: null,
          tesbihat: const BackupTesbihat(),
          days: const [],
          settings: _ok(await store.read()).settings,
        ),
      ),
    );
    final seen = await _see(db);
    expect(seen.list.isEmpty, isTrue);
    expect(seen.history, DailyHistory.empty);
    expect(seen.tesbihat, TesbihatState.initial);
  });

  test('restored data loads after reopen', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    final source = _memory();
    await _seed(source);
    final before = await _see(source);
    final data = _ok(await DriftBackupStore(source).read());

    final first = AppDatabase(NativeDatabase(file));
    _ok(await DriftBackupStore(first).replaceAll(data));
    await first.close();

    final reopened = AppDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    final after = await _see(reopened);
    expect(after.list, before.list);
    expect(after.counters, before.counters);
    expect(after.tesbihat, before.tesbihat);
    expect(after.history, before.history);
    expect(after.settings, before.settings);
  });

  test('failed replace rolls back', () async {
    final db = _memory();
    await _seed(db);
    final store = DriftBackupStore(db);
    final data = _ok(await store.read());
    await _change(db);
    final before = await _see(db);
    final raw = _ok(await store.read());

    // The last table written fails, after every other one was replaced.
    await db.customStatement(
      'CREATE TRIGGER fail_settings BEFORE INSERT ON settings '
      "BEGIN SELECT RAISE(ABORT, 'disk full'); END",
    );
    expect(await store.replaceAll(data), isA<Err<void>>());

    final after = await _see(db);
    expect(after.list, before.list);
    expect(after.counters, before.counters);
    expect(after.tesbihat, before.tesbihat);
    expect(after.history, before.history);
    expect(after.settings, before.settings);
    expect(_ok(await store.read()), raw);
  });

  test('a stored selection that points nowhere is read as none', () async {
    final db = _memory();
    await db.customStatement(
      'UPDATE dhikr_selections SET dhikr_id = 42 WHERE id = 1',
    );
    final data = _ok(await DriftBackupStore(db).read());
    expect(data.dhikrs.map((d) => d.id), [1]);
    expect(data.selectedDhikrId, isNull);
  });

  test('a new database reads as the defaults', () async {
    final data = _ok(await DriftBackupStore(_memory()).read());
    expect(data.dhikrs.single.name, 'Zikir');
    expect(data.days, isEmpty);
    expect(data.tesbihat, const BackupTesbihat());
    expect(data.settings.theme, 'system');
    expect(data.settings.vibration, isTrue);
  });
}
