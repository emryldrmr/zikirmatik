import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/data/drift_counter_repository.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';

DhikrCount _loaded(Result<DhikrCount> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

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
    expect(_loaded(await repo.load()), DhikrCount.zero);
  });

  test('save then load returns the saved count', () async {
    expect(await repo.save(const DhikrCount(7)), isA<Ok<void>>());
    expect(_loaded(await repo.load()), const DhikrCount(7));
  });

  test('a later save replaces the earlier one', () async {
    await repo.save(const DhikrCount(1));
    await repo.save(const DhikrCount(2));
    expect(_loaded(await repo.load()), const DhikrCount(2));
  });

  test('count survives reopening the database', () async {
    final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    await DriftCounterRepository(first).save(const DhikrCount(3));
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    final loaded = await DriftCounterRepository(second).load();
    expect(_loaded(loaded), const DhikrCount(3));
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
      isA<Err<DhikrCount>>().having(
        (e) => e.failure,
        'failure',
        isA<StorageFailure>(),
      ),
    );
    expect(await brokenRepo.save(DhikrCount.zero), isA<Err<void>>());
  });

  test('the database refuses a negative count', () async {
    await expectLater(
      db.customStatement('INSERT INTO counters (id, count) VALUES (2, -1)'),
      throwsA(isA<SqliteException>()),
    );
  });
}
