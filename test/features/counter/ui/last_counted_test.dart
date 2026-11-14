import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/ui/counter_controller.dart';
import 'package:zikirmatik/features/counter/ui/tesbihat_controller.dart';

import '../../../support/test_app.dart';

// Spec 0017 — where the user left off (Req. 1–2; AC-3, AC-4; G1, G2, G5).

final _tapArea = find.byKey(const Key('counter-tap-area'));

CounterState _state({int count = 0, int total = 0, int? target}) =>
    CounterState(
      count: DhikrCount(count),
      total: total,
      target: target == null ? null : Target.of(target),
    );

/// "A" (id 1, target 33) and "B" (id 2, no target); A is selected.
FakeDhikrStore _two() => FakeDhikrStore([
  ('A', _state(count: 1, total: 1, target: 33)),
  ('B', _state(count: 10, total: 10)),
]);

Future<ProviderContainer> _start(
  WidgetTester tester, {
  FakeDhikrStore? store,
  FakeTesbihatRepository? tesbihat,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(tester, store: store ?? _two(), tesbihat: tesbihat),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(ZikirmatikApp)));
}

Future<void> _tapTimes(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.tap(_tapArea);
    await tester.pump();
  }
}

CounterController _dhikr(ProviderContainer c, int id) =>
    c.read(counterControllerProvider(id).notifier);

TesbihatController _tesbihat(ProviderContainer c) =>
    c.read(tesbihatControllerProvider.notifier);

void main() {
  testWidgets('no counting tap gives nothing', (tester) async {
    final c = await _start(tester);
    expect(c.read(resumePointProvider), isNull);

    // Selection, undo and reset are not counting taps (Req. 1).
    await c.read(dhikrListControllerProvider.notifier).select(2);
    await _dhikr(c, 2).undo();
    await _dhikr(c, 1).reset();
    await _tesbihat(c).select(true);
    await _tesbihat(c).select(false);
    await tester.pump();
    expect(c.read(lastCountedProvider), isNull);
    expect(c.read(resumePointProvider), isNull);
  });

  testWidgets('a counting tap gives that dhikr with its values', (
    tester,
  ) async {
    final c = await _start(tester);
    await _tapTimes(tester, 4);
    expect(
      c.read(resumePointProvider),
      const DhikrResume(id: 1, name: 'A', count: 5, target: 33),
    );
  });

  testWidgets('latest counted wins over selection', (tester) async {
    final c = await _start(tester);
    await _tapTimes(tester, 3); // A
    await c.read(dhikrListControllerProvider.notifier).select(2);
    await tester.pumpAndSettle();
    await _tapTimes(tester, 2); // B
    expect(
      c.read(resumePointProvider),
      const DhikrResume(id: 2, name: 'B', count: 12),
    );

    // A selected but not tapped: still B.
    await c.read(dhikrListControllerProvider.notifier).select(1);
    await tester.pump();
    expect(c.read(resumePointProvider)?.item, const CountedDhikr(2));
  });

  testWidgets('undo keeps the item', (tester) async {
    final c = await _start(tester);
    await _tapTimes(tester, 2); // A: 3
    await _dhikr(c, 1).undo(); // A: 2
    expect(
      c.read(resumePointProvider),
      const DhikrResume(id: 1, name: 'A', count: 2, target: 33),
    );
  });

  testWidgets('round completion shows zero', (tester) async {
    final c = await _start(
      tester,
      store: FakeDhikrStore([('A', _state(count: 32, total: 32, target: 33))]),
    );
    await _tapTimes(tester, 1);
    expect(
      c.read(resumePointProvider),
      const DhikrResume(id: 1, name: 'A', count: 0, target: 33),
    );
  });

  testWidgets('reset restart delete clear', (tester) async {
    final c = await _start(tester);

    // Reset (G1) — until the next counting tap.
    await _tapTimes(tester, 1);
    await _dhikr(c, 1).reset();
    expect(c.read(resumePointProvider), isNull);
    await _tapTimes(tester, 1);
    expect(c.read(resumePointProvider)?.item, const CountedDhikr(1));

    // Resetting another dhikr keeps A.
    await _dhikr(c, 2).reset();
    expect(c.read(resumePointProvider)?.item, const CountedDhikr(1));

    // Tesbihat "Baştan başla" / "Sıfırla" (G1).
    await _tesbihat(c).select(true);
    await tester.pump();
    await _tapTimes(tester, 1);
    expect(c.read(resumePointProvider)?.item, const CountedTesbihat());
    await _tesbihat(c).restart();
    expect(c.read(resumePointProvider), isNull);

    // Delete (G1).
    await _tesbihat(c).select(false);
    await tester.pump();
    await _tapTimes(tester, 1); // A
    await c.read(dhikrListControllerProvider.notifier).delete(1);
    await tester.pump();
    expect(c.read(lastCountedProvider), isNull);
    expect(c.read(resumePointProvider), isNull);
  });

  testWidgets('tesbihat gives its step, count and target', (tester) async {
    final c = await _start(
      tester,
      tesbihat: FakeTesbihatRepository(
        stored: TesbihatState(step: 1, count: DhikrCount(11), selected: true),
      ),
    );
    await _tapTimes(tester, 1);
    expect(
      c.read(resumePointProvider),
      const TesbihatResume(stepNumber: 2, count: 12, target: 33),
    );
  });

  testWidgets('finished tesbihat gives nothing', (tester) async {
    final c = await _start(
      tester,
      tesbihat: FakeTesbihatRepository(
        stored: TesbihatState(step: 2, count: DhikrCount(32), selected: true),
      ),
    );
    await _tapTimes(tester, 1); // finishes it (G2)
    expect(c.read(lastCountedProvider), const CountedTesbihat());
    expect(c.read(resumePointProvider), isNull);
  });

  testWidgets('full screen tap counts', (tester) async {
    final c = await _start(tester);
    final open = find.byKey(const Key('full-screen-open'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('full-screen-tap-area')));
    await tester.pump();
    expect(
      c.read(resumePointProvider),
      const DhikrResume(id: 1, name: 'A', count: 2, target: 33),
    );
  });
}
