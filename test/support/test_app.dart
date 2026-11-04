import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/app/composition.dart';
import 'package:zikirmatik/core/haptics.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/settings/settings.dart';

/// The app under test in its deterministic mode (docs/testing.md, Determinism):
/// animations off, Turkish locale (fixed in the app), vibration by [haptics].
/// Never touches the network or the device database.
///
/// Storage: [store] when given (several dhikrs, spec 0003); otherwise a single
/// dhikr "Zikir" (id 1) whose counter is [repo] — the setup of specs 0001/0002.
/// Settings: [settings] when given (spec 0004); otherwise the defaults. The
/// cross-feature wiring is the app's own (`featureWiring`).
Widget testApp(
  WidgetTester tester, {
  CounterRepository? repo,
  FakeDhikrStore? store,
  FakeHaptics? haptics,
  FakeSettingsRepository? settings,
}) {
  final dhikrs =
      store ?? FakeDhikrStore.single(repo ?? FakeCounterRepository());
  return ProviderScope(
    overrides: [
      counterRepositoryForProvider.overrideWithValue(dhikrs.counterFor),
      dhikrListRepositoryProvider.overrideWithValue(dhikrs),
      settingsRepositoryProvider.overrideWithValue(
        settings ?? FakeSettingsRepository(),
      ),
      hapticsProvider.overrideWithValue(haptics ?? FakeHaptics()),
      ...featureWiring(),
    ],
    // Live view metrics (spec 0004: the phone's light/dark setting can change
    // while the app runs), with animations off on top.
    child: MediaQuery.fromView(
      view: tester.view,
      child: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: const ZikirmatikApp(),
        ),
      ),
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

/// In-memory [SettingsRepository] (spec 0004) whose load can be held open or
/// made to fail. Survives a "restart" when the same instance is reused.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    this.stored = AppSettings.defaults,
    this.failLoad = false,
  });

  AppSettings stored;
  final bool failLoad;

  /// When set, [load] waits for it, so the loading state stays visible.
  Completer<void>? holdLoad;

  final List<AppSettings> saves = [];

  @override
  Future<Result<AppSettings>> load() async {
    await holdLoad?.future;
    if (failLoad) {
      return const Err(StorageFailure('settings unreadable'));
    }
    return Ok(stored);
  }

  @override
  Future<Result<void>> save(AppSettings settings) async {
    saves.add(settings);
    stored = settings;
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

/// In-memory dhikr list plus one [FakeCounterRepository] per dhikr (spec 0003).
/// Survives a "restart" (a new ProviderScope) when the same instance is reused.
class FakeDhikrStore implements DhikrListRepository {
  FakeDhikrStore(List<(String, CounterState)> dhikrs, {int? selectedId}) {
    for (final (name, state) in dhikrs) {
      final id = _nextId++;
      entries.add(DhikrEntry(id, DhikrName.stored(name)));
      counters[id] = FakeCounterRepository(state: state);
    }
    this.selectedId = selectedId ?? (entries.isEmpty ? null : entries.first.id);
  }

  /// One dhikr "Zikir" (id 1) whose counter is [repo].
  FakeDhikrStore.single(CounterRepository repo) {
    entries.add(DhikrEntry(_nextId++, DhikrName.first));
    counters[1] = repo;
    selectedId = 1;
  }

  final List<DhikrEntry> entries = [];
  final Map<int, CounterRepository> counters = {};
  int? selectedId;
  int _nextId = 1;

  CounterRepository counterFor(int id) =>
      counters[id] ?? (throw StateError('no counter for dhikr $id'));

  /// The stored counter state of a fake counter.
  CounterState stateOf(int id) =>
      (counters[id]! as FakeCounterRepository).stored;

  @override
  Future<Result<DhikrList>> load() async =>
      Ok(DhikrList(List.of(entries), selectedId: selectedId));

  @override
  Future<Result<DhikrEntry>> add(DhikrName name, Target? target) async {
    final entry = DhikrEntry(_nextId++, name);
    entries.add(entry);
    counters[entry.id] = FakeCounterRepository(
      state: CounterState(count: DhikrCount.zero, target: target),
    );
    selectedId = entry.id;
    return Ok(entry);
  }

  @override
  Future<Result<void>> rename(int id, DhikrName name) async {
    final i = entries.indexWhere((e) => e.id == id);
    entries[i] = DhikrEntry(id, name);
    return const Ok(null);
  }

  @override
  Future<Result<void>> delete(int id) async {
    entries.removeWhere((e) => e.id == id);
    counters.remove(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> select(int? id) async {
    selectedId = id;
    return const Ok(null);
  }
}
