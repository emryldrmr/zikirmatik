import 'package:flutter/material.dart';
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
