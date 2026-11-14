import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/core/hand_layout.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/data/drift_counter_repository.dart';
import 'package:zikirmatik/features/counter/domain/counter_state.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';
import 'package:zikirmatik/features/settings/data/drift_settings_repository.dart';
import 'package:zikirmatik/features/settings/domain/app_settings.dart';

// Spec 0017 — the continue notification setting, storage (AC-8; schema v10).

T _ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

File _tempDb() {
  final dir = Directory.systemTemp.createTempSync('zikirmatik_test_');
  addTearDown(() => dir.deleteSync(recursive: true));
  return File('${dir.path}${Platform.pathSeparator}db.sqlite');
}

void main() {
  // Several AppDatabase instances on purpose, each on its own executor.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('the continue notification survives reopening', () async {
    final file = _tempDb();
    final first = AppDatabase(NativeDatabase(file));
    const saved = AppSettings(
      vibration: true,
      theme: ThemeChoice.system,
      continueNotification: true,
    );
    expect(await DriftSettingsRepository(first).save(saved), isA<Ok<void>>());
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect(_ok(await DriftSettingsRepository(second).load()), saved);
  });

  test('migrates a v9 database and keeps the settings', () async {
    // A database as spec 0016 left it: v10 without the column is v9.
    final file = _tempDb();
    final v9 = AppDatabase(NativeDatabase(file));
    const kept = AppSettings(
      vibration: false,
      theme: ThemeChoice.dark,
      tapVibration: true,
      keepScreenOn: true,
      largeCount: true,
      handLayout: HandLayout.left,
    );
    await DriftSettingsRepository(v9).save(kept);
    const counted = CounterState(count: DhikrCount(7), rounds: 2, total: 73);
    await DriftCounterRepository(v9, dhikrId: 1).save(counted);
    await v9.customStatement(
      'ALTER TABLE settings DROP COLUMN continue_notification',
    );
    await v9.customStatement('PRAGMA user_version = 9');
    await v9.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final settings = DriftSettingsRepository(migrated);
    // Off for kept settings (G3); everything else as it was.
    expect(_ok(await settings.load()), kept);
    expect(
      _ok(await DriftCounterRepository(migrated, dhikrId: 1).load()),
      counted,
    );

    final on = kept.copyWith(continueNotification: true);
    await settings.save(on);
    expect(_ok(await settings.load()), on);
  });
}
