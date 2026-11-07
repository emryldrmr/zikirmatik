import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/hand_layout.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';

// Spec 0011 — Görünüm seçenekleri on Zikirlerim (AC-2…AC-8, AC-10).

final _open = find.byKey(const Key('full-screen-open'));
final _full = find.byKey(const Key('full-screen'));
final _lcd = find.byKey(const Key('counter-lcd'));
final _value = find.byKey(const Key('counter-value'));
final _bigCount = find.byKey(const Key('full-screen-count'));

final _device = find.byKey(const Key('counter-device'));
final _undo = find.byKey(const Key('full-screen-undo'));
final _close = find.byKey(const Key('full-screen-close'));

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

/// Today's margin around Zikirlerim's view (plan 0011, R3).
const _margin = 24.0;

/// The device's own parts, relative to its top left: must not change with
/// the hand (AC-5).
Map<String, Rect> _layout(WidgetTester tester, bool tesbihat) {
  final origin = tester.getTopLeft(_device);
  return {
    for (final key in [
      'counter-lcd',
      'counter-tap-area',
      if (tesbihat) ...[
        'tesbihat-text',
        'tesbihat-step',
        'tesbihat-undo',
        'tesbihat-reset',
      ] else ...[
        'counter-target',
        'counter-total',
        'counter-undo',
        'counter-reset',
      ],
    ])
      key: _rounded(_rect(tester, find.byKey(Key(key))).shift(-origin)),
  };
}

/// Every combination of the two options.
final _combinations = [
  for (final large in [false, true])
    for (final hand in HandLayout.values) (large, hand),
];

AppSettings _settings({
  bool large = false,
  HandLayout hand = HandLayout.center,
}) => AppSettings.defaults.copyWith(largeCount: large, handLayout: hand);

CounterState _state({int count = 7, int? target = 33}) => CounterState(
  count: DhikrCount(count),
  rounds: 2,
  total: 73 + count,
  target: target == null ? null : Target.of(target),
);

FakeDhikrStore _sabah({int count = 7, int? target = 33}) =>
    FakeDhikrStore([('Sabah', _state(count: count, target: target))]);

/// A phone held upright, or sideways.
const _upright = Size(400, 800);
const _sideways = Size(852, 393);

void _screen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _start(
  WidgetTester tester, {
  AppSettings? settings,
  FakeDhikrStore? store,
  FakeTesbihatRepository? tesbihat,
  FakeHaptics? haptics,
  FakeSettingsRepository? settingsStore,
}) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    testApp(
      tester,
      store: store ?? _sabah(),
      tesbihat: tesbihat,
      haptics: haptics,
      settings:
          settingsStore ??
          FakeSettingsRepository(stored: settings ?? _settings()),
    ),
  );
  await tester.pumpAndSettle();
}

FakeTesbihatRepository _tesbihat({int step = 0, int count = 5}) =>
    FakeTesbihatRepository(
      stored: TesbihatState(
        step: step,
        count: DhikrCount(count),
        selected: true,
      ),
    );

Future<void> _openFullScreen(WidgetTester tester) async {
  await tester.ensureVisible(_open);
  await tester.pumpAndSettle();
  await tester.tap(_open);
  await tester.pumpAndSettle();
}

/// Where a widget is painted, its transforms (shrinking to fit) included.
Rect _rect(WidgetTester tester, Finder f) =>
    Rect.fromPoints(tester.getTopLeft(f), tester.getBottomRight(f));

/// The painted heights of the texts that must not change with the options.
Map<String, double> _otherTexts(WidgetTester tester, List<String> keys) => {
  for (final key in keys) key: _rect(tester, find.byKey(Key(key))).height,
};

