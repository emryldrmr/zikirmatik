import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';

// Spec 0010 — Tam ekran sayma (AC-1…AC-7, AC-10).

final _open = find.byKey(const Key('full-screen-open'));
final _full = find.byKey(const Key('full-screen'));
final _area = find.byKey(const Key('full-screen-tap-area'));
final _count = find.byKey(const Key('full-screen-count'));
final _undo = find.byKey(const Key('full-screen-undo'));
final _close = find.byKey(const Key('full-screen-close'));

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

CounterState _state({
  int count = 0,
  int rounds = 0,
  int total = 0,
  int? target,
}) => CounterState(
  count: DhikrCount(count),
  rounds: rounds,
  total: total,
  target: target == null ? null : Target.of(target),
);

FakeDhikrStore _sabah({int count = 7, int total = 73, int? target = 33}) =>
    FakeDhikrStore([
      ('Sabah', _state(count: count, rounds: 2, total: total, target: target)),
    ]);

/// A phone-sized screen.
void _phone(WidgetTester tester, {Size size = const Size(400, 800)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _start(
  WidgetTester tester, {
  FakeDhikrStore? store,
  FakeTesbihatRepository? tesbihat,
  FakeHaptics? haptics,
  FakeSystemBars? bars,
  AppSettings settings = AppSettings.defaults,
}) async {
  await tester.pumpWidget(
    testApp(
      tester,
      store: store ?? _sabah(),
      tesbihat: tesbihat,
      haptics: haptics,
      systemBars: bars,
      settings: FakeSettingsRepository(stored: settings),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openFullScreen(WidgetTester tester) async {
  await tester.ensureVisible(_open);
  await tester.tap(_open);
  await tester.pumpAndSettle();
}

/// Points spread over the screen, the four corners and the information
/// included, never on "Geri al" or "Kapat".
List<Offset> _points(WidgetTester tester) {
  final size = tester.getSize(_full);
  return [
    Offset(size.width / 2, size.height / 2), // the count itself
    Offset(size.width / 2, size.height * 0.3), // the name
    Offset(8, 120), // top left, under "Geri al"
    Offset(size.width - 8, 120), // top right, under "Kapat"
    Offset(size.width / 2, 24), // top, between the buttons
    Offset(8, size.height - 8),
    Offset(size.width - 8, size.height - 8),
  ];
}

void main() {
  testWidgets('full screen button on dhikr and tesbihat', (tester) async {
    await _start(tester);
    expect(_open, findsOneWidget);
    expect(find.text('Tam ekran'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _start(
      tester,
      tesbihat: FakeTesbihatRepository(
        stored: const TesbihatState(selected: true),
      ),
    );
    expect(find.byKey(const Key('tesbihat-text')), findsOneWidget);
    expect(_open, findsOneWidget);

    // Also once the tesbihat is finished.
    await tester.pumpWidget(const SizedBox());
    await _start(
      tester,
      tesbihat: FakeTesbihatRepository(
        stored: const TesbihatState(step: 2, finished: true, selected: true),
      ),
    );
    expect(find.byKey(const Key('tesbihat-finished')), findsOneWidget);
    expect(_open, findsOneWidget);
  });

  testWidgets('no full screen button when empty, loading or failed', (
    tester,
  ) async {
    await _start(tester, store: FakeDhikrStore([]));
    expect(find.byKey(const Key('dhikr-empty')), findsOneWidget);
    expect(_open, findsNothing);

    await tester.pumpWidget(const SizedBox());
    final loading = FakeCounterRepository(stored: 5)
      ..holdLoad = Completer<void>();
    await tester.pumpWidget(testApp(tester, repo: loading));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('counter-loading')), findsOneWidget);
    expect(_open, findsNothing);
    loading.holdLoad!.complete();
    await tester.pumpAndSettle();
    expect(_open, findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      testApp(tester, repo: FakeCounterRepository(failLoad: true)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('counter-error')), findsOneWidget);
    expect(_open, findsNothing);
  });

  testWidgets('full screen hides the bars and shows the dhikr', (tester) async {
    _phone(tester);
    final bars = FakeSystemBars();
    await _start(tester, bars: bars);
    expect(bars.hidden, isFalse);

    await _openFullScreen(tester);
    expect(_full, findsOneWidget);
    expect(bars.hidden, isTrue);
    expect(_text(tester, find.byKey(const Key('full-screen-name'))), 'Sabah');
    expect(_text(tester, _count), '7');
    expect(
      _text(tester, find.byKey(const Key('full-screen-target'))),
      'Hedef 33 · Tur 2',
    );
    expect(
      _text(tester, find.byKey(const Key('full-screen-total'))),
      'Toplam 73',
    );
  });

  testWidgets('full screen without a target says no target', (tester) async {
    _phone(tester);
    await _start(tester, store: _sabah(target: null));
    await _openFullScreen(tester);
    expect(
      _text(tester, find.byKey(const Key('full-screen-target'))),
      'Hedef yok',
    );
  });

  testWidgets('a tap anywhere counts', (tester) async {
    _phone(tester);
    final store = _sabah(count: 0, total: 0, target: null);
    await _start(tester, store: store);
    await _openFullScreen(tester);

    final points = _points(tester);
    for (final (i, p) in points.indexed) {
      await tester.tapAt(p);
      await tester.pump();
      expect(_text(tester, _count), '${i + 1}', reason: 'at $p');
    }
    expect(store.stateOf(1).total, points.length);
  });

  testWidgets('ten fast taps count ten', (tester) async {
    _phone(tester);
    final store = _sabah(count: 0, total: 0, target: null);
    await _start(tester, store: store);
    await _openFullScreen(tester);

    final center = tester.getCenter(_full);
    for (var i = 0; i < 10; i++) {
      await tester.tapAt(center); // no frame in between
    }
    await tester.pump();
    expect(_text(tester, _count), '10');
    expect(store.stateOf(1).count.value, 10);
    expect(store.stateOf(1).total, 10);
  });

  testWidgets('two fingers count once', (tester) async {
    _phone(tester);
    await _start(tester, store: _sabah(count: 0, total: 0, target: null));
    await _openFullScreen(tester);

    final a = await tester.startGesture(const Offset(100, 400), pointer: 1);
    final b = await tester.startGesture(const Offset(300, 500), pointer: 2);
    await a.up();
    await tester.pump();
    expect(_text(tester, _count), '0'); // a finger is still down
    await b.up();
    await tester.pump();
    expect(_text(tester, _count), '1');

    // The second finger lands after the first, lifts before it.
    final c = await tester.startGesture(const Offset(100, 400), pointer: 3);
    final d = await tester.startGesture(const Offset(300, 500), pointer: 4);
    await d.up();
    await c.up();
    await tester.pump();
    expect(_text(tester, _count), '2');
  });

  testWidgets('a cancelled touch does not count', (tester) async {
    _phone(tester);
    await _start(tester, store: _sabah(count: 0, total: 0, target: null));
    await _openFullScreen(tester);

    final g = await tester.startGesture(const Offset(5, 400));
    await g.cancel();
    await tester.pump();
    expect(_text(tester, _count), '0');

    // A moving finger still counts (holding the phone).
    final m = await tester.startGesture(const Offset(200, 400));
    await m.moveBy(const Offset(30, 40));
    await m.up();
    await tester.pump();
    expect(_text(tester, _count), '1');
  });

  testWidgets('full screen reaches the target and keeps it after restart', (
    tester,
  ) async {
    _phone(tester);
    final store = _sabah(count: 31, total: 31);
    await _start(tester, store: store);
    await _openFullScreen(tester);

    await tester.tapAt(tester.getCenter(_full));
    await tester.pump();
    expect(_text(tester, _count), '32');
    await tester.tapAt(tester.getCenter(_full));
    await tester.pump();
    expect(_text(tester, _count), '0'); // BR-4
    expect(
      _text(tester, find.byKey(const Key('full-screen-target'))),
      'Hedef 33 · Tur 3',
    );
    await tester.tapAt(tester.getCenter(_full));
    await tester.pump();

    // "Restart" with the same store: the normal screen, the same values.
    await tester.pumpWidget(const SizedBox());
    await _start(tester, store: store);
    expect(_full, findsNothing);
    expect(_text(tester, find.byKey(const Key('counter-value'))), '1');
    expect(find.text('Hedef 33 · Tur 3'), findsOneWidget);
    expect(find.text('Toplam 34'), findsOneWidget);
  });

  testWidgets('full screen taps follow the vibration settings', (tester) async {
    _phone(tester);
    for (final (tapOn, roundOn) in [
      (true, true),
      (true, false),
      (false, true),
      (false, false),
    ]) {
      final haptics = FakeHaptics();
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        store: _sabah(count: 31, total: 31),
        haptics: haptics,
        settings: AppSettings(
          vibration: roundOn,
          theme: ThemeChoice.system,
          tapVibration: tapOn,
        ),
      );
      await _openFullScreen(tester);
      await tester.tapAt(tester.getCenter(_full)); // 32
      await tester.tapAt(tester.getCenter(_full)); // 33: the round
      await tester.pump();

      final why = 'tap $tapOn, round $roundOn';
      expect(haptics.roundsCompleted, roundOn ? 1 : 0, reason: why);
      // Spec 0009, AC-4: the round tap vibrates once.
      expect(haptics.taps, tapOn ? (roundOn ? 1 : 2) : 0, reason: why);
    }
  });

  testWidgets('tesbihat full screen steps and finishes', (tester) async {
    _phone(tester);
    final haptics = FakeHaptics();
    final tesbihat = FakeTesbihatRepository(
      stored: TesbihatState(
        step: 1,
        count: const DhikrCount(32),
        selected: true,
      ),
    );
    await _start(tester, tesbihat: tesbihat, haptics: haptics);
    await _openFullScreen(tester);

    final text = find.byKey(const Key('full-screen-step-text'));
    expect(_text(tester, text), 'Elhamdülillâh');
    expect(
      _text(tester, find.byKey(const Key('full-screen-step'))),
      'Adım 2/3',
    );
    expect(_text(tester, _count), '32');
    expect(
      _text(tester, find.byKey(const Key('full-screen-target'))),
      'Hedef 33',
    );

    await tester.tapAt(tester.getCenter(_full)); // BR-13: the next step
    await tester.pump();
    expect(_text(tester, text), 'Allâhu ekber');
    expect(
      _text(tester, find.byKey(const Key('full-screen-step'))),
      'Adım 3/3',
    );
    expect(_text(tester, _count), '0');
    expect(haptics.roundsCompleted, 1);

    for (var i = 0; i < 33; i++) {
      await tester.tapAt(tester.getCenter(_full));
    }
    await tester.pump();
    expect(find.byKey(const Key('full-screen-finished')), findsOneWidget);
    expect(find.text('Tesbihat tamamlandı'), findsOneWidget);
    expect(tesbihat.stored.finished, isTrue);
    expect(_undo, findsNothing); // G6: nothing but "Kapat"
    expect(find.text('Baştan başla'), findsNothing);

    final saves = tesbihat.saves.length;
    for (var i = 0; i < 3; i++) {
      await tester.tapAt(tester.getCenter(_full));
    }
    await tester.pump();
    expect(tesbihat.saves.length, saves); // a finished tesbihat counts nothing
    expect(haptics.roundsCompleted, 2);

    await tester.tap(_close);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tesbihat-finished')), findsOneWidget);
  });

  testWidgets('full screen undo', (tester) async {
    _phone(tester);
    final store = _sabah(count: 2, total: 40);
    await _start(tester, store: store);
    await _openFullScreen(tester);

    await tester.tap(_undo);
    await tester.pump();
    expect(_text(tester, _count), '1');
    expect(store.stateOf(1).total, 39);
    await tester.tap(_undo);
    await tester.pump();
    expect(_text(tester, _count), '0');
    // BR-5: disabled at 0, nothing changes.
    expect(tester.widget<IconButton>(_undo).onPressed, isNull);
    await tester.tap(_undo, warnIfMissed: false);
    await tester.pump();
    expect(_text(tester, _count), '0');
    expect(store.stateOf(1).total, 38);
    expect(store.stateOf(1).rounds, 2);

    // The tesbihat's undo.
    await tester.pumpWidget(const SizedBox());
    final tesbihat = FakeTesbihatRepository(
      stored: TesbihatState(count: const DhikrCount(5), selected: true),
    );
    await _start(tester, tesbihat: tesbihat);
    await _openFullScreen(tester);
    await tester.tap(_undo);
    await tester.pump();
    expect(_text(tester, _count), '4');
    expect(tesbihat.stored.count.value, 4);
  });

  testWidgets('undo and close do not count', (tester) async {
    _phone(tester);
    final store = _sabah(count: 3, total: 3, target: null);
    await _start(tester, store: store);
    await _openFullScreen(tester);

    await tester.tap(_undo);
    await tester.pump();
    expect(_text(tester, _count), '2'); // undone, not counted
    await tester.tap(_close);
    await tester.pumpAndSettle();
    expect(_full, findsNothing);
    expect(store.stateOf(1).count.value, 2);
    expect(store.stateOf(1).total, 2);
  });

  testWidgets('no reset, target or picker in full screen', (tester) async {
    _phone(tester);
    await _start(tester);
    await _openFullScreen(tester);

    for (final key in [
      'counter-reset',
      'counter-target',
      'dhikr-picker-button',
      'counter-tap-area',
      'open-menu',
    ]) {
      expect(find.byKey(Key(key)), findsNothing, reason: key);
    }
    expect(find.byIcon(Icons.restart_alt), findsNothing);
    expect(find.byType(IconButton), findsNWidgets(2)); // "Geri al", "Kapat"
  });

  testWidgets('close and back leave full screen with the same values', (
    tester,
  ) async {
    _phone(tester);
    final bars = FakeSystemBars();
    await _start(tester, bars: bars, store: _sabah(count: 0, total: 0));

    await _openFullScreen(tester);
    await tester.tapAt(tester.getCenter(_full));
    await tester.tapAt(tester.getCenter(_full));
    await tester.pump();
    await tester.tap(_close);
    await tester.pumpAndSettle();
    expect(_full, findsNothing);
    expect(bars.hidden, isFalse);
    expect(_text(tester, find.byKey(const Key('counter-value'))), '2');

    await _openFullScreen(tester);
    expect(bars.hidden, isTrue);
    await tester.tapAt(tester.getCenter(_full));
    await tester.pump();
    await tester.binding.handlePopRoute(); // the system back gesture
    await tester.pumpAndSettle();
    expect(_full, findsNothing);
    expect(bars.hidden, isFalse);
    expect(_text(tester, find.byKey(const Key('counter-value'))), '3');
    // Only the full screen closed: no exit warning (spec 0005).
    expect(find.byKey(const Key('exit-warning')), findsNothing);
  });

  testWidgets('full screen hides the bars again on resume', (tester) async {
    _phone(tester);
    final bars = FakeSystemBars();
    await _start(tester, bars: bars);
    await _openFullScreen(tester);
    expect(bars.hides, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(_full, findsOneWidget);
    expect(bars.hides, 2);
    expect(bars.hidden, isTrue);
  });

  testWidgets('full screen semantics, targets and contrast', (tester) async {
    _phone(tester);
    final semantics = tester.ensureSemantics();
    final store = _sabah(count: 3, total: 3);
    await _start(tester, store: store);

    expect(tester.getSemantics(_open).label, contains('Tam ekran'));
    expect(tester.getSize(_open).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(_open).width, greaterThanOrEqualTo(48));

    await _openFullScreen(tester);
    expect(find.bySemanticsLabel('Geri al'), findsOneWidget);
    expect(find.bySemanticsLabel('Kapat'), findsOneWidget);
    for (final button in [_undo, _close]) {
      expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    }

    // The area reads like the normal count button and counts when activated.
    // It covers the whole screen (Req. 2).
    expect(tester.getSize(_area), tester.getSize(_full));
    final area = find.bySemanticsLabel('Sayım 3. Saymak için dokunun.');
    expect(area, findsOneWidget);
    tester.semantics.tap(
      find.semantics.byLabel('Sayım 3. Saymak için dokunun.'),
    );
    await tester.pump();
    expect(_text(tester, _count), '4');
    expect(
      find.bySemanticsLabel('Sayım 4. Saymak için dokunun.'),
      findsOneWidget,
    );
    semantics.dispose();

    for (final choice in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        store: _sabah(),
        settings: AppSettings(vibration: true, theme: choice),
      );
      // The button's label on the page.
      final pageBg = Theme.of(tester.element(_open)).colorScheme.surface;
      final label = tester
          .renderObject<RenderParagraph>(find.text('Tam ekran'))
          .text
          .style!
          .color!;
      expect(_contrast(label, pageBg), greaterThanOrEqualTo(4.5));

      await _openFullScreen(tester);
      final bg = tester.widget<Scaffold>(_full).backgroundColor!;
      for (final key in [
        'full-screen-name',
        'full-screen-count',
        'full-screen-target',
        'full-screen-total',
      ]) {
        final color = tester
            .renderObject<RenderParagraph>(find.byKey(Key(key)))
            .text
            .style!
            .color!;
        expect(
          _contrast(color, bg),
          greaterThanOrEqualTo(4.5),
          reason: '$choice $key',
        );
      }
      for (final button in [_undo, _close]) {
        final color = tester.widget<IconButton>(button).color!;
        expect(_contrast(color, bg), greaterThanOrEqualTo(4.5));
      }
    }
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}
