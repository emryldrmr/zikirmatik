import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/history/history.dart';

import '../../../support/test_app.dart';

// Spec 0014 — Günlük geçmiş ve seri, the "Geçmiş" section (AC-4, AC-6…AC-10).

final _streak = find.byKey(const Key('history-streak'));
final _longest = find.byKey(const Key('history-longest'));
final _empty = find.byKey(const Key('history-empty'));
final _list = find.byKey(const Key('history-list'));
Finder _day(Day d) => find.byKey(Key('history-day-${d.iso}'));

final _today = Day(2026, 11, 8);

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

List<String> _texts(WidgetTester tester, Finder row) => tester
    .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
    .map((t) => t.data!)
    .toList();

Future<void> _start(
  WidgetTester tester, {
  FakeHistoryRepository? history,
  FakeClock? clock,
}) async {
  await tester.pumpWidget(testApp(tester, history: history, clock: clock));
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _openHistory(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('section-history')));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder f) =>
    tester.scrollUntilVisible(
      f,
      200,
      // The list's own vertical Scrollable; the badge row (spec 0016) is a
      // second, horizontal one inside it (plan 0016, A-1).
      scrollable: find
          .descendant(of: _list, matching: find.byType(Scrollable))
          .first,
    );

void main() {
  testWidgets('thirty days from today with zeros and Turkish dates', (
    tester,
  ) async {
    final history = FakeHistoryRepository(
      stored: {_today: 12, Day(2026, 11, 7): 3, Day(2026, 11, 5): 8},
    );
    await _start(tester, history: history);
    await _openHistory(tester);

    expect(find.widgetWithText(AppBar, 'Geçmiş'), findsOneWidget);
    expect(_text(tester, _streak), 'Seri: 2 gün');
    expect(_text(tester, _longest), 'En uzun seri: 2 gün');
    expect(_texts(tester, _day(_today)), ['Bugün', '12']);
    expect(_texts(tester, _day(Day(2026, 11, 7))), [
      '7 Kasım 2026, Cumartesi',
      '3',
    ]);
    expect(_texts(tester, _day(Day(2026, 11, 6))), ['6 Kasım 2026, Cuma', '0']);
    expect(find.text('Bu bölüm yakında.'), findsNothing);

    final last = Day(2026, 10, 10);
    await _scrollTo(tester, _day(last));
    expect(_texts(tester, _day(last)), ['10 Ekim 2026, Cumartesi', '0']);
    await tester.drag(_list, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(_day(last.previous), findsNothing); // exactly 30 days
  });

  testWidgets('thousands separator', (tester) async {
    final history = FakeHistoryRepository(stored: {_today: 1250});
    await _start(tester, history: history);
    await _openHistory(tester);

    expect(_texts(tester, _day(_today)), ['Bugün', '1.250']);
  });

  testWidgets('future days are hidden', (tester) async {
    final history = FakeHistoryRepository(
      stored: {_today.next: 5, _today.next.next: 5},
    );
    await _start(tester, history: history);
    await _openHistory(tester);

    expect(_day(_today.next), findsNothing);
    expect(_text(tester, _streak), 'Seri: 0 gün');
    expect(_text(tester, _longest), 'En uzun seri: 0 gün');
    expect(_empty, findsOneWidget);
  });

  testWidgets('today follows the clock on resume', (tester) async {
    final clock = FakeClock(DateTime(2026, 11, 8, 23, 59));
    final history = FakeHistoryRepository(stored: {_today: 4});
    await _start(tester, history: history, clock: clock);
    await _openHistory(tester);
    expect(_texts(tester, _day(_today)), ['Bugün', '4']);

    // The phone's order: resumed → inactive → hidden → paused and back.
    for (final s in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump();
    clock.now = DateTime(2026, 11, 9, 0, 1);
    for (final s in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pumpAndSettle();

    expect(_texts(tester, _day(_today.next)), ['Bugün', '0']);
    expect(_texts(tester, _day(_today)), ['8 Kasım 2026, Pazar', '4']);
    expect(_text(tester, _streak), 'Seri: 1 gün'); // from yesterday
  });

  testWidgets('today follows the clock when the section is entered again', (
    tester,
  ) async {
    final clock = FakeClock(DateTime(2026, 11, 8, 23, 59));
    await _start(tester, clock: clock);
    await _openHistory(tester);
    await tester.binding.handlePopRoute(); // back to Zikirlerim
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('counter-tap-area')));
    await tester.pumpAndSettle();
    clock.now = DateTime(2026, 11, 9, 0, 1);
    await tester.tap(find.byKey(const Key('counter-tap-area')));
    await tester.pumpAndSettle();
    await _openHistory(tester);

    expect(_texts(tester, _day(_today.next)), ['Bugün', '1']);
    expect(_texts(tester, _day(_today)), ['8 Kasım 2026, Pazar', '1']);
    expect(_text(tester, _streak), 'Seri: 2 gün');
  });

  testWidgets('back from history returns to Zikirlerim', (tester) async {
    await _start(tester);
    await _openHistory(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Zikirlerim'), findsOneWidget);
    expect(find.byKey(const Key('counter-tap-area')), findsOneWidget);
  });

  testWidgets('loading indicator', (tester) async {
    final history = FakeHistoryRepository()..holdLoad = Completer<void>();
    await _start(tester, history: history);
    await tester.tap(find.byKey(const Key('open-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-history')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('history-loading')), findsOneWidget);
    history.holdLoad!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-loading')), findsNothing);
    expect(_empty, findsOneWidget);
  });

  testWidgets('empty state', (tester) async {
    await _start(tester);
    await _openHistory(tester);

    expect(_text(tester, _streak), 'Seri: 0 gün');
    expect(_text(tester, _longest), 'En uzun seri: 0 gün');
    expect(_text(tester, _empty), 'Henüz sayım yok.');
    expect(_day(_today), findsNothing);
  });

  testWidgets('load error keeps counting', (tester) async {
    final history = FakeHistoryRepository(failLoad: true);
    final repo = FakeCounterRepository();
    await tester.pumpWidget(testApp(tester, repo: repo, history: history));
    await tester.pumpAndSettle();
    await _openHistory(tester);

    expect(
      _text(tester, find.byKey(const Key('history-error'))),
      'Geçmiş yüklenemedi.',
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('counter-tap-area')));
    await tester.pumpAndSettle();
    expect(repo.stored.count.value, 1);
    expect(history.stored[_today], 1); // the write still went through
  });

  testWidgets('row semantics, largest text and touch targets', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final semantics = tester.ensureSemantics();
    // 30 September 2026 is "30 Eylül 2026, Çarşamba", among the longest.
    final today = Day(2026, 10, 2);
    final history = FakeHistoryRepository(
      stored: {today: 3, Day(2026, 9, 30): 123456},
    );
    await _start(
      tester,
      history: history,
      clock: FakeClock(DateTime(2026, 10, 2, 9)),
    );
    await _openHistory(tester);

    expect(
      tester.getSemantics(_day(today)),
      matchesSemantics(label: 'Bugün: 3 zikir'),
    );
    final long = Day(2026, 9, 30);
    // Below the badges (spec 0016) the row starts out of view (plan 0016, A-1).
    await _scrollTo(tester, _day(long));
    expect(
      tester.getSemantics(_day(long)),
      matchesSemantics(label: '30 Eylül 2026, Çarşamba: 123.456 zikir'),
    );
    expect(
      tester.getSemantics(_streak),
      matchesSemantics(label: 'Seri: 1 gün'),
    );

    for (final f in [_streak, _longest, _day(long), _day(today)]) {
      for (final p in tester.renderObjectList<RenderParagraph>(
        find.descendant(of: f, matching: find.byType(RichText)),
      )) {
        expect(p.didExceedMaxLines, isFalse);
        final whole = TextPainter(
          text: p.text,
          textDirection: p.textDirection,
          textScaler: p.textScaler,
        )..layout(maxWidth: p.size.width);
        addTearDown(whole.dispose);
        expect(p.size.height, greaterThanOrEqualTo(whole.height - 0.5));
      }
    }
    for (final d in [today, long]) {
      expect(tester.getSize(_day(d)).height, greaterThanOrEqualTo(48));
    }
    expect(tester.takeException(), isNull); // no overflow
    semantics.dispose();
  });
}
