import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/data/drift_counter_repository.dart';
import 'package:zikirmatik/features/counter/data/drift_dhikr_list_repository.dart';
import 'package:zikirmatik/features/counter/domain/counter_state.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_list.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_name.dart';
import 'package:zikirmatik/features/counter/domain/target.dart';

T _ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

DhikrName _n(String s) => DhikrName.stored(s);

void main() {
  // Several AppDatabase instances on purpose, each on its own executor.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late DriftDhikrListRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftDhikrListRepository(db);
  });

  tearDown(() => db.close());

  Future<CounterState> counterOf(AppDatabase d, int id) async =>
      _ok(await DriftCounterRepository(d, dhikrId: id).load());

  test('a new database starts with one dhikr named Zikir', () async {
    final list = _ok(await repo.load());
    expect(list.entries, [DhikrEntry(1, _n('Zikir'))]);
    expect(list.selectedId, 1);
    expect(await counterOf(db, 1), CounterState.initial);
  });

  test('migrates a v2 counter into the first dhikr', () async {
    // A database exactly as spec 0002 left it: schema v2, one counter row.
    final v2 = NativeDatabase.memory(
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
            'INSERT INTO counters (id, count, rounds, total, target) '
            'VALUES (1, 7, 2, 73, 33)',
          )
          ..userVersion = 2;
      },
    );
    final migrated = AppDatabase(v2);
    addTearDown(migrated.close);

    final list = _ok(await DriftDhikrListRepository(migrated).load());
    expect(list.entries, [DhikrEntry(1, _n('Zikir'))]);
    expect(list.selectedId, 1);
    expect(
      await counterOf(migrated, 1),
      CounterState(
        count: const DhikrCount(7),
        rounds: 2,
        total: 73,
        target: Target.of(33),
      ),
    );
  });

  test('add appends, selects and starts from zero with the target', () async {
    final added = _ok(await repo.add(_n('Sabah'), Target.of(33)));
    expect(added.id, greaterThan(1));

    final list = _ok(await repo.load());
    expect(list.entries.map((e) => e.name.value), ['Zikir', 'Sabah']);
    expect(list.selectedId, added.id);
    expect(
      await counterOf(db, added.id),
      CounterState(count: DhikrCount.zero, target: Target.of(33)),
    );
  });

  test('rename changes only the name', () async {
    await DriftCounterRepository(
      db,
    ).save(const CounterState(count: DhikrCount(4), total: 9));
    expect(await repo.rename(1, _n('Akşam')), isA<Ok<void>>());

    expect(_ok(await repo.load()).entries, [DhikrEntry(1, _n('Akşam'))]);
    expect(
      await counterOf(db, 1),
      const CounterState(count: DhikrCount(4), total: 9),
    );
  });

  test('delete removes the dhikr and its counter', () async {
    final added = _ok(await repo.add(_n('Sabah'), null));
    expect(await repo.delete(added.id), isA<Ok<void>>());

    expect(_ok(await repo.load()).entries.map((e) => e.id), [1]);
    final left = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM counters WHERE id = ${added.id}',
        )
        .getSingle();
    expect(left.read<int>('n'), 0);
  });

  test('deleting every dhikr leaves an empty list', () async {
    await repo.delete(1);
    await repo.select(null);
    final list = _ok(await repo.load());
    expect(list.isEmpty, isTrue);
    expect(list.selectedId, isNull);
  });

  test('a later dhikr never reuses a deleted id', () async {
    final a = _ok(await repo.add(_n('A'), null));
    await repo.delete(a.id);
    final b = _ok(await repo.add(_n('B'), null));
    expect(b.id, greaterThan(a.id));
  });

  test('list, values and selection survive reopening', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    final firstRepo = DriftDhikrListRepository(first);
    final sabah = _ok(await firstRepo.add(_n('Sabah'), Target.of(99)));
    await DriftCounterRepository(first, dhikrId: sabah.id).save(
      CounterState(
        count: const DhikrCount(5),
        rounds: 1,
        total: 104,
        target: Target.of(99),
      ),
    );
    await firstRepo.select(1);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    final list = _ok(await DriftDhikrListRepository(second).load());
    expect(list.entries, [DhikrEntry(1, _n('Zikir')), sabah]);
    expect(list.selectedId, 1);
    expect(
      await counterOf(second, sabah.id),
      CounterState(
        count: const DhikrCount(5),
        rounds: 1,
        total: 104,
        target: Target.of(99),
      ),
    );
  });

  test('the database refuses an empty or 51-character name', () async {
    for (final bad in ['', 'x' * 51]) {
      await expectLater(
        db.customStatement('INSERT INTO dhikrs (name) VALUES (?)', [bad]),
        throwsA(isA<SqliteException>()),
        reason: 'name of length ${bad.length}',
      );
    }
  });

  test('a storage error becomes a StorageFailure', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final garbage = File('${dir.path}${Platform.pathSeparator}db.sqlite')
      ..writeAsBytesSync(List<int>.filled(4096, 0x5A));
    final broken = AppDatabase(NativeDatabase(garbage));
    addTearDown(broken.close);

    expect(
      await DriftDhikrListRepository(broken).load(),
      isA<Err<DhikrList>>().having(
        (e) => e.failure,
        'failure',
        isA<StorageFailure>(),
      ),
    );
  });
}
