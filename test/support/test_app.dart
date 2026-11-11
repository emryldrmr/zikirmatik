import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/app/composition.dart';
import 'package:zikirmatik/core/app_version.dart';
import 'package:zikirmatik/core/clock.dart';
import 'package:zikirmatik/core/haptics.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/core/screen.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/esma/esma.dart';
import 'package:zikirmatik/features/history/history.dart';
import 'package:zikirmatik/features/settings/settings.dart';
import 'package:zikirmatik/features/suggested/suggested.dart';

/// The app under test in its deterministic mode (docs/testing.md, Determinism):
/// animations off, Turkish locale (fixed in the app), vibration by [haptics].
/// Never touches the network or the device database.
///
/// Storage: [store] when given (several dhikrs, spec 0003); otherwise a single
/// dhikr "Zikir" (id 1) whose counter is [repo] — the setup of specs 0001/0002.
/// Settings: [settings] when given (spec 0004); otherwise the defaults.
/// Tesbihat: [tesbihat] when given (spec 0006); otherwise not started.
/// Version: [version] when given (spec 0009); otherwise none is shown.
/// Screen and system bars: [screenAwake] and [systemBars] record what the app
/// asks of the phone (spec 0010). History: [history] when given (spec 0014);
/// otherwise empty. Time: [clock] when given; otherwise fixed at noon on
/// 8 November 2026. The cross-feature wiring is the app's own
/// (`featureWiring`).
Widget testApp(
  WidgetTester tester, {
  CounterRepository? repo,
  FakeDhikrStore? store,
  FakeHaptics? haptics,
  FakeSettingsRepository? settings,
  FakeTesbihatRepository? tesbihat,
  String? version,
  FakeScreenAwake? screenAwake,
  FakeSystemBars? systemBars,
  FakeHistoryRepository? history,
  FakeClock? clock,
}) {
  final time = clock ?? FakeClock();
  final dhikrs =
      store ?? FakeDhikrStore.single(repo ?? FakeCounterRepository());
  return ProviderScope(
    overrides: [
      counterRepositoryForProvider.overrideWithValue(dhikrs.counterFor),
      dhikrListRepositoryProvider.overrideWithValue(dhikrs),
      settingsRepositoryProvider.overrideWithValue(
        settings ?? FakeSettingsRepository(),
      ),
      tesbihatRepositoryProvider.overrideWithValue(
        tesbihat ?? FakeTesbihatRepository(),
      ),
      // Spec 0007: the real bundled content (plan 0007, A-1).
      esmaRepositoryProvider.overrideWithValue(AssetEsmaRepository(rootBundle)),
      // Spec 0008: the real bundled content (as plan 0007, A-1).
      suggestedRepositoryProvider.overrideWithValue(
        AssetSuggestedRepository(rootBundle),
      ),
      hapticsProvider.overrideWithValue(haptics ?? FakeHaptics()),
      // Spec 0010.
      screenAwakeProvider.overrideWithValue(screenAwake ?? FakeScreenAwake()),
      systemBarsProvider.overrideWithValue(systemBars ?? FakeSystemBars()),
      // Spec 0009: no version unless given (as when it is unreadable).
      if (version != null) appVersionProvider.overrideWith((ref) => version),
      // Spec 0014.
      historyRepositoryProvider.overrideWithValue(
        history ?? FakeHistoryRepository(),
      ),
      clockProvider.overrideWithValue(() => time.now),
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

  /// When true, every save fails without changing [stored] (spec 0015).
  bool failWrites = false;

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
    if (failWrites) return const Err(StorageFailure('disk full'));
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

  /// When true, every save fails without changing [stored] (spec 0015).
  bool failWrites = false;

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
    if (failWrites) return const Err(StorageFailure('disk full'));
    saves.add(settings);
    stored = settings;
    return const Ok(null);
  }
}

/// In-memory [TesbihatRepository] (spec 0006); not started and not selected
/// unless [stored] says otherwise; its load can fail (spec 0015). Survives a
/// "restart" when the same instance is reused.
class FakeTesbihatRepository implements TesbihatRepository {
  FakeTesbihatRepository({
    this.stored = TesbihatState.initial,
    this.failLoad = false,
  });

  TesbihatState stored;
  final bool failLoad;

  final List<TesbihatState> saves = [];

  /// When true, every save fails without changing [stored] (spec 0015).
  bool failWrites = false;

  @override
  Future<Result<TesbihatState>> load() async =>
      failLoad ? const Err(StorageFailure('tesbihat unreadable')) : Ok(stored);

  @override
  Future<Result<void>> save(TesbihatState state) async {
    if (failWrites) return const Err(StorageFailure('disk full'));
    saves.add(state);
    stored = state;
    return const Ok(null);
  }
}

/// A clock the test sets (spec 0014: 23:59 → 00:00, month and year ends).
class FakeClock {
  FakeClock([DateTime? now]) : now = now ?? DateTime(2026, 11, 8, 12);

  DateTime now;
}

/// In-memory [HistoryRepository] (spec 0014) whose load can be held open or
/// made to fail and whose writes can fail. Survives a "restart" when the same
/// instance is reused.
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository({Map<Day, int>? stored, this.failLoad = false})
    : stored = {...?stored};

  final Map<Day, int> stored;
  final bool failLoad;

  /// When true, every write fails without changing [stored].
  bool failWrites = false;

  /// When set, [load] waits for it, so the loading state stays visible.
  Completer<void>? holdLoad;

  @override
  Future<Result<DailyHistory>> load() async {
    // Read when asked, as storage runs statements in order: writes issued
    // after the load are not in it (plan 0014, R2).
    final snapshot = DailyHistory(stored);
    await holdLoad?.future;
    if (failLoad) return const Err(StorageFailure('history unreadable'));
    return Ok(snapshot);
  }

  @override
  Future<Result<void>> add(Day day) async {
    if (failWrites) return const Err(StorageFailure('disk full'));
    stored[day] = (stored[day] ?? 0) + 1;
    return const Ok(null);
  }

  @override
  Future<Result<void>> remove(Day day) async {
    if (failWrites) return const Err(StorageFailure('disk full'));
    final n = stored[day] ?? 0;
    if (n > 0) stored[day] = n - 1;
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

  /// Short vibrations, one per counted tap (spec 0009).
  int taps = 0;

  @override
  Future<void> roundCompleted() async {
    roundsCompleted++;
    await hold?.future;
    if (fail) throw StateError('vibrator unavailable');
  }

  @override
  Future<void> tap() async {
    taps++;
    await hold?.future;
    if (fail) throw StateError('vibrator unavailable');
  }
}

/// Records keep-screen-on requests instead of calling the platform
/// (spec 0010).
class FakeScreenAwake implements ScreenAwake {
  /// Every request, in order.
  final List<bool> calls = [];

  /// Whether the screen is being kept on now (the last request).
  bool get on => calls.isNotEmpty && calls.last;

  @override
  Future<void> set({required bool on}) async => calls.add(on);
}

/// Records whether the system bars are hidden (spec 0010).
class FakeSystemBars implements SystemBars {
  bool hidden = false;

  /// Every hide request, so a re-hide on resume can be seen.
  int hides = 0;

  @override
  Future<void> hide() async {
    hides++;
    hidden = true;
  }

  @override
  Future<void> show() async => hidden = false;
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

  /// When true, list writes (add, rename, delete, select) fail without
  /// changing the store (spec 0015). Read when a write starts, so a write
  /// issued while it is true fails even if it is turned off before the write
  /// is let through by [holdWrites].
  bool failWrites = false;

  /// When set, each list write stays in flight until it completes, so other
  /// changes can happen in between (spec 0015, G2).
  Completer<void>? holdWrites;

  Future<Result<T>> _write<T>(T Function() apply) async {
    final fail = failWrites;
    final hold = holdWrites;
    if (hold != null) await hold.future;
    if (fail) return const Err(StorageFailure('disk full'));
    return Ok(apply());
  }

  CounterRepository counterFor(int id) =>
      counters[id] ?? (throw StateError('no counter for dhikr $id'));

  /// The stored counter state of a fake counter.
  CounterState stateOf(int id) =>
      (counters[id]! as FakeCounterRepository).stored;

  @override
  Future<Result<DhikrList>> load() async =>
      Ok(DhikrList(List.of(entries), selectedId: selectedId));

  @override
  Future<Result<DhikrEntry>> add(
    DhikrName name,
    Target? target, {
    bool select = true,
  }) => _write(() {
    final entry = DhikrEntry(_nextId++, name);
    entries.add(entry);
    counters[entry.id] = FakeCounterRepository(
      state: CounterState(count: DhikrCount.zero, target: target),
    );
    if (select) selectedId = entry.id;
    return entry;
  });

  @override
  Future<Result<void>> rename(int id, DhikrName name) => _write(() {
    final i = entries.indexWhere((e) => e.id == id);
    entries[i] = DhikrEntry(id, name);
  });

  @override
  Future<Result<void>> delete(int id) => _write(() {
    entries.removeWhere((e) => e.id == id);
    counters.remove(id);
  });

  @override
  Future<Result<void>> select(int? id) => _write(() {
    selectedId = id;
  });
}
