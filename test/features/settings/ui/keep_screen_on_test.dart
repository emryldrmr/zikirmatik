import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';

// Spec 0010 — Ekranı açık tut (AC-8, AC-9, AC-10).

final _toggle = find.byKey(const Key('settings-keep-screen-on'));

const _on = AppSettings(
  vibration: true,
  theme: ThemeChoice.system,
  keepScreenOn: true,
);

Future<void> _start(
  WidgetTester tester, {
  required FakeScreenAwake screen,
  AppSettings settings = _on,
  bool failLoad = false,
  FakeSettingsRepository? store,
  FakeDhikrStore? dhikrs,
}) async {
  await tester.pumpWidget(
    testApp(
      tester,
      screenAwake: screen,
      store: dhikrs,
      settings:
          store ?? FakeSettingsRepository(stored: settings, failLoad: failLoad),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _goTo(WidgetTester tester, String section) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('section-$section')));
  await tester.pumpAndSettle();
}

Future<void> _openFullScreen(WidgetTester tester) async {
  final open = find.byKey(const Key('full-screen-open'));
  await tester.ensureVisible(open);
  await tester.tap(open);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('keep screen on is off by default', (tester) async {
    final screen = FakeScreenAwake();
    await _start(tester, screen: screen, settings: AppSettings.defaults);
    expect(screen.on, isFalse);

    await _goTo(tester, 'settings');
    expect(find.text('Ekranı açık tut'), findsOneWidget);
    expect(find.text('Zikirlerim açıkken ekran kararmaz'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(_toggle).value, isFalse);
    // Right below "Her sayımda titreşim", above the theme.
    expect(
      tester.getTopLeft(_toggle).dy,
      greaterThan(
        tester.getTopLeft(find.byKey(const Key('settings-tap-vibration'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(_toggle).dy,
      lessThan(tester.getTopLeft(find.text('Tema')).dy),
    );
  });

  testWidgets('unreadable settings mean keep screen on off', (tester) async {
    final screen = FakeScreenAwake();
    await _start(tester, screen: screen, failLoad: true);
    expect(screen.calls, isEmpty);

    await _goTo(tester, 'settings');
    expect(tester.widget<SwitchListTile>(_toggle).value, isFalse);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('keep screen on holds on my dhikrs and full screen', (
    tester,
  ) async {
    final screen = FakeScreenAwake();
    await _start(tester, screen: screen);
    expect(screen.on, isTrue);

    // The side menu over Zikirlerim keeps it (G5).
    await tester.tap(find.byKey(const Key('open-menu')));
    await tester.pumpAndSettle();
    expect(screen.on, isTrue);
    await tester.tap(find.byKey(const Key('section-myDhikrs')));
    await tester.pumpAndSettle();
    expect(screen.on, isTrue);

    await _openFullScreen(tester);
    expect(find.byKey(const Key('full-screen')), findsOneWidget);
    expect(screen.on, isTrue);
    await tester.tap(find.byKey(const Key('full-screen-close')));
    await tester.pumpAndSettle();
    expect(screen.on, isTrue);
    expect(screen.calls, [true]); // asked once, never dropped
  });

  testWidgets('keep screen on holds in the empty state', (tester) async {
    final screen = FakeScreenAwake();
    await _start(tester, screen: screen, dhikrs: FakeDhikrStore([]));
    expect(find.byKey(const Key('dhikr-empty')), findsOneWidget);
    expect(screen.on, isTrue);
  });

  testWidgets('released on other sections and in background', (tester) async {
    final screen = FakeScreenAwake();
    await _start(tester, screen: screen);
    expect(screen.on, isTrue);

    for (final section in ['settings', 'suggested', 'asma']) {
      await _goTo(tester, section);
      expect(screen.on, isFalse, reason: section);
      await _goTo(tester, 'myDhikrs');
      expect(screen.on, isTrue, reason: section);
    }

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(screen.on, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(screen.on, isTrue);

    // In the background from full screen too.
    await _openFullScreen(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(screen.on, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(screen.on, isTrue);
  });

  testWidgets('never on when the setting is off', (tester) async {
    final screen = FakeScreenAwake();
    await _start(tester, screen: screen, settings: AppSettings.defaults);

    await _openFullScreen(tester);
    await tester.tap(find.byKey(const Key('full-screen-close')));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await _goTo(tester, 'settings');
    await _goTo(tester, 'myDhikrs');
    expect(screen.calls, isEmpty);
  });

  testWidgets('turning it on applies at once and is kept after restart', (
    tester,
  ) async {
    final screen = FakeScreenAwake();
    final store = FakeSettingsRepository();
    await _start(tester, screen: screen, store: store);
    expect(screen.on, isFalse);

    await _goTo(tester, 'settings');
    await tester.tap(_toggle);
    await tester.pumpAndSettle();
    expect(store.stored.keepScreenOn, isTrue);
    expect(store.stored.vibration, isTrue); // the others unchanged
    expect(store.stored.tapVibration, isFalse);
    await _goTo(tester, 'myDhikrs');
    expect(screen.on, isTrue);

    // Turning it off gives the screen back on the next visit.
    await _goTo(tester, 'settings');
    await tester.tap(_toggle);
    await tester.pumpAndSettle();
    await _goTo(tester, 'myDhikrs');
    expect(screen.on, isFalse);
    await _goTo(tester, 'settings');
    await tester.tap(_toggle);
    await tester.pumpAndSettle();

    // "Restart" with the same store.
    await tester.pumpWidget(const SizedBox());
    final after = FakeScreenAwake();
    await _start(tester, screen: after, store: store);
    expect(after.on, isTrue);
    await _goTo(tester, 'settings');
    expect(tester.widget<SwitchListTile>(_toggle).value, isTrue);
  });

  testWidgets('keep screen on semantics, target and contrast', (tester) async {
    final semantics = tester.ensureSemantics();
    await _start(
      tester,
      screen: FakeScreenAwake(),
      settings: AppSettings.defaults,
    );
    await _goTo(tester, 'settings');

    final node = tester.getSemantics(_toggle);
    expect(node.label, startsWith('Ekranı açık tut'));
    expect(node, isSemantics(hasToggledState: true, isToggled: false));
    await tester.tap(_toggle);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(_toggle),
      isSemantics(hasToggledState: true, isToggled: true),
    );
    final size = tester.getSize(_toggle);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    semantics.dispose();

    for (final choice in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        screen: FakeScreenAwake(),
        settings: AppSettings(vibration: true, theme: choice),
      );
      await _goTo(tester, 'settings');
      final bg = Theme.of(tester.element(_toggle)).colorScheme.surface;
      for (final text in [
        'Ekranı açık tut',
        'Zikirlerim açıkken ekran kararmaz',
      ]) {
        final color = tester
            .renderObject<RenderParagraph>(find.text(text))
            .text
            .style!
            .color!;
        expect(
          contrast(color, bg),
          greaterThanOrEqualTo(4.5),
          reason: '$choice $text',
        );
      }
    }
  });
}

/// WCAG contrast ratio.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}
