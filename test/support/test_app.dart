import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/counter.dart';

/// The app under test in its deterministic mode (docs/testing.md, Determinism):
/// animations off, Turkish locale (fixed in the app), storage replaced by [repo].
/// Never touches the network or the device database.
Widget testApp(WidgetTester tester, {required CounterRepository repo}) {
  return ProviderScope(
    overrides: [counterRepositoryProvider.overrideWithValue(repo)],
    child: MediaQuery(
      data: MediaQueryData.fromView(
        tester.view,
      ).copyWith(disableAnimations: true),
      child: const ZikirmatikApp(),
    ),
  );
}

/// In-memory [CounterRepository] whose load can be held open or made to fail.
class FakeCounterRepository implements CounterRepository {
  FakeCounterRepository({int stored = 0, this.failLoad = false})
    : stored = DhikrCount(stored);

  DhikrCount stored;
  final bool failLoad;

  /// When set, [load] waits for it, so the loading state stays visible.
  Completer<void>? holdLoad;

  final List<DhikrCount> saves = [];

  @override
  Future<Result<DhikrCount>> load() async {
    await holdLoad?.future;
    if (failLoad) {
      return const Err(StorageFailure('disk on fire: /data/zikirmatik.db'));
    }
    return Ok(stored);
  }

  @override
  Future<Result<void>> save(DhikrCount count) async {
    saves.add(count);
    stored = count;
    return const Ok(null);
  }
}
