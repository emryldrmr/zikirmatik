import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/ui/counter_controller.dart';
import 'package:zikirmatik/features/counter/ui/tesbihat_controller.dart';
import 'package:zikirmatik/features/history/history.dart';

import '../../../support/test_app.dart';

// Spec 0014 — Günlük geçmiş ve seri, counting (AC-1…AC-4, G5).

final _button = find.byKey(const Key('counter-tap-area'));
final _undo = find.byKey(const Key('counter-undo'));
final _tesbihatUndo = find.byKey(const Key('tesbihat-undo'));

final _today = Day(2026, 11, 8);

CounterState _state({int count = 0, int total = 0, int? target}) =>
    CounterState(
      count: DhikrCount(count),
      total: total,
      target: target == null ? null : Target.of(target),
    );

Future<void> _start(
  WidgetTester tester, {
  FakeDhikrStore? store,
  FakeTesbihatRepository? tesbihat,
  FakeHistoryRepository? history,
  FakeClock? clock,
}) async {
  await tester.pumpWidget(
    testApp(
      tester,
      store: store,
      tesbihat: tesbihat,
      history: history,
      clock: clock,
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f, [int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(f);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ZikirmatikApp)));

Future<DailyHistory> _shown(WidgetTester tester) =>
    _container(tester).read(historyControllerProvider.future);

void main() {
  testWidgets('every counting tap adds one to today', (tester) async {
    final history = FakeHistoryRepository(stored: {_today.previous: 4});
    final store = FakeDhikrStore([('Zikir', _state(target: 3))]);
    await _start(tester, store: store, history: history);

    await _tap(tester, _button, 7); // two rounds completed on the way

    expect(history.stored[_today], 7);
    expect(history.stored[_today.previous], 4);
    expect((await _shown(tester)).countOn(_today), 7);
    expect(store.stateOf(1).total, 7); // the counter itself is unchanged
  });

  testWidgets('tesbihat taps add one to today', (tester) async {
    final history = FakeHistoryRepository();
    final tesbihat = FakeTesbihatRepository(
      stored: const TesbihatState(selected: true),
    );
    await _start(tester, tesbihat: tesbihat, history: history);

    await _tap(tester, _button, 35); // across the first step boundary

    expect(history.stored[_today], 35);
  });

  testWidgets('a finished tesbihat tap adds nothing', (tester) async {
    final history = FakeHistoryRepository();
    final tesbihat = FakeTesbihatRepository(
      stored: const TesbihatState(step: 2, finished: true, selected: true),
    );
    await _start(tester, tesbihat: tesbihat, history: history);

    await _tap(tester, _button, 3);

    expect(history.stored[_today], isNull);
    expect((await _shown(tester)).countOn(_today), 0);
  });

  testWidgets('undo takes one from today and never below zero', (tester) async {
    final history = FakeHistoryRepository(stored: {_today.previous: 4});
    final store = FakeDhikrStore([('Zikir', _state(count: 5, total: 5))]);
    await _start(tester, store: store, history: history);

    await _tap(tester, _button, 2);
    await _tap(tester, _undo, 3); // today: 2 → 0, the third stays at 0

    expect(history.stored[_today], 0);
    expect((await _shown(tester)).countOn(_today), 0);
    expect(history.stored[_today.previous], 4);
    expect(store.stateOf(1).count.value, 4); // the counter took back 3
  });

  testWidgets('undo on the tesbihat takes one from today', (tester) async {
    final history = FakeHistoryRepository();
    final tesbihat = FakeTesbihatRepository(
      stored: const TesbihatState(selected: true),
    );
    await _start(tester, tesbihat: tesbihat, history: history);

    await _tap(tester, _button, 3);
    await _tap(tester, _tesbihatUndo);

    expect(history.stored[_today], 2);
  });

  testWidgets('undo after midnight keeps yesterday', (tester) async {
    final clock = FakeClock(DateTime(2026, 11, 7, 23, 59));
    final history = FakeHistoryRepository();
    final store = FakeDhikrStore([('Zikir', _state())]);
    await _start(tester, store: store, history: history, clock: clock);

    await _tap(tester, _button);
    clock.now = DateTime(2026, 11, 8, 0, 0, 30);
    await _tap(tester, _undo);

    expect(store.stateOf(1).count.value, 0); // the dhikr took it back
    expect(history.stored[_today.previous], 1); // yesterday is unchanged
    expect(history.stored[_today] ?? 0, 0);
    expect((await _shown(tester)).countOn(_today.previous), 1);
  });

  testWidgets('23:59 and 00:00 go to different days', (tester) async {
    final clock = FakeClock(DateTime(2026, 12, 31, 23, 59, 59));
    final history = FakeHistoryRepository();
    await _start(tester, history: history, clock: clock);

    await _tap(tester, _button, 2);
    clock.now = DateTime(2027);
    await _tap(tester, _button, 3);

    expect(history.stored[Day(2026, 12, 31)], 2);
    expect(history.stored[Day(2027, 1, 1)], 3);
  });

  testWidgets('reset, target, delete, rename, restart and add change no day', (
    tester,
  ) async {
    final history = FakeHistoryRepository(stored: {_today: 9});
    final store = FakeDhikrStore([
      ('Zikir', _state(count: 5, total: 5)),
      ('Sabah', _state(count: 2, total: 2)),
    ]);
    final tesbihat = FakeTesbihatRepository(
      stored: const TesbihatState(step: 1, count: DhikrCount(4)),
    );
    await _start(tester, store: store, tesbihat: tesbihat, history: history);
    final c = _container(tester);

    await c.read(counterControllerProvider(1).notifier).reset();
    await c
        .read(counterControllerProvider(1).notifier)
        .changeTarget(Target.of(33));
    final list = c.read(dhikrListControllerProvider.notifier);
    await list.rename(1, DhikrName.stored('Akşam'));
    await list.delete(2);
    await list.append(DhikrName.stored('er-Rahmân'));
    await c.read(tesbihatControllerProvider.notifier).restart();
    await c.read(tesbihatControllerProvider.notifier).select(true);
    await tester.pumpAndSettle();

    expect(history.stored, {_today: 9});
    expect(await _shown(tester), DailyHistory({_today: 9}));
  });

  testWidgets('counting goes on when the history cannot be stored', (
    tester,
  ) async {
    final history = FakeHistoryRepository()..failWrites = true;
    final store = FakeDhikrStore([('Zikir', _state())]);
    await _start(tester, store: store, history: history);

    await _tap(tester, _button, 3);
    await _tap(tester, _undo);

    expect(store.stateOf(1).count.value, 2);
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('taps while the history loads are not lost', (tester) async {
    final history = FakeHistoryRepository(stored: {_today: 1})
      ..holdLoad = Completer<void>();
    await _start(tester, history: history);

    await _tap(tester, _button, 2);
    history.holdLoad!.complete();
    await tester.pumpAndSettle();

    expect((await _shown(tester)).countOn(_today), 3);
    expect(history.stored[_today], 3);
  });
}
