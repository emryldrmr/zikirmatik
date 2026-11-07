import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/core/hand_layout.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/data/drift_counter_repository.dart';
import 'package:zikirmatik/features/counter/data/drift_dhikr_list_repository.dart';
import 'package:zikirmatik/features/counter/domain/counter_state.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';
import 'package:zikirmatik/features/counter/domain/target.dart';
import 'package:zikirmatik/features/settings/data/drift_settings_repository.dart';
import 'package:zikirmatik/features/settings/domain/app_settings.dart';

// Spec 0004 — Ayarlar, storage.

T _ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

void main() {
  // Several AppDatabase instances on purpose, each on its own executor.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('a new database has the default settings', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(_ok(await DriftSettingsRepository(db).load()), AppSettings.defaults);
  });

  test('settings survive reopening', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    const saved = AppSettings(vibration: false, theme: ThemeChoice.dark);
    expect(await DriftSettingsRepository(first).save(saved), isA<Ok<void>>());
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect(_ok(await DriftSettingsRepository(second).load()), saved);
  });

  test('saving again replaces the previous settings', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.save(
      const AppSettings(vibration: false, theme: ThemeChoice.dark),
    );
    await repo.save(
      const AppSettings(vibration: true, theme: ThemeChoice.light),
    );
    expect(
      _ok(await repo.load()),
      const AppSettings(vibration: true, theme: ThemeChoice.light),
    );
  });

  test('migrates a v3 database and keeps the dhikrs', () async {
    // A database as spec 0003 left it: schema v3, two dhikrs, the second selected.
    final v3 = NativeDatabase.memory(
      setup: (raw) {
        if (raw.userVersion != 0) return;
        raw
          ..execute(
            'CREATE TABLE counters (id INTEGER NOT NULL, '
            'count INTEGER NOT NULL CHECK (count >= 0), '
            'rounds INTEGER NOT NULL DEFAULT 0, total INTEGER NOT NULL DEFAULT 0, '
            'target INTEGER NULL, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE dhikrs (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
            'name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 50))',
          )
          ..execute(
            'CREATE TABLE dhikr_selections (id INTEGER NOT NULL CHECK (id = 1), '
            'dhikr_id INTEGER NULL, PRIMARY KEY (id))',
          )
          ..execute(
            "INSERT INTO dhikrs (id, name) VALUES (1, 'Zikir'), (2, 'Sabah')",
          )
          ..execute(
            'INSERT INTO counters (id, count, rounds, total, target) '
            'VALUES (1, 4, 0, 4, NULL), (2, 7, 2, 73, 33)',
          )
          ..execute('INSERT INTO dhikr_selections (id, dhikr_id) VALUES (1, 2)')
          ..userVersion = 3;
      },
    );
    final migrated = AppDatabase(v3);
    addTearDown(migrated.close);

    final list = _ok(await DriftDhikrListRepository(migrated).load());
    expect(list.entries.map((e) => e.name.value), ['Zikir', 'Sabah']);
    expect(list.selectedId, 2);
    expect(
      _ok(await DriftCounterRepository(migrated, dhikrId: 2).load()),
      CounterState(
        count: const DhikrCount(7),
        rounds: 2,
        total: 73,
        target: Target.of(33),
      ),
    );
    final settings = DriftSettingsRepository(migrated);
    expect(_ok(await settings.load()), AppSettings.defaults);
    const changed = AppSettings(vibration: false, theme: ThemeChoice.light);
    await settings.save(changed);
    expect(_ok(await settings.load()), changed);
  });

  test('the database refuses an unknown theme', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await expectLater(
      db.customStatement(
        "INSERT INTO settings (id, vibration, theme) VALUES (1, 1, 'sepia')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('a storage error becomes a StorageFailure', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final garbage = File('${dir.path}${Platform.pathSeparator}db.sqlite')
      ..writeAsBytesSync(List<int>.filled(4096, 0x5A));
    final broken = AppDatabase(NativeDatabase(garbage));
    addTearDown(broken.close);

    expect(
      await DriftSettingsRepository(broken).load(),
      isA<Err<AppSettings>>().having(
        (e) => e.failure,
        'failure',
        isA<StorageFailure>(),
      ),
    );
  });

  // Spec 0009, AC-6.
  test('tap vibration survives reopening', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    const saved = AppSettings(
      vibration: false,
      theme: ThemeChoice.light,
      tapVibration: true,
    );
    await DriftSettingsRepository(first).save(saved);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect(_ok(await DriftSettingsRepository(second).load()), saved);
  });

  // Spec 0009, AC-1: an update keeps the saved settings; the new one is off.
  test('migrates a v5 database and keeps the settings', () async {
    final v5 = NativeDatabase.memory(
      setup: (raw) {
        if (raw.userVersion != 0) return;
        raw
          ..execute(
            'CREATE TABLE counters (id INTEGER NOT NULL, '
            'count INTEGER NOT NULL CHECK (count >= 0), '
            'rounds INTEGER NOT NULL DEFAULT 0, total INTEGER NOT NULL DEFAULT 0, '
            'target INTEGER NULL, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE dhikrs (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
            'name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 50))',
          )
          ..execute(
            'CREATE TABLE dhikr_selections (id INTEGER NOT NULL CHECK (id = 1), '
            'dhikr_id INTEGER NULL, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE settings (id INTEGER NOT NULL CHECK (id = 1), '
            'vibration INTEGER NOT NULL, theme TEXT NOT NULL, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE tesbihat_progress (id INTEGER NOT NULL CHECK (id = 1), '
            'step INTEGER NOT NULL CHECK (step >= 0), '
            'count INTEGER NOT NULL CHECK (count >= 0), '
            'finished INTEGER NOT NULL, '
            'completions INTEGER NOT NULL CHECK (completions >= 0), '
            'selected INTEGER NOT NULL, PRIMARY KEY (id))',
          )
          ..execute("INSERT INTO dhikrs (id, name) VALUES (1, 'Zikir')")
          ..execute(
            'INSERT INTO counters (id, count, rounds, total, target) '
            'VALUES (1, 5, 1, 38, 33)',
          )
          ..execute('INSERT INTO dhikr_selections (id, dhikr_id) VALUES (1, 1)')
          ..execute(
            "INSERT INTO settings (id, vibration, theme) VALUES (1, 0, 'dark')",
          )
          ..userVersion = 5;
      },
    );
    final migrated = AppDatabase(v5);
    addTearDown(migrated.close);

    final settings = DriftSettingsRepository(migrated);
    expect(
      _ok(await settings.load()),
      const AppSettings(vibration: false, theme: ThemeChoice.dark),
    );
    expect(
      _ok(await DriftCounterRepository(migrated, dhikrId: 1).load()),
      CounterState(
        count: const DhikrCount(5),
        rounds: 1,
        total: 38,
        target: Target.of(33),
      ),
    );
    const changed = AppSettings(
      vibration: false,
      theme: ThemeChoice.dark,
      tapVibration: true,
    );
    await settings.save(changed);
    expect(_ok(await settings.load()), changed);
  });

  // Spec 0010, AC-8.
  test('keep screen on survives reopening', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    const saved = AppSettings(
      vibration: true,
      theme: ThemeChoice.dark,
      keepScreenOn: true,
    );
    await DriftSettingsRepository(first).save(saved);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect(_ok(await DriftSettingsRepository(second).load()), saved);
  });

  // Spec 0010, AC-8: an update keeps the saved settings; the new one is off.
  test('migrates a v6 database and keeps the settings', () async {
    final v6 = NativeDatabase.memory(
      setup: (raw) {
        if (raw.userVersion != 0) return;
        raw
          ..execute(
            'CREATE TABLE counters (id INTEGER NOT NULL, '
            'count INTEGER NOT NULL CHECK (count >= 0), '
            'rounds INTEGER NOT NULL DEFAULT 0, total INTEGER NOT NULL DEFAULT 0, '
            'target INTEGER NULL, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE dhikrs (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
            'name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 50))',
          )
          ..execute(
            'CREATE TABLE dhikr_selections (id INTEGER NOT NULL CHECK (id = 1), '
            'dhikr_id INTEGER NULL, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE settings (id INTEGER NOT NULL CHECK (id = 1), '
            'vibration INTEGER NOT NULL, theme TEXT NOT NULL, '
            'tap_vibration INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE tesbihat_progress (id INTEGER NOT NULL CHECK (id = 1), '
            'step INTEGER NOT NULL CHECK (step >= 0), '
            'count INTEGER NOT NULL CHECK (count >= 0), '
            'finished INTEGER NOT NULL, '
            'completions INTEGER NOT NULL CHECK (completions >= 0), '
            'selected INTEGER NOT NULL, PRIMARY KEY (id))',
          )
          ..execute("INSERT INTO dhikrs (id, name) VALUES (1, 'Zikir')")
          ..execute(
            'INSERT INTO counters (id, count, rounds, total, target) '
            'VALUES (1, 7, 2, 73, 33)',
          )
          ..execute('INSERT INTO dhikr_selections (id, dhikr_id) VALUES (1, 1)')
          ..execute(
            'INSERT INTO settings (id, vibration, theme, tap_vibration) '
            "VALUES (1, 0, 'light', 1)",
          )
          ..userVersion = 6;
      },
    );
    final migrated = AppDatabase(v6);
    addTearDown(migrated.close);

    final settings = DriftSettingsRepository(migrated);
    expect(
      _ok(await settings.load()),
      const AppSettings(
        vibration: false,
        theme: ThemeChoice.light,
        tapVibration: true,
      ),
    );
    expect(
      _ok(await DriftCounterRepository(migrated, dhikrId: 1).load()),
      CounterState(
        count: const DhikrCount(7),
        rounds: 2,
        total: 73,
        target: Target.of(33),
      ),
    );
    const changed = AppSettings(
      vibration: false,
      theme: ThemeChoice.light,
      tapVibration: true,
      keepScreenOn: true,
    );
    await settings.save(changed);
    expect(_ok(await settings.load()), changed);
  });

  // Spec 0011, AC-1.
  test('display options survive reopening', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    for (final hand in HandLayout.values) {
      final first = AppDatabase(NativeDatabase(file));
      final saved = AppSettings(
        vibration: true,
        theme: ThemeChoice.dark,
        largeCount: hand != HandLayout.center,
        handLayout: hand,
      );
      await DriftSettingsRepository(first).save(saved);
      await first.close();

      final second = AppDatabase(NativeDatabase(file));
      expect(_ok(await DriftSettingsRepository(second).load()), saved);
      await second.close();
    }
  });

  // Spec 0011, AC-1.
  test('the database refuses an unknown hand layout', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await expectLater(
      db.customStatement(
        'INSERT INTO settings (id, vibration, theme, hand_layout) '
        "VALUES (1, 1, 'light', 'both')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  // Spec 0011, AC-1: an update keeps the saved settings; the new ones are the
  // defaults.
  test('migrates a v7 database and keeps the settings', () async {
    final v7 = NativeDatabase.memory(
      setup: (raw) {
        if (raw.userVersion != 0) return;
        raw
          ..execute(
            'CREATE TABLE counters (id INTEGER NOT NULL, '
            'count INTEGER NOT NULL CHECK (count >= 0), '
            'rounds INTEGER NOT NULL DEFAULT 0, total INTEGER NOT NULL DEFAULT 0, '
            'target INTEGER NULL, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE dhikrs (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
            'name TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 50))',
          )
          ..execute(
            'CREATE TABLE dhikr_selections (id INTEGER NOT NULL CHECK (id = 1), '
            'dhikr_id INTEGER NULL, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE settings (id INTEGER NOT NULL CHECK (id = 1), '
            'vibration INTEGER NOT NULL, theme TEXT NOT NULL, '
            'tap_vibration INTEGER NOT NULL DEFAULT 0, '
            'keep_screen_on INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (id))',
          )
          ..execute(
            'CREATE TABLE tesbihat_progress (id INTEGER NOT NULL CHECK (id = 1), '
            'step INTEGER NOT NULL CHECK (step >= 0), '
            'count INTEGER NOT NULL CHECK (count >= 0), '
            'finished INTEGER NOT NULL, '
            'completions INTEGER NOT NULL CHECK (completions >= 0), '
            'selected INTEGER NOT NULL, PRIMARY KEY (id))',
          )
          ..execute("INSERT INTO dhikrs (id, name) VALUES (1, 'Zikir')")
          ..execute(
            'INSERT INTO counters (id, count, rounds, total, target) '
            'VALUES (1, 7, 2, 73, 33)',
          )
          ..execute('INSERT INTO dhikr_selections (id, dhikr_id) VALUES (1, 1)')
          ..execute(
            'INSERT INTO settings '
            '(id, vibration, theme, tap_vibration, keep_screen_on) '
            "VALUES (1, 0, 'light', 1, 1)",
          )
          ..userVersion = 7;
      },
    );
    final migrated = AppDatabase(v7);
    addTearDown(migrated.close);

    final settings = DriftSettingsRepository(migrated);
    expect(
      _ok(await settings.load()),
      const AppSettings(
        vibration: false,
        theme: ThemeChoice.light,
        tapVibration: true,
        keepScreenOn: true,
      ),
    );
    expect(
      _ok(await DriftCounterRepository(migrated, dhikrId: 1).load()),
      CounterState(
        count: const DhikrCount(7),
        rounds: 2,
        total: 73,
        target: Target.of(33),
      ),
    );
    const changed = AppSettings(
      vibration: false,
      theme: ThemeChoice.light,
      tapVibration: true,
      keepScreenOn: true,
      largeCount: true,
      handLayout: HandLayout.left,
    );
    await settings.save(changed);
    expect(_ok(await settings.load()), changed);
  });
}
