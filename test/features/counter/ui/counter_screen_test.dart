import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/features/counter/counter.dart';

import '../../../support/test_app.dart';

final _value = find.byKey(const Key('counter-value'));
final _tapArea = find.byKey(const Key('counter-tap-area'));
final _loading = find.byKey(const Key('counter-loading'));

String _shownCount(WidgetTester tester) => tester.widget<Text>(_value).data!;

void main() {
  testWidgets('shows 0 on first launch', (tester) async {
    await tester.pumpWidget(testApp(tester, repo: FakeCounterRepository()));
    await tester.pump();

    expect(
      find.text('Zikirlerim'),
      findsOneWidget,
    ); // title of the start section
    expect(_shownCount(tester), '0');
  });

  testWidgets('each tap increments, rapid taps included', (tester) async {
    final repo = FakeCounterRepository();
    await tester.pumpWidget(testApp(tester, repo: repo));
    await tester.pump();

    // Three taps without waiting in between: no debounce, every tap counts.
    await tester.tap(_tapArea);
    await tester.tap(_tapArea);
    await tester.tap(_tapArea);
    await tester.pump();

    expect(_shownCount(tester), '3');
    expect(repo.saves.map((c) => c.value), [1, 2, 3]); // stored right away
  });

  testWidgets('restart shows persisted count', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        testApp(tester, repo: DriftCounterRepository(db)),
      );
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await tester.tap(_tapArea);
    }
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(_shownCount(tester), '3');

    // "Restart": tear the whole app (and its state) down, then start it again
    // over the same storage.
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await tester.pumpWidget(
        testApp(tester, repo: DriftCounterRepository(db)),
      );
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();

    expect(_shownCount(tester), '3');
  });

  testWidgets('loading hides count and ignores taps', (tester) async {
    final repo = FakeCounterRepository(stored: 5)..holdLoad = Completer<void>();
    await tester.pumpWidget(testApp(tester, repo: repo));
    await tester.pump();

    expect(_loading, findsOneWidget);
    expect(_value, findsNothing);
    await tester.tap(find.byType(Scaffold), warnIfMissed: false);
    await tester.pump();
    expect(repo.saves, isEmpty);

    repo.holdLoad!.complete();
    await tester.pump();
    await tester.pump();
    expect(_loading, findsNothing);
    expect(_shownCount(tester), '5'); // the taps while loading were not counted
  });

  testWidgets('error shows message without details and ignores taps', (
    tester,
  ) async {
    final repo = FakeCounterRepository(stored: 5, failLoad: true);
    await tester.pumpWidget(testApp(tester, repo: repo));
    await tester.pump();
    await tester.pump();

    expect(find.text('Sayaç yüklenemedi.'), findsOneWidget);
    expect(find.textContaining('disk on fire'), findsNothing);
    expect(find.textContaining('zikirmatik.db'), findsNothing);
    expect(_value, findsNothing);

    await tester.tap(find.byType(Scaffold), warnIfMissed: false);
    await tester.pump();
    expect(repo.saves, isEmpty);
  });

  testWidgets('semantics labels', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      testApp(tester, repo: FakeCounterRepository(stored: 2)),
    );
    await tester.pump();

    await tester.tap(_tapArea);
    await tester.pump();

    expect(
      find.bySemanticsLabel('Sayım 3. Saymak için dokunun.'),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(_tapArea),
      isSemantics(
        label: 'Sayım 3. Saymak için dokunun.',
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(tester.getSize(_tapArea).shortestSide, greaterThanOrEqualTo(48));
    semantics.dispose();
  });
}
