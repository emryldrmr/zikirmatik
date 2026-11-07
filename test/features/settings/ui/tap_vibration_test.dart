import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';
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

  // --- Ayarlar ekranı (AC-1, AC-6, AC-9) ---

  final toggle = find.byKey(const Key('settings-tap-vibration'));

  Future<void> goToSettings(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('open-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-settings')));
    await tester.pumpAndSettle();
  }

  testWidgets('settings shows tap vibration off by default', (tester) async {
    await _start(tester, settings: AppSettings.defaults);
    await goToSettings(tester);

    expect(find.text('Her sayımda titreşim'), findsOneWidget);
    expect(find.text('Her dokunuşta kısa titreşir'), findsOneWidget);
    expect(find.text('Tur tamamlanınca titreşir'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    // Right below "Titreşim".
    expect(
      tester.getTopLeft(toggle).dy,
      greaterThan(
        tester.getTopLeft(find.byKey(const Key('settings-vibration'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(toggle).dy,
      lessThan(tester.getTopLeft(find.text('Tema')).dy),
    );
  });

  testWidgets('turning it on applies at once and is kept after restart', (
    tester,
  ) async {
    final haptics = FakeHaptics();
    final settings = FakeSettingsRepository();
    await tester.pumpWidget(
      testApp(tester, settings: settings, haptics: haptics),
    );
    await tester.pumpAndSettle();
    await goToSettings(tester);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(settings.stored.tapVibration, isTrue);
    expect(settings.stored.vibration, isTrue); // the other setting unchanged

    await tester.tap(find.byKey(const Key('open-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-myDhikrs')));
    await tester.pumpAndSettle();
    await _taps(tester, 1);
    expect(haptics.taps, 1);

    // "Restart" with the same store.
    await tester.pumpWidget(const SizedBox());
    final after = FakeHaptics();
    await tester.pumpWidget(
      testApp(tester, settings: settings, haptics: after),
    );
    await tester.pumpAndSettle();
    await _taps(tester, 1);
    expect(after.taps, 1);
    await goToSettings(tester);
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
  });

  testWidgets('unreadable settings show tap vibration off', (tester) async {
    await _start(tester, failLoad: true);
    await goToSettings(tester);
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
  });

  testWidgets('tap vibration semantics, target and contrast', (tester) async {
    final semantics = tester.ensureSemantics();
    await _start(tester, settings: AppSettings.defaults);
    await goToSettings(tester);

    final node = tester.getSemantics(toggle);
    expect(node.label, startsWith('Her sayımda titreşim'));
    expect(node, isSemantics(hasToggledState: true, isToggled: false));
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(toggle),
      isSemantics(hasToggledState: true, isToggled: true),
    );
    final size = tester.getSize(toggle);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    semantics.dispose();

    for (final choice in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        settings: AppSettings(vibration: true, theme: choice),
      );
      await goToSettings(tester);
      final bg = Theme.of(tester.element(toggle)).colorScheme.surface;
      for (final text in [
        'Her sayımda titreşim',
        'Her dokunuşta kısa titreşir',
      ]) {
        // The colour the text is actually painted with.
        final color = tester
            .renderObject<RenderParagraph>(find.text(text))
            .text
            .style!
            .color!;
        expect(
          _contrast(color, bg),
          greaterThanOrEqualTo(4.5),
          reason: '$choice $text',
        );
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
