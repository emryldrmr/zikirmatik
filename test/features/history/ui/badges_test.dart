import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/history/history.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';

// Spec 0016 — Rozetler, the badges in the "Geçmiş" section (AC-1…AC-11).

const _ids = ['firstDay', 'week', 'month', 'hundred', 'year'];
const _names = ['İlk gün', 'Bir hafta', 'Bir ay', '100 gün', 'Bir yıl'];

final _row = find.byKey(const Key('badge-row'));
final _next = find.byKey(const Key('badge-next'));
final _markLeft = find.byKey(const Key('badge-mark-left'));
final _markRight = find.byKey(const Key('badge-mark-right'));
final _longest = find.byKey(const Key('history-longest'));
final _list = find.byKey(const Key('history-list'));
Finder _badge(String id) => find.byKey(Key('badge-$id'));
Finder _earned(String id) => find.byKey(Key('badge-$id-earned'));
Finder _locked(String id) => find.byKey(Key('badge-$id-locked'));
Finder _condition(String id) => find.byKey(Key('badge-$id-condition'));

/// Default test clock: noon, 8 November 2026.
final _today = Day(2026, 11, 8);

/// [length] consecutive counted days ending on [last].
Map<Day, int> _run(Day last, int length) {
  final map = <Day, int>{};
  var day = last;
  for (var i = 0; i < length; i++) {
    map[day] = 1;
    day = day.previous;
  }
  return map;
}

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

