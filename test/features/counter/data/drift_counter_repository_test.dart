import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/data/drift_counter_repository.dart';
import 'package:zikirmatik/features/counter/domain/counter_state.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';
import 'package:zikirmatik/features/counter/domain/target.dart';

CounterState _loaded(Result<CounterState> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

CounterState _withCount(int n) =>
    CounterState(count: DhikrCount(n), total: n);

void main() {
  // These tests open several AppDatabase instances on purpose, each on its own
  // executor (memory, temp file, broken file); drift's shared-executor warning
  // does not apply.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Each test owns its database (docs/testing.md, Resource hygiene rule 5).
  late AppDatabase db;
  late DriftCounterRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftCounterRepository(db);
  });

  tearDown(() => db.close());

  test('load returns zero when nothing is stored', () async {
    expect(_loaded(await repo.load()).count, DhikrCount.zero);
  });

  test('save then load returns the saved count', () async {
    expect(await repo.save(_withCount(7)), isA<Ok<void>>());
    expect(_loaded(await repo.load()).count, const DhikrCount(7));
  });

  test('a later save replaces the earlier one', () async {
    await repo.save(_withCount(1));
    await repo.save(_withCount(2));
    expect(_loaded(await repo.load()).count, const DhikrCount(2));
  });

  test('count survives reopening the database', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    await DriftCounterRepository(first).save(_withCount(3));
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    final loaded = await DriftCounterRepository(second).load();
    expect(_loaded(loaded).count, const DhikrCount(3));
  });

  test('a storage error becomes a StorageFailure, not an exception', () async {
    // A file that is not a SQLite database cannot be read.
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final garbage = File('${dir.path}${Platform.pathSeparator}db.sqlite')
      ..writeAsBytesSync(List<int>.filled(4096, 0x5A));
    final broken = AppDatabase(NativeDatabase(garbage));
    addTearDown(broken.close);
    final brokenRepo = DriftCounterRepository(broken);

    expect(
      await brokenRepo.load(),
      isA<Err<CounterState>>().having(
        (e) => e.failure,
        'failure',
        isA<StorageFailure>(),
      ),
    );
    expect(await brokenRepo.save(CounterState.initial), isA<Err<void>>());
  });

  test('the database refuses a negative count', () async {
    await expectLater(
      db.customStatement('INSERT INTO counters (id, count) VALUES (2, -1)'),
      throwsA(isA<SqliteException>()),
    );
  });

  // --- spec 0002 ---

  test('load returns the initial state when nothing is stored', () async {
    expect(_loaded(await repo.load()), CounterState.initial);
  });

  test('state survives reopening the database', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');
    final state = CounterState(
      count: const DhikrCount(12),
      rounds: 4,
      total: 1250,
      target: Target.of(33),
    );

    final first = AppDatabase(NativeDatabase(file));
    expect(await DriftCounterRepository(first).save(state), isA<Ok<void>>());
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect(_loaded(await DriftCounterRepository(second).load()), state);
  });

  test('a cleared target is stored as no target', () async {
    await repo.save(CounterState(count: DhikrCount.zero, target: Target.of(99)));
    await repo.save(const CounterState(count: DhikrCount.zero, total: 3));
    expect(_loaded(await repo.load()).target, isNull);
  });

  test('migrates a v1 count to count and total', () async {
    // A database exactly as spec 0001 left it: schema v1 holding count 57.
    final v1 = NativeDatabase.memory(
      setup: (raw) {
        if (raw.userVersion != 0) return;
        raw
          ..execute(
            'CREATE TABLE counters (id INTEGER NOT NULL, '
            'count INTEGER NOT NULL CHECK (count >= 0), PRIMARY KEY (id))',
          )
          ..execute('INSERT INTO counters (id, count) VALUES (1, 57)')
          ..userVersion = 1;
      },
    );
    final migrated = AppDatabase(v1);
    addTearDown(migrated.close);

    expect(
      _loaded(await DriftCounterRepository(migrated).load()),
      const CounterState(count: DhikrCount(57), total: 57),
    );
  });

  test('the database refuses an out-of-range target', () async {
    for (final bad in [0, 100001]) {
      await expectLater(
        db.customStatement(
          'INSERT INTO counters (id, count, target) VALUES (3, 0, $bad)',
        ),
        throwsA(isA<SqliteException>()),
        reason: 'target $bad',
      );
    }
  });
}