void _expectWhole(WidgetTester tester, Finder count, Rect within, String why) {
  final text = tester.widget<Text>(count);
  expect(text.maxLines, 1, reason: why);
  expect(text.overflow, isNull, reason: why);
  expect(text.data, isNot(contains('…')), reason: why);
  final rect = _rect(tester, count);
  expect(rect.height, greaterThan(0), reason: why);
  expect(rect.left, greaterThanOrEqualTo(within.left - 0.5), reason: why);
  expect(rect.right, lessThanOrEqualTo(within.right + 0.5), reason: why);
  expect(rect.top, greaterThanOrEqualTo(within.top - 0.5), reason: why);
  expect(rect.bottom, lessThanOrEqualTo(within.bottom + 0.5), reason: why);
  // One line: the painted text is no taller than its own single line.
  final line = MediaQuery.textScalerOf(
    tester.element(count),
  ).scale(text.style!.fontSize!);
  expect(tester.getSize(count).height, lessThan(line * 1.6), reason: why);
}

void main() {
  // AC-2: with the defaults, today's sizes.
  testWidgets('defaults keep the count size', (tester) async {
    _screen(tester, _upright);
    await _start(tester);
    final theme = Theme.of(tester.element(_value));
    expect(
      tester.widget<Text>(_value).style!.fontSize,
      theme.textTheme.displayLarge!.fontSize,
    );
    // Not shrunk either: painted at its own size.
    expect(_rect(tester, _value).size, tester.getSize(_value));

    await _openFullScreen(tester);
    expect(tester.widget<Text>(_bigCount).style!.fontSize, 120);
    expect(_rect(tester, _bigCount).size, tester.getSize(_bigCount));

    await _start(tester, tesbihat: _tesbihat());
    expect(
      tester.widget<Text>(_value).style!.fontSize,
      theme.textTheme.displayLarge!.fontSize,
    );
    await _openFullScreen(tester);
    expect(tester.widget<Text>(_bigCount).style!.fontSize, 120);
  });

  // AC-3.
  testWidgets('large digits grow the counts one and a half times', (
    tester,
  ) async {
    _screen(tester, _upright);
    for (final tesbihat in [null, _tesbihat]) {
      final why = tesbihat == null ? 'dhikr' : 'tesbihat';
      await _start(tester, tesbihat: tesbihat?.call());
      final lcd = _rect(tester, _value).height;
      await _openFullScreen(tester);
      final full = _rect(tester, _bigCount).height;

      await _start(
        tester,
        settings: _settings(large: true),
        tesbihat: tesbihat?.call(),
      );
      expect(
        _rect(tester, _value).height,
        greaterThanOrEqualTo(lcd * 1.5 - 0.5),
        reason: '$why LCD',
      );
      await _openFullScreen(tester);
      expect(
        _rect(tester, _bigCount).height,
        greaterThanOrEqualTo(full * 1.5 - 0.5),
        reason: '$why full screen',
      );
    }
  });

  // AC-3.
  testWidgets('large digits leave the other texts as they are', (tester) async {
    _screen(tester, _upright);
    const dhikr = ['dhikr-name', 'counter-target', 'counter-total'];
    const dhikrFull = [
      'full-screen-name',
      'full-screen-target',
      'full-screen-total',
    ];
    const tesbihat = [
      'tesbihat-name',
      'tesbihat-text',
      'tesbihat-step',
      'tesbihat-target',
      'tesbihat-completions',
    ];
    const tesbihatFull = [
      'full-screen-step-text',
      'full-screen-step',
      'full-screen-target',
    ];
    final before = <String, double>{};
    final after = <String, double>{};
    for (final (large, into) in [(false, before), (true, after)]) {
      await _start(tester, settings: _settings(large: large));
      into.addAll(_otherTexts(tester, dhikr));
      await _openFullScreen(tester);
      into.addAll(_otherTexts(tester, dhikrFull));
      await _start(
        tester,
        settings: _settings(large: large),
        tesbihat: _tesbihat(),
      );
      into.addAll(_otherTexts(tester, tesbihat));
      await _openFullScreen(tester);
      into.addAll({
        for (final MapEntry(:key, :value) in _otherTexts(
          tester,
          tesbihatFull,
        ).entries)
          'tesbihat $key': value,
      });
    }
    expect(after, before);
  });

  // AC-2: with the defaults the device is in the middle, as today.
  testWidgets('defaults keep the device centred', (tester) async {
    for (final size in const [_upright, _sideways]) {
      for (final tesbihat in [null, _tesbihat]) {
        final why = '$size ${tesbihat == null ? 'dhikr' : 'tesbihat'}';
        _screen(tester, size);
        await _start(tester, tesbihat: tesbihat?.call());
        expect(
          tester.getCenter(_device).dx,
          moreOrLessEquals(size.width / 2, epsilon: 0.5),
          reason: why,
        );
      }
    }
  });

  // AC-5.
  testWidgets('right and left hand move the device to the edge', (
    tester,
  ) async {
    for (final size in const [_upright, _sideways]) {
      for (final tesbihat in [null, _tesbihat]) {
        final why = '$size ${tesbihat == null ? 'dhikr' : 'tesbihat'}';
        _screen(tester, size);
        await _start(tester, tesbihat: tesbihat?.call());
        final centre = _layout(tester, tesbihat != null);

        await _start(
          tester,
          settings: _settings(hand: HandLayout.right),
          tesbihat: tesbihat?.call(),
        );
        final right = _rect(tester, _device);
        expect(
          right.right,
          moreOrLessEquals(size.width - _margin, epsilon: 0.5),
          reason: why,
        );
        expect(_layout(tester, tesbihat != null), centre, reason: why);

        await _start(
          tester,
          settings: _settings(hand: HandLayout.left),
          tesbihat: tesbihat?.call(),
        );
        final left = _rect(tester, _device);
        expect(left.left, moreOrLessEquals(_margin, epsilon: 0.5), reason: why);
        expect(_layout(tester, tesbihat != null), centre, reason: why);
        // The name and "Tam ekran" go with it, as a whole.
        expect(
          tester.getCenter(_open).dx,
          moreOrLessEquals(left.center.dx, epsilon: 0.5),
          reason: why,
        );
      }
    }
  });

  // AC-5: never off the screen, upright or sideways, with large digits and
  // the phone's large text too.
  testWidgets('hand layout keeps the device inside sideways', (tester) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final size in const [_upright, _sideways]) {
      for (final scale in const [1.0, 2.0]) {
        for (final (large, hand) in _combinations) {
          final why = '$size ×$scale large:$large $hand';
          _screen(tester, size);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          await _start(
            tester,
            settings: _settings(large: large, hand: hand),
          );
          final device = _rect(tester, _device);
          expect(device.left, greaterThanOrEqualTo(0), reason: why);
          expect(device.right, lessThanOrEqualTo(size.width), reason: why);
          expect(tester.takeException(), isNull, reason: why);
        }
      }
    }
  });

  // AC-5: no room to move, the device stays in the middle.
  testWidgets('a narrow screen keeps the device centred', (tester) async {
    const narrow = Size(360, 760);
    for (final hand in HandLayout.values) {
      _screen(tester, narrow);
      await _start(tester, settings: _settings(hand: hand));
      expect(
        tester.getCenter(_device).dx,
        moreOrLessEquals(narrow.width / 2, epsilon: 0.5),
        reason: '$hand',
      );
    }
  });

  // AC-2: with the defaults, spec 0010's corners.
  testWidgets('defaults keep the full screen corners', (tester) async {
    _screen(tester, _upright);
    for (final tesbihat in [null, _tesbihat]) {
      await _start(tester, tesbihat: tesbihat?.call());
      await _openFullScreen(tester);
      expect(tester.getTopLeft(_undo), const Offset(8, 8));
      expect(tester.getTopRight(_close), Offset(_upright.width - 8, 8));
    }
  });

  // AC-6.
  testWidgets('full screen corners follow the hand', (tester) async {
    for (final size in const [_upright, _sideways]) {
      for (final tesbihat in [null, _tesbihat]) {
        final why = '$size ${tesbihat == null ? 'dhikr' : 'tesbihat'}';
        _screen(tester, size);
        final topRight = Offset(size.width - 8, 8);
        final bottomRight = Offset(size.width - 8, size.height - 8);
        final bottomLeft = Offset(8, size.height - 8);

        await _start(tester, tesbihat: tesbihat?.call());
        await _openFullScreen(tester);
        expect(tester.getTopLeft(_undo), const Offset(8, 8), reason: why);
        expect(tester.getTopRight(_close), topRight, reason: why);

        await _start(
          tester,
          settings: _settings(hand: HandLayout.right),
          tesbihat: tesbihat?.call(),
        );
        await _openFullScreen(tester);
        expect(tester.getBottomRight(_undo), bottomRight, reason: why);
        expect(tester.getTopLeft(_close), const Offset(8, 8), reason: why);

        await _start(
          tester,
          settings: _settings(hand: HandLayout.left),
          tesbihat: tesbihat?.call(),
        );
        await _openFullScreen(tester);
        expect(tester.getBottomLeft(_undo), bottomLeft, reason: why);
        expect(tester.getTopRight(_close), topRight, reason: why);
      }
    }
  });

  // AC-6: the information never under a button, also small, sideways, with
  // large digits and the phone's large text.
  testWidgets('full screen info never meets the buttons', (tester) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    const dhikrInfo = [
      'full-screen-name',
      'full-screen-count',
      'full-screen-target',
      'full-screen-total',
    ];
    const tesbihatInfo = [
      'full-screen-step-text',
      'full-screen-step',
      'full-screen-count',
      'full-screen-target',
    ];
    for (final size in const [_upright, _sideways, Size(320, 480)]) {
      for (final scale in const [1.0, 2.0]) {
        for (final (large, hand) in _combinations) {
          for (final tesbihat in [false, true]) {
            final why =
                '$size ×$scale large:$large $hand '
                '${tesbihat ? 'tesbihat' : 'dhikr'}';
            _screen(tester, size);
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            await _start(
              tester,
              settings: _settings(large: large, hand: hand),
              tesbihat: tesbihat ? _tesbihat() : null,
            );
            await _openFullScreen(tester);
            final buttons = [_rect(tester, _undo), _rect(tester, _close)];
            // Plan 0011, A-2: the count never gives way to nothing.
            expect(
              _rect(tester, _bigCount).height,
              greaterThan(0),
              reason: why,
            );
            for (final key in tesbihat ? tesbihatInfo : dhikrInfo) {
              final info = _rect(tester, find.byKey(Key(key)));
              for (final button in buttons) {
                expect(
                  info.overlaps(button),
                  isFalse,
                  reason: '$why $key $info $button',
                );
              }
            }
            expect(tester.takeException(), isNull, reason: why);
          }
        }
      }
    }
  });

  // AC-6: a bottom "Geri al" stays out of the system's bottom gesture area.
  testWidgets('bottom undo sits above the gesture area', (tester) async {
    for (final size in const [_upright, _sideways]) {
      for (final hand in [HandLayout.right, HandLayout.left]) {
        final why = '$size $hand';
        _screen(tester, size);
        tester.view.systemGestureInsets = const FakeViewPadding(bottom: 48);
        await _start(tester, settings: _settings(hand: hand));
        await _openFullScreen(tester);
        final undo = _rect(tester, _undo);
        expect(undo.bottom, size.height - 48 - 8, reason: why);
        for (final key in [
          'full-screen-name',
          'full-screen-count',
          'full-screen-target',
          'full-screen-total',
        ]) {
          expect(
            _rect(tester, find.byKey(Key(key))).overlaps(undo),
            isFalse,
            reason: '$why $key',
          );
        }
      }
    }
  });

  // AC-6: pulling up from the bottom edge — through "Geri al" too — neither
  // counts nor undoes.
  testWidgets('a pull from the bottom neither counts nor undoes', (
    tester,
  ) async {
    _screen(tester, _upright);
    for (final hand in HandLayout.values) {
      final store = _sabah();
      await _start(
        tester,
        settings: _settings(hand: hand),
        store: store,
      );
      await _openFullScreen(tester);
      final undo = tester.getCenter(_undo);
      for (final start in [
        Offset(undo.dx, _upright.height - 2), // the very edge, below it
        if (hand != HandLayout.center) undo, // on "Geri al" itself
        Offset(_upright.width / 2, _upright.height - 2),
      ]) {
        await tester.dragFrom(start, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(_text(tester, _bigCount), '7', reason: '$hand $start');
      }
      expect(store.stateOf(1), _state(), reason: '$hand');
    }
  });

  // AC-6: a touch on a button never counts; everywhere else counts, the
  // corners and the spots next to the buttons included.
  testWidgets('buttons do not count, the rest counts in every layout', (
    tester,
  ) async {
    for (final size in const [_upright, _sideways]) {
      for (final hand in HandLayout.values) {
        final why = '$size $hand';
        _screen(tester, size);
        await _start(tester, settings: _settings(hand: hand));
        await _openFullScreen(tester);
        var expected = 7;

        await tester.tap(_undo);
        await tester.pumpAndSettle();
        expected -= 1; // undone, not counted
        expect(_text(tester, _bigCount), '$expected', reason: '$why undo');

        final undo = _rect(tester, _undo);
        final close = _rect(tester, _close);
        final points =
            [
              Offset(size.width / 2, size.height / 2),
              const Offset(4, 4),
              Offset(size.width - 4, 4),
              Offset(4, size.height - 4),
              Offset(size.width - 4, size.height - 4),
              // Next to the buttons.
              for (final button in [undo, close]) ...[
                button.centerLeft.translate(-8, 0),
                button.centerRight.translate(8, 0),
                button.topCenter.translate(0, -6),
                button.bottomCenter.translate(0, 8),
              ],
            ].where(
              (p) =>
                  !undo.inflate(1).contains(p) &&
                  !close.inflate(1).contains(p) &&
                  p.dx >= 0 &&
                  p.dy >= 0 &&
                  p.dx < size.width &&
                  p.dy < size.height,
            );
        for (final p in points) {
          await tester.tapAt(p);
          await tester.pump();
          expected += 1;
          expect(_text(tester, _bigCount), '$expected', reason: '$why $p');
        }

        await tester.tap(_close);
        await tester.pumpAndSettle();
        expect(_full, findsNothing, reason: why);
        expect(tester.widget<Text>(_value).data, '$expected', reason: why);
      }
    }
  });

  // AC-7: the options change only the look.
  testWidgets('counting works the same in every combination', (tester) async {
    _screen(tester, _upright);
    for (final (large, hand) in _combinations) {
      final why = 'large:$large $hand';
      final settings = _settings(
        large: large,
        hand: hand,
      ).copyWith(tapVibration: true);
      final haptics = FakeHaptics();
      final store = _sabah(count: 31);
      await _start(tester, settings: settings, store: store, haptics: haptics);

      // Two taps complete the round.
      final button = find.byKey(const Key('counter-tap-area'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(
        store.stateOf(1),
        _round(count: 0, rounds: 3, total: 106),
        reason: why,
      );
      expect(haptics.roundsCompleted, 1, reason: why);
      // The tap that completes the round gives the round vibration instead
      // (spec 0009).
      expect(haptics.taps, 1, reason: why);

      // Count, undo, reset (asks, keeps total and target).
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('counter-undo')));
      await tester.pumpAndSettle();
      expect(
        store.stateOf(1),
        _round(count: 0, rounds: 3, total: 106),
        reason: why,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('counter-reset')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-ok')));
      await tester.pumpAndSettle();
      expect(
        store.stateOf(1),
        _round(count: 0, rounds: 0, total: 107),
        reason: why,
      );

      // Full screen counts and undoes the same counter.
      await _openFullScreen(tester);
      await tester.tapAt(tester.getCenter(_full));
      await tester.pump();
      await tester.tapAt(tester.getCenter(_full));
      await tester.pump();
      await tester.tap(_undo);
      await tester.pumpAndSettle();
      expect(
        store.stateOf(1),
        _round(count: 1, rounds: 0, total: 108),
        reason: why,
      );
      await tester.tap(_close);
      await tester.pumpAndSettle();

      // A "restart" keeps it all.
      await _start(tester, settings: settings, store: store);
      expect(_text(tester, _value), '1', reason: why);
      expect(
        find.descendant(
          of: find.byKey(const Key('counter-target')),
          matching: find.text('Hedef 33 · Tur 0'),
        ),
        findsOneWidget,
        reason: why,
      );
      expect(
        _text(tester, find.byKey(const Key('counter-total'))),
        'Toplam 108',
        reason: why,
      );

      // The tesbihat moves on to its next step at the target.
      final tesbihat = _tesbihat(count: 32);
      final steps = FakeHaptics();
      await _start(
        tester,
        settings: settings,
        tesbihat: tesbihat,
        haptics: steps,
      );
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(tesbihat.stored.step, 1, reason: why);
      expect(tesbihat.stored.count.value, 0, reason: why);
      expect(
        _text(tester, find.byKey(const Key('tesbihat-step'))),
        'Adım 2/3',
        reason: why,
      );
      expect(steps.roundsCompleted, 1, reason: why);
    }
  });

  // AC-10: what a screen reader hears, and in which order, does not depend
  // on the options.
  testWidgets('screen reader labels do not depend on the options', (
    tester,
  ) async {
    _screen(tester, _upright);
    final semantics = tester.ensureSemantics();
    final heard = <(bool, HandLayout), List<List<String>>>{};
    for (final (large, hand) in _combinations) {
      final screens = <List<String>>[];
      for (final tesbihat in [false, true]) {
        await _start(
          tester,
          settings: _settings(large: large, hand: hand),
          tesbihat: tesbihat ? _tesbihat() : null,
        );
        screens.add(_heard(tester));
        await _openFullScreen(tester);
        screens.add(_heard(tester));
      }
      heard[(large, hand)] = screens;
    }
    final today = heard[(false, HandLayout.center)]!;
    expect(today.every((s) => s.isNotEmpty), isTrue);
    expect(today[1], containsAllInOrder(['Geri al', 'Kapat']));
    for (final MapEntry(:key, :value) in heard.entries) {
      expect(value, today, reason: '$key');
    }
    semantics.dispose();
  });

  // AC-4: the count is whole in every combination, upright and sideways,
  // with the phone's large text.
  testWidgets('the count is never cut', (tester) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final count in const [0, 99999, 1000000]) {
      for (final size in const [_upright, _sideways]) {
        for (final scale in const [1.0, 2.0]) {
          for (final (large, hand) in _combinations) {
            final why = '$count $size ×$scale large:$large $hand';
            _screen(tester, size);
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            await _start(
              tester,
              settings: _settings(large: large, hand: hand),
              store: _sabah(count: count, target: null),
            );
            await tester.ensureVisible(_lcd);
            await tester.pumpAndSettle();
            expect(tester.widget<Text>(_value).data, '$count', reason: why);
            _expectWhole(tester, _value, _rect(tester, _lcd), why);

            await _openFullScreen(tester);
            expect(tester.widget<Text>(_bigCount).data, '$count', reason: why);
            _expectWhole(tester, _bigCount, _rect(tester, _full), why);
            expect(tester.takeException(), isNull, reason: why);
          }
        }
      }
    }
  });
}

/// Positions to 1/100 px, so a sub-pixel difference in where a row of
/// buttons is spread out does not count as a changed layout.
Rect _rounded(Rect r) {
  double round(double v) => (v * 100).roundToDouble() / 100;
  return Rect.fromLTRB(
    round(r.left),
    round(r.top),
    round(r.right),
    round(r.bottom),
  );
}

CounterState _round({
  required int count,
  required int rounds,
  required int total,
}) => CounterState(
  count: DhikrCount(count),
  rounds: rounds,
  total: total,
  target: Target.of(33),
);

/// Every label a screen reader reads on the screen, in its reading order.
List<String> _heard(WidgetTester tester) {
  final root = tester
      .binding
      .renderViews
      .first
      .owner!
      .semanticsOwner!
      .rootSemanticsNode!;
  final labels = <String>[];
  void visit(SemanticsNode node) {
    if (node.label.isNotEmpty) labels.add(node.label);
    for (final child in node.debugListChildrenInOrder(
      DebugSemanticsDumpOrder.traversalOrder,
    )) {
      visit(child);
    }
  }

  visit(root);
  return labels;
}
