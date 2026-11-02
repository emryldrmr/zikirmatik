import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/haptics.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/counter.dart';

/// The app under test in its deterministic mode (docs/testing.md, Determinism):
/// animations off, Turkish locale (fixed in the app), storage replaced by [repo],
/// vibration by [haptics]. Never touches the network or the device database.
Widget testApp(
  WidgetTester tester, {
  required CounterRepository repo,
  FakeHaptics? haptics,
}) {
  return ProviderScope(
    overrides: [
      counterRepositoryProvider.overrideWithValue(repo),
      hapticsProvider.overrideWithValue(haptics ?? FakeHaptics()),
    ],
    child: MediaQuery(
      data: MediaQueryData.fromView(
        tester.view,
      ).copyWith(disableAnimations: true),
      child: const ZikirmatikApp(),
    ),
  );
}

/// In-memory [CounterRepository] whose load can be held open or made to fail.
///
/// [stored] is a shortcut for a state holding that count (and that total);
/// [state] sets the whole state.
class FakeCounterRepository implements CounterRepository {
  FakeCounterRepository({
    int stored = 0,
    CounterState? state,
    this.failLoad = false,
  }) : stored = state ?? CounterState(count: DhikrCount(stored), total: stored);

  CounterState stored;
  final bool failLoad;

  /// When set, [load] waits for it, so the loading state stays visible.
  Completer<void>? holdLoad;

  /// When set, each [save] stays in flight until it completes (a slow disk).
  Completer<void>? holdSave;

  final List<CounterState> saves = [];

  @override
  Future<Result<CounterState>> load() async {
    await holdLoad?.future;
    if (failLoad) {
      return const Err(StorageFailure('disk on fire: /data/zikirmatik.db'));
    }
    return Ok(stored);
  }

  @override
  Future<Result<void>> save(CounterState state) async {
    saves.add(state);
    stored = state;
    await holdSave?.future;
    return const Ok(null);
  }
}

/// Counts vibrations instead of calling the platform.
class FakeHaptics implements Haptics {
  int roundsCompleted = 0;

  /// When set, each vibration waits for it (a slow platform channel).
  Completer<void>? hold;

  /// When true, each vibration fails after being counted.
  bool fail = false;

  @override
  Future<void> roundCompleted() async {
    roundsCompleted++;
    await hold?.future;
    if (fail) throw StateError('vibrator unavailable');
  }
}
