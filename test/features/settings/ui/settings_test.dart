import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';

// Spec 0004 — Ayarlar.

final _vibration = find.byKey(const Key('settings-vibration'));
final _device = find.byKey(const Key('counter-device'));
final _value = find.byKey(const Key('counter-value'));
final _name = find.byKey(const Key('dhikr-name'));
Finder _theme(ThemeChoice c) => find.byKey(Key('theme-${c.name}'));

Future<void> _start(
  WidgetTester tester, {
  FakeSettingsRepository? settings,
  FakeDhikrStore? store,
  CounterRepository? repo,
  FakeHaptics? haptics,
}) async {
  await tester.pumpWidget(
    testApp(
      tester,
      settings: settings,
      store: store,
      repo: repo,
      haptics: haptics,
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _goTo(WidgetTester tester, String section) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('section-$section')));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Plan 0011, A-1: the theme choices sit below the display options (spec
/// 0011), out of the test screen; scroll them into view first.
Future<void> _showThemes(WidgetTester tester) =>
    _scrollTo(tester, _theme(ThemeChoice.system), 100);

/// Plan 0011, A-1: scrolls the settings list until [f] is in view; a negative
/// [delta] scrolls back up.
Future<void> _scrollTo(WidgetTester tester, Finder f, double delta) async {
  await tester.scrollUntilVisible(
    f,
    delta,
    scrollable: find.descendant(
      of: find.byKey(const Key('settings-screen')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
}

/// The theme the visible content is drawn with.
Brightness _brightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(AppBar))).brightness;

bool _checked(WidgetTester tester, ThemeChoice c) =>
    tester
        .widget<RadioGroup<ThemeChoice>>(find.byType(RadioGroup<ThemeChoice>))
        .groupValue ==
    c;

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

/// Every colour the device paints: surfaces, the count button and its texts.
List<Color?> _deviceColors(WidgetTester tester) => [
  for (final m in tester.widgetList<Material>(
    find.descendant(of: _device, matching: find.byType(Material)),
  ))
    m.color,
  for (final c in tester.widgetList<Container>(
    find.descendant(of: _device, matching: find.byType(Container)),
  ))
    (c.decoration as BoxDecoration?)?.color,
  for (final p in tester.widgetList<RichText>(
    find.descendant(of: _device, matching: find.byType(RichText)),
  ))
    p.text.style?.color,
];

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  testWidgets('settings shows vibration and theme with defaults', (
    tester,
  ) async {
    await _start(tester);
    await _goTo(tester, 'settings');

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Ayarlar')),
      findsOneWidget,
    );
    expect(find.text('Bu bölüm yakında.'), findsNothing);
    expect(find.text('Titreşim'), findsOneWidget);
    expect(find.text('Tur tamamlanınca titreşir'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(_vibration).value, isTrue);
    await _showThemes(tester); // plan 0011, A-1
    for (final (choice, label) in [
      (ThemeChoice.light, 'Açık'),
      (ThemeChoice.dark, 'Koyu'),
      (ThemeChoice.system, 'Sistem'),
    ]) {
      expect(
        find.descendant(of: _theme(choice), matching: find.text(label)),
        findsOneWidget,
      );
      await _showThemes(tester); // plan 0011, A-1
      expect(_checked(tester, choice), choice == ThemeChoice.system);
    }
  });

  testWidgets('vibration off completes the round without vibrating', (
    tester,
  ) async {
    final haptics = FakeHaptics();
    final repo = FakeCounterRepository(
      state: _state(count: 32, total: 32, target: 33),
    );
    final settings = FakeSettingsRepository();
    await _start(tester, repo: repo, haptics: haptics, settings: settings);

    await _goTo(tester, 'settings');
    await _tap(tester, _vibration);
    expect(tester.widget<SwitchListTile>(_vibration).value, isFalse);
    expect(settings.stored.vibration, isFalse);
    await _goTo(tester, 'myDhikrs');

    await _tap(tester, find.byKey(const Key('counter-tap-area')));
    expect(haptics.roundsCompleted, 0);
    expect(repo.stored, _state(rounds: 1, total: 33, target: 33));
    expect(tester.widget<Text>(_value).data, '0');
  });

  testWidgets('vibration back on vibrates again', (tester) async {
    final haptics = FakeHaptics();
    final repo = FakeCounterRepository(
      state: _state(count: 32, total: 32, target: 33),
    );
    await _start(
      tester,
      repo: repo,
      haptics: haptics,
      settings: FakeSettingsRepository(
        stored: const AppSettings(vibration: false, theme: ThemeChoice.system),
      ),
    );

    await _goTo(tester, 'settings');
    expect(tester.widget<SwitchListTile>(_vibration).value, isFalse);
    await _tap(tester, _vibration);
    await _goTo(tester, 'myDhikrs');

    await _tap(tester, find.byKey(const Key('counter-tap-area')));
    expect(haptics.roundsCompleted, 1);
    expect(repo.stored.rounds, 1);
  });

  testWidgets('choosing dark or light applies at once', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final settings = FakeSettingsRepository();
    await _start(tester, settings: settings);
    await _goTo(tester, 'settings');
    expect(_brightness(tester), Brightness.light);

    await _showThemes(tester); // plan 0011, A-1
    await _tap(tester, _theme(ThemeChoice.dark));
    expect(_brightness(tester), Brightness.dark);
    await _showThemes(tester); // plan 0011, A-1
    expect(_checked(tester, ThemeChoice.dark), isTrue);
    expect(settings.stored.theme, ThemeChoice.dark);

    // The whole app, not only this screen.
    await _goTo(tester, 'myDhikrs');
    expect(_brightness(tester), Brightness.dark);

    await _goTo(tester, 'settings');
    await _showThemes(tester); // plan 0011, A-1
    await _tap(tester, _theme(ThemeChoice.light));
    expect(_brightness(tester), Brightness.light);
    expect(settings.stored.theme, ThemeChoice.light);
  });

  testWidgets('system follows the phone and its changes', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _start(tester); // defaults: Sistem
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(_brightness(tester), Brightness.light);
  });

  testWidgets('the device looks the same in light and dark', (tester) async {
    final settings = FakeSettingsRepository(
      stored: const AppSettings(vibration: true, theme: ThemeChoice.light),
    );
    await _start(
      tester,
      settings: settings,
      repo: FakeCounterRepository(stored: 3),
    );
    await tester.pumpAndSettle();
    final light = _deviceColors(tester);
    expect(light, isNotEmpty);

    await _goTo(tester, 'settings');
    await _showThemes(tester); // plan 0011, A-1
    await _tap(tester, _theme(ThemeChoice.dark));
    await _goTo(tester, 'myDhikrs');
    expect(_brightness(tester), Brightness.dark);
    expect(_deviceColors(tester), light);
  });

  testWidgets('restart opens in the saved theme with the saved vibration', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final settings = FakeSettingsRepository();
    await _start(tester, settings: settings);
    await _goTo(tester, 'settings');
    await _tap(tester, _vibration);
    await _showThemes(tester); // plan 0011, A-1
    await _tap(tester, _theme(ThemeChoice.dark));

    // "Restart", with the settings read slowly: a loading screen first, then
    // the content directly in the saved theme (G1).
    await tester.pumpWidget(const SizedBox());
    settings.holdLoad = Completer<void>();
    await _start(tester, settings: settings);
    expect(find.byKey(const Key('app-loading')), findsOneWidget);
    expect(_device, findsNothing);
    expect(find.byType(AppBar), findsNothing);

    settings.holdLoad!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-loading')), findsNothing);
    expect(_device, findsOneWidget);
    expect(_brightness(tester), Brightness.dark);
    await _goTo(tester, 'settings');
    expect(tester.widget<SwitchListTile>(_vibration).value, isFalse);
    await _showThemes(tester); // plan 0011, A-1
    expect(_checked(tester, ThemeChoice.dark), isTrue);
  });

  testWidgets('unreadable settings fall back to defaults silently', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final haptics = FakeHaptics();
    final repo = FakeCounterRepository(
      state: _state(count: 32, total: 32, target: 33),
    );
    await _start(
      tester,
      settings: FakeSettingsRepository(failLoad: true),
      repo: repo,
      haptics: haptics,
    );
    await tester.pumpAndSettle();

    expect(_device, findsOneWidget); // no error state
    expect(_brightness(tester), Brightness.dark); // Sistem
    await _tap(tester, find.byKey(const Key('counter-tap-area')));
    expect(haptics.roundsCompleted, 1); // vibration on

    await _goTo(tester, 'settings');
    expect(tester.widget<SwitchListTile>(_vibration).value, isTrue);
    await _showThemes(tester); // plan 0011, A-1
    expect(_checked(tester, ThemeChoice.system), isTrue);
  });

  testWidgets('returning to Zikirlerim keeps the selected dhikr and values', (
    tester,
  ) async {
    final store = FakeDhikrStore([
      ('Zikir', _state(count: 1, total: 1)),
      ('Sabah', _state(count: 7, rounds: 2, total: 73, target: 33)),
    ], selectedId: 2);
    await _start(tester, store: store);

    await _goTo(tester, 'settings');
    await _tap(tester, _vibration);
    await _showThemes(tester); // plan 0011, A-1
    await _tap(tester, _theme(ThemeChoice.dark));
    await _goTo(tester, 'myDhikrs');

    expect(tester.widget<Text>(_name).data, 'Sabah');
    expect(tester.widget<Text>(_value).data, '7');
    expect(store.selectedId, 2);
    expect(
      store.stateOf(2),
      _state(count: 7, rounds: 2, total: 73, target: 33),
    );
  });

  testWidgets('settings semantics and touch targets', (tester) async {
    final semantics = tester.ensureSemantics();
    await _start(tester);
    await _goTo(tester, 'settings');

    final vibration = tester.getSemantics(_vibration);
    expect(vibration.label, startsWith('Titreşim'));
    expect(vibration, isSemantics(hasToggledState: true, isToggled: true));
    await _tap(tester, _vibration);
    expect(
      tester.getSemantics(_vibration),
      isSemantics(hasToggledState: true, isToggled: false),
    );

    await _showThemes(tester); // plan 0011, A-1
    for (final c in ThemeChoice.values) {
      expect(
        tester.getSemantics(_theme(c)),
        isSemantics(
          hasCheckedState: true,
          isChecked: c == ThemeChoice.system,
          isInMutuallyExclusiveGroup: true,
        ),
        reason: '$c',
      );
    }

    for (final f in [
      _vibration,
      for (final c in ThemeChoice.values) _theme(c),
    ]) {
      // Plan 0011, A-1.
      await _scrollTo(tester, f, identical(f, _vibration) ? -100 : 100);
      final size = tester.getSize(f);
      expect(size.width, greaterThanOrEqualTo(48), reason: '$f');
      expect(size.height, greaterThanOrEqualTo(48), reason: '$f');
    }
    semantics.dispose();
  });

  testWidgets('text contrast is at least 4.5 in light and dark', (
    tester,
  ) async {
    for (final choice in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        settings: FakeSettingsRepository(
          stored: AppSettings(vibration: true, theme: choice),
        ),
      );
      await tester.pumpAndSettle();
      final scheme = Theme.of(tester.element(find.byType(AppBar))).colorScheme;
      // Text on the app's surfaces: titles, the dhikr name, list rows and
      // their subtitles, the selected radio and switch.
      for (final (fg, bg, what) in [
        (scheme.onSurface, scheme.surface, 'onSurface/surface'),
        (scheme.onSurfaceVariant, scheme.surface, 'onSurfaceVariant/surface'),
        (scheme.primary, scheme.surface, 'primary/surface'),
        (scheme.onSurface, scheme.surfaceContainerLow, 'onSurface/sheet'),
        (scheme.onPrimary, scheme.primary, 'onPrimary/primary'),
      ]) {
        expect(
          _contrast(fg, bg),
          greaterThanOrEqualTo(4.5),
          reason: '$choice $what',
        );
      }
    }
  });
}
