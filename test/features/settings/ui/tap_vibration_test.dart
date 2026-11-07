import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';

// Spec 0009 — Her sayımda titreşim.

final _button = find.byKey(const Key('counter-tap-area'));
final _value = find.byKey(const Key('counter-value'));

const _tapOn = AppSettings(
  vibration: true,
  theme: ThemeChoice.system,
  tapVibration: true,
);

CounterState _state({int count = 0, int total = 0, int? target}) =>
    CounterState(
      count: DhikrCount(count),
      rounds: 0,
      total: total,
      target: target == null ? null : Target.of(target),
    );

Future<void> _start(
  WidgetTester tester, {
  AppSettings settings = _tapOn,
  bool failLoad = false,
  CounterRepository? repo,
  FakeTesbihatRepository? tesbihat,
  FakeHaptics? haptics,
}) async {
  await tester.pumpWidget(
    testApp(
      tester,
      repo: repo,
      tesbihat: tesbihat,
      haptics: haptics,
      settings: FakeSettingsRepository(stored: settings, failLoad: failLoad),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _taps(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.tap(_button);
    await tester.pump();
  }
}

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

void main() {
  testWidgets('tap vibration on vibrates every counted tap', (tester) async {
    final haptics = FakeHaptics();
    final repo = FakeCounterRepository();
    await _start(tester, repo: repo, haptics: haptics);

    await _taps(tester, 3);
    expect(haptics.taps, 3);
    expect(haptics.roundsCompleted, 0);
    expect(_text(tester, _value), '3');
    expect(repo.stored.total, 3);
  });

  testWidgets('tap vibration off never tap-vibrates', (tester) async {
    final haptics = FakeHaptics();
    await _start(
      tester,
      settings: AppSettings.defaults,
      repo: FakeCounterRepository(
        state: _state(count: 31, total: 31, target: 33),
      ),
      haptics: haptics,
    );

    await _taps(tester, 3); // 32, round at 33, then 1
    expect(haptics.taps, 0);
    expect(haptics.roundsCompleted, 1); // spec 0004 unchanged
    expect(_text(tester, _value), '1');
  });

  testWidgets('a round-completing tap vibrates once', (tester) async {
    final haptics = FakeHaptics();
    await _start(
      tester,
      repo: FakeCounterRepository(
        state: _state(count: 32, total: 32, target: 33),
      ),
      haptics: haptics,
    );

    await _taps(tester, 1);
    expect(haptics.roundsCompleted, 1);
    expect(haptics.taps, 0);
    await _taps(tester, 1);
    expect(haptics.roundsCompleted, 1);
    expect(haptics.taps, 1);
  });

  testWidgets('round off and tap on gives a short vibration', (tester) async {
    final haptics = FakeHaptics();
    await _start(
      tester,
      settings: _tapOn.copyWith(vibration: false),
      repo: FakeCounterRepository(
        state: _state(count: 32, total: 32, target: 33),
      ),
      haptics: haptics,
    );

    await _taps(tester, 1);
    expect(haptics.roundsCompleted, 0);
    expect(haptics.taps, 1);
    expect(_text(tester, _value), '0');
  });

  testWidgets('tesbihat taps vibrate and a finished tesbihat does not', (
    tester,
  ) async {
    final haptics = FakeHaptics();
    final tesbihat = FakeTesbihatRepository(
      stored: const TesbihatState(
        step: 2,
        count: DhikrCount(31),
      ).selecting(true),
    );
    await _start(tester, tesbihat: tesbihat, haptics: haptics);

    await _taps(tester, 1); // 32: short
    expect(haptics.taps, 1);
    await _taps(tester, 1); // 33: finishes — the round vibration only
    expect(haptics.taps, 1);
    expect(haptics.roundsCompleted, 1);
    expect(tesbihat.stored.finished, isTrue);

    await _taps(tester, 3); // a finished tesbihat counts nothing
    expect(haptics.taps, 1);
    expect(haptics.roundsCompleted, 1);
  });

  testWidgets('a step change with round vibration off is a short one', (
    tester,
  ) async {
    final haptics = FakeHaptics();
    await _start(
      tester,
      settings: _tapOn.copyWith(vibration: false),
      tesbihat: FakeTesbihatRepository(
        stored: const TesbihatState(count: DhikrCount(32)).selecting(true),
      ),
      haptics: haptics,
    );

    await _taps(tester, 1);
    expect(haptics.roundsCompleted, 0);
    expect(haptics.taps, 1);
  });

  testWidgets('undo and reset never vibrate', (tester) async {
    final haptics = FakeHaptics();
    final repo = FakeCounterRepository(state: _state(count: 5, total: 5));
    await _start(tester, repo: repo, haptics: haptics);

    await tester.tap(find.byKey(const Key('counter-undo')));
    await tester.pumpAndSettle();
    expect(_text(tester, _value), '4');
    await tester.tap(find.byKey(const Key('counter-reset')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-ok')));
    await tester.pumpAndSettle();
    expect(_text(tester, _value), '0');
    expect(haptics.taps, 0);
    expect(haptics.roundsCompleted, 0);
  });

  testWidgets('a failing tap vibration still counts', (tester) async {
    final haptics = FakeHaptics()..fail = true;
    final repo = FakeCounterRepository();
    await _start(tester, repo: repo, haptics: haptics);

    await _taps(tester, 2);
    expect(haptics.taps, 2);
    expect(_text(tester, _value), '2');
    expect(repo.stored.total, 2);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('unreadable settings mean tap vibration off', (tester) async {
    final haptics = FakeHaptics();
    await _start(tester, failLoad: true, haptics: haptics);

    await _taps(tester, 2);
    expect(haptics.taps, 0);
    expect(_text(tester, _value), '2');
  });
}