Future<void> _start(
  WidgetTester tester, {
  FakeHistoryRepository? history,
  FakeClock? clock,
  FakeHaptics? haptics,
  FakeSettingsRepository? settings,
}) async {
  await tester.pumpWidget(
    testApp(
      tester,
      history: history,
      clock: clock,
      haptics: haptics,
      settings: settings,
    ),
  );
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

Future<void> _show(WidgetTester tester, Map<Day, int> stored) async {
  await _start(tester, history: FakeHistoryRepository(stored: stored));
  await _openHistory(tester);
}

void _narrow(WidgetTester tester, [double width = 320]) {
  tester.view.physicalSize = Size(width, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

double _left(WidgetTester tester, Finder f) => tester.getTopLeft(f).dx;
double _right(WidgetTester tester, Finder f) => tester.getTopRight(f).dx;

/// Which badges show as earned, in threshold order.
List<bool> _earnedStates(WidgetTester tester) => [
  for (final id in _ids) tester.any(_earned(id)),
];

/// Badge labels in the screen reader's traversal order.
List<String> _badgeLabels(WidgetTester tester) {
  final labels = <String>[];
  void visit(SemanticsNode node) {
    if (node.label.startsWith('Rozet:')) labels.add(node.label);
    for (final child in node.debugListChildrenInOrder(
      DebugSemanticsDumpOrder.traversalOrder,
    )) {
      visit(child);
    }
  }

  visit(tester.getSemantics(_row));
  return labels;
}

void main() {
  testWidgets('five badges in order between streaks and days', (tester) async {
    await _show(tester, {_today: 3});

    for (var i = 0; i < _ids.length; i++) {
      expect(
        find.descendant(of: _badge(_ids[i]), matching: find.text(_names[i])),
        findsOneWidget,
      );
      if (i > 0) {
        expect(
          _left(tester, _badge(_ids[i])),
          greaterThan(_right(tester, _badge(_ids[i - 1]))),
        );
      }
    }
    final rowTop = tester.getTopLeft(_row).dy;
    expect(rowTop, greaterThan(tester.getBottomLeft(_longest).dy));
    final today = find.byKey(Key('history-day-${_today.iso}'));
    expect(
      tester.getTopLeft(today).dy,
      greaterThan(tester.getBottomLeft(_next).dy),
    );
  });

  testWidgets('earned and locked follow the longest streak', (tester) async {
    await _show(tester, _run(_today, 7));

    expect(_earnedStates(tester), [true, true, false, false, false]);
    for (final id in ['month', 'hundred', 'year']) {
      expect(_locked(id), findsOneWidget);
    }
  });

  testWidgets('history from before badges opens them', (tester) async {
    // 30 days in September, counted before badges existed; nothing since.
    await _show(tester, _run(Day(2026, 9, 30), 30));

    expect(
      _text(tester, find.byKey(const Key('history-streak'))),
      'Seri: 0 gün',
    );
    expect(_earnedStates(tester), [true, true, true, false, false]);
    expect(_text(tester, _next), 'Sıradaki rozete 100 gün');
  });

  testWidgets('next badge line and all earned', (tester) async {
    // Streak 5 today, longest 40 earlier: 100 − 5.
    await _show(tester, {..._run(Day(2026, 9, 30), 40), ..._run(_today, 5)});
    expect(_text(tester, _next), 'Sıradaki rozete 95 gün');

    await tester.pumpWidget(const SizedBox()); // a fresh app
    await _show(tester, _run(_today, 365));
    expect(_earnedStates(tester), [true, true, true, true, true]);
    expect(_text(tester, _next), 'Tüm rozetler kazanıldı.');
  });

  testWidgets('today not counted yet, six days to yesterday', (tester) async {
    await _show(tester, _run(_today.previous, 6));
    expect(_text(tester, _next), 'Sıradaki rozete 1 gün');
  });

  testWidgets('locked shows its condition, earned shows none, no dates', (
    tester,
  ) async {
    await _show(tester, _run(_today, 7));

    expect(_condition('firstDay'), findsNothing);
    expect(_condition('week'), findsNothing);
    expect(_text(tester, _condition('month')), '30 gün seri');
    expect(_text(tester, _condition('hundred')), '100 gün seri');
    expect(_text(tester, _condition('year')), '365 gün seri');
    final texts = tester
        .widgetList<Text>(
          find.descendant(of: _row, matching: find.byType(Text)),
        )
        .map((t) => t.data!);
    for (final t in texts) {
      expect(t, isNot(matches(RegExp(r'2026|Kasım|Ekim|\.\d'))));
    }
  });

  testWidgets('badges follow the streak on resume after midnight', (
    tester,
  ) async {
    final clock = FakeClock(DateTime(2026, 11, 8, 23, 59));
    await _start(
      tester,
      history: FakeHistoryRepository(stored: _run(_today, 7)),
      clock: clock,
    );
    await _openHistory(tester);
    expect(_earnedStates(tester), [true, true, false, false, false]);
    expect(_text(tester, _next), 'Sıradaki rozete 23 gün');

    for (final s in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump();
    // Two midnights later: the streak is broken, the badges stay.
    clock.now = DateTime(2026, 11, 10, 0, 1);
    for (final s in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pumpAndSettle();

    expect(
      _text(tester, find.byKey(const Key('history-streak'))),
      'Seri: 0 gün',
    );
    expect(_earnedStates(tester), [true, true, false, false, false]);
    expect(_text(tester, _next), 'Sıradaki rozete 30 gün');
  });

  testWidgets('earning tap shows no message and no extra vibration', (
    tester,
  ) async {
    final haptics = FakeHaptics();
    final history = FakeHistoryRepository(stored: _run(_today.previous, 6));
    await _start(
      tester,
      history: history,
      haptics: haptics,
      settings: FakeSettingsRepository(
        stored: AppSettings.defaults.copyWith(tapVibration: true),
      ),
    );
    final button = find.byKey(const Key('counter-tap-area'));

    // The 7th day's first tap earns "Bir hafta".
    await tester.tap(button);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(history.stored[_today], 1);
    expect(haptics.taps, 1);
    expect(haptics.roundsCompleted, 0);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(MaterialBanner), findsNothing);
    expect(find.byKey(const Key('storage-notice')), findsNothing);
    expect(find.textContaining('ozet'), findsNothing);

    // A tap that earns nothing vibrates the same.
    await tester.tap(button);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(haptics.taps, 2);
    expect(haptics.roundsCompleted, 0);

    await _openHistory(tester);
    expect(_earned('week'), findsOneWidget);
  });

  testWidgets('empty state shows five locked and next in one day', (
    tester,
  ) async {
    await _show(tester, {});

    expect(_earnedStates(tester), [false, false, false, false, false]);
    for (final id in _ids) {
      expect(_locked(id), findsOneWidget);
    }
    expect(_text(tester, _next), 'Sıradaki rozete 1 gün');
    final empty = find.byKey(const Key('history-empty'));
    expect(_text(tester, empty), 'Henüz sayım yok.');
    expect(
      tester.getTopLeft(empty).dy,
      greaterThan(tester.getBottomLeft(_next).dy),
    );
  });

  testWidgets('no badges while loading', (tester) async {
    final history = FakeHistoryRepository(stored: _run(_today, 7))
      ..holdLoad = Completer<void>();
    await _start(tester, history: history);
    await tester.tap(find.byKey(const Key('open-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-history')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('history-loading')), findsOneWidget);
    expect(_row, findsNothing);
    expect(_next, findsNothing);
    history.holdLoad!.complete();
    await tester.pumpAndSettle();
    expect(_row, findsOneWidget);
  });

  testWidgets('no badges on load error, counting works', (tester) async {
    final history = FakeHistoryRepository(
      stored: _run(_today, 7),
      failLoad: true,
    );
    await _start(tester, history: history);
    await _openHistory(tester);

    expect(
      _text(tester, find.byKey(const Key('history-error'))),
      'Geçmiş yüklenemedi.',
    );
    expect(_row, findsNothing);
    expect(_next, findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('counter-tap-area')));
    await tester.pumpAndSettle();
    expect(history.stored[_today], 2);
  });

  testWidgets('badges are the same after restart', (tester) async {
    final history = FakeHistoryRepository(
      stored: {..._run(Day(2026, 9, 30), 40), ..._run(_today, 5)},
    );
    await _start(tester, history: history);
    await _openHistory(tester);
    expect(_earnedStates(tester), [true, true, true, false, false]);
    expect(_text(tester, _next), 'Sıradaki rozete 95 gün');

    // A new app on the same storage.
    await tester.pumpWidget(const SizedBox());
    await _start(tester, history: history);
    await _openHistory(tester);
    expect(_earnedStates(tester), [true, true, true, false, false]);
    expect(_text(tester, _next), 'Sıradaki rozete 95 gün');
  });

  testWidgets('badge semantics in threshold order including off screen', (
    tester,
  ) async {
    _narrow(tester);
    final semantics = tester.ensureSemantics();
    await _show(tester, _run(_today, 7));

    // At 320 dp the later badges are out of view; they are still read.
    expect(_right(tester, _badge('year')), greaterThan(_right(tester, _row)));
    expect(_badgeLabels(tester), [
      'Rozet: İlk gün, kazanıldı',
      'Rozet: Bir hafta, kazanıldı',
      'Rozet: Bir ay, kazanılmadı, 30 gün seri gerekir',
      'Rozet: 100 gün, kazanılmadı, 100 gün seri gerekir',
      'Rozet: Bir yıl, kazanılmadı, 365 gün seri gerekir',
    ]);
    // The edge marks are not items of their own.
    expect(_markRight, findsOneWidget);
    expect(
      find.descendant(of: _markRight, matching: find.byType(ExcludeSemantics)),
      findsWidgets,
    );
    semantics.dispose();
  });

  testWidgets('largest text at 320 dp clips nothing', (tester) async {
    _narrow(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _show(tester, _run(_today, 7));

    for (final id in _ids) {
      for (final p in tester.renderObjectList<RenderParagraph>(
        find.descendant(of: _badge(id), matching: find.byType(RichText)),
      )) {
        expect(p.didExceedMaxLines, isFalse);
        final whole = TextPainter(
          text: p.text,
          textDirection: p.textDirection,
          textScaler: p.textScaler,
        )..layout();
        addTearDown(whole.dispose);
        expect(
          p.size.width,
          greaterThanOrEqualTo(whole.width - 0.5),
          reason: id,
        );
        expect(p.size.height, greaterThanOrEqualTo(whole.height - 0.5));
      }
    }
    expect(tester.takeException(), isNull); // no overflow
  });

  testWidgets('readable in light and dark', (tester) async {
    for (final theme in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        history: FakeHistoryRepository(stored: _run(_today, 7)),
        settings: FakeSettingsRepository(
          stored: AppSettings.defaults.copyWith(theme: theme),
        ),
      );
      await _openHistory(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
  });

  testWidgets('latest earned starts at the left edge', (tester) async {
    _narrow(tester);
    await _show(tester, _run(_today, 40));

    expect(_left(tester, _badge('month')), closeTo(_left(tester, _row), 0.5));
    expect(
      _right(tester, _badge('week')),
      lessThanOrEqualTo(_left(tester, _row)),
    );
    expect(_markLeft, findsOneWidget);

    // Scrolling right to left brings "İlk gün" and "Bir hafta" back.
    await tester.drag(_row, const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(
      _left(tester, _badge('firstDay')),
      closeTo(_left(tester, _row), 0.5),
    );
    expect(_markLeft, findsNothing);
  });

  testWidgets('nothing earned starts with İlk gün', (tester) async {
    _narrow(tester);
    await _show(tester, {});

    expect(
      _left(tester, _badge('firstDay')),
      closeTo(_left(tester, _row), 0.5),
    );
    expect(_markLeft, findsNothing);
    expect(_markRight, findsOneWidget);
  });

  testWidgets('all earned rests at the end', (tester) async {
    _narrow(tester);
    await _show(tester, _run(_today, 365));

    // "Bir yıl" cannot reach the left edge: the row rests at its end.
    expect(_right(tester, _badge('year')), closeTo(_right(tester, _row), 0.5));
    expect(_left(tester, _badge('year')), greaterThan(_left(tester, _row)));
    expect(_markRight, findsNothing);
    expect(_markLeft, findsOneWidget);
  });

  testWidgets('edge marks follow hidden badges at 320 dp and wide', (
    tester,
  ) async {
    _narrow(tester);
    await _show(tester, {});
    expect((tester.any(_markLeft), tester.any(_markRight)), (false, true));

    // Somewhere in the middle: both edges hide badges.
    await tester.drag(_row, const Offset(-120, 0));
    await tester.pumpAndSettle();
    expect((tester.any(_markLeft), tester.any(_markRight)), (true, true));

    await tester.drag(_row, const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect((tester.any(_markLeft), tester.any(_markRight)), (true, false));

    // Wide enough for all five: no marks.
    await tester.pumpWidget(const SizedBox());
    _narrow(tester, 1200);
    await _show(tester, {});
    expect((tester.any(_markLeft), tester.any(_markRight)), (false, false));
    expect(_list, findsOneWidget);
  });
}
