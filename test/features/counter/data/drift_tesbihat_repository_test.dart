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
import 'package:zikirmatik/features/counter/domain/target.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat_state.dart';
import 'package:zikirmatik/features/settings/data/drift_settings_repository.dart';
import 'package:zikirmatik/features/settings/domain/app_settings.dart';

// Spec 0006 — Namaz sonrası tesbihat, storage (AC-7).

T _ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

void main() {
  // Several AppDatabase instances on purpose, each on its own executor.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'a new database has the tesbihat not started and not selected',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(
        _ok(await DriftTesbihatRepository(db).load()),
        TesbihatState.initial,
      );
    },
  );

  test('progress and selection survive reopening', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    const midway = TesbihatState(
      step: 1,
      count: DhikrCount(12),
      completions: 3,
      selected: true,
    );
    final first = AppDatabase(NativeDatabase(file));
    expect(await DriftTesbihatRepository(first).save(midway), isA<Ok<void>>());
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    final repo = DriftTesbihatRepository(second);
    expect(_ok(await repo.load()), midway);

    const finished = TesbihatState(step: 2, finished: true, completions: 4);
    await repo.save(finished);
    expect(_ok(await repo.load()), finished);
  });

  test('a stored row that does not fit the steps starts again', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customStatement(
      'INSERT INTO tesbihat_progress '
      '(id, step, count, finished, completions, selected) '
      'VALUES (1, 1, 33, 0, 2, 1)',
    );

    expect(
      _ok(await DriftTesbihatRepository(db).load()),
      const TesbihatState(completions: 2, selected: true),
    );
  });

  test('migrates a v4 database and keeps dhikrs and settings', () async {
    // A database as spec 0004 left it: schema v4, two dhikrs, the second
    // selected, saved settings.
    final v4 = NativeDatabase.memory(
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
            "INSERT INTO dhikrs (id, name) VALUES (1, 'Zikir'), (2, 'Sabah')",
          )
          ..execute(
            'INSERT INTO counters (id, count, rounds, total, target) '
            'VALUES (1, 4, 0, 4, NULL), (2, 7, 2, 73, 33)',
          )
          ..execute('INSERT INTO dhikr_selections (id, dhikr_id) VALUES (1, 2)')
          ..execute(
            "INSERT INTO settings (id, vibration, theme) VALUES (1, 0, 'dark')",
          )
          ..userVersion = 4;
      },
    );
    final migrated = AppDatabase(v4);
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
    expect(
      _ok(await DriftSettingsRepository(migrated).load()),
      const AppSettings(vibration: false, theme: ThemeChoice.dark),
    );
    final tesbihat = DriftTesbihatRepository(migrated);
    expect(_ok(await tesbihat.load()), TesbihatState.initial);
    const saved = TesbihatState(step: 2, count: DhikrCount(5));
    await tesbihat.save(saved);
    expect(_ok(await tesbihat.load()), saved);
  });
}
