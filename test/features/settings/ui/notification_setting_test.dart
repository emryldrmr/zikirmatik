import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';
import 'keep_screen_on_test.dart' show contrast;

// Spec 0017 — the continue notification setting (AC-8, AC-9, AC-10).

final _toggle = find.byKey(const Key('settings-continue-notification'));
final _denied = find.byKey(const Key('notification-permission-denied'));
const _title = 'Yarım kalan zikir bildirimi';
const _subtitle =
    'Saymaya başlayıp uygulamadan çıkınca kaldığınız yeri gösterir';
const _deniedText =
    'Bildirim izni verilmedi. Telefonun ayarlarından açabilirsiniz.';

const _on = AppSettings(
  vibration: true,
  theme: ThemeChoice.system,
  continueNotification: true,
);

Future<void> _start(
  WidgetTester tester, {
  FakeSettingsRepository? settings,
  FakeContinueNotifier? notifier,
}) async {
  await tester.pumpWidget(
    testApp(tester, settings: settings, notifier: notifier),
  );
  await tester.pumpAndSettle();
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('section-settings')));
  await tester.pumpAndSettle();
}

Future<void> _showToggle(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    _toggle,
    100,
    scrollable: find.descendant(
      of: find.byKey(const Key('settings-screen')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
}

bool _value(WidgetTester tester) =>
    tester.widget<SwitchListTile>(_toggle).value;

void main() {
  testWidgets('notifications section after theme, off by default', (
    tester,
  ) async {
    // A tall screen shows every setting at once, so every position is real.
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _start(tester);
    await _openSettings(tester);

    expect(find.text('Bildirimler'), findsOneWidget);
    expect(find.text(_title), findsOneWidget);
    expect(find.text(_subtitle), findsOneWidget);
    expect(_value(tester), isFalse);

    // The earlier settings keep their order; notifications come last.
    double top(String key) => tester.getTopLeft(find.byKey(Key(key))).dy;
    final order = [
      'settings-vibration',
      'settings-tap-vibration',
      'settings-keep-screen-on',
      'settings-large-count',
      'hand-center',
      'theme-light',
      'theme-system',
      'settings-continue-notification',
    ];
    for (var i = 1; i < order.length; i++) {
      expect(top(order[i - 1]), lessThan(top(order[i])), reason: order[i]);
    }
    expect(
      tester.getTopLeft(find.text('Bildirimler')).dy,
      greaterThan(top('theme-system')),
    );
  });

  testWidgets('kept after restart', (tester) async {
    final store = FakeSettingsRepository();
    final notifier = FakeContinueNotifier(grantOnRequest: true);
    await _start(tester, settings: store, notifier: notifier);
    await _openSettings(tester);
    await _showToggle(tester);
    await tester.tap(_toggle);
    await tester.pumpAndSettle();
    expect(store.stored.continueNotification, isTrue);

    await tester.pumpWidget(const SizedBox());
    await _start(tester, settings: store, notifier: notifier);
    await _openSettings(tester);
    await _showToggle(tester);
    expect(_value(tester), isTrue);
  });

  testWidgets('asks on turning on, not at start', (tester) async {
    final notifier = FakeContinueNotifier(grantOnRequest: true);
    await _start(tester, notifier: notifier);
    await _openSettings(tester);
    expect(notifier.requests, 0);

    await _showToggle(tester);
    await tester.tap(_toggle);
    await tester.pumpAndSettle();
    expect(notifier.requests, 1);
    expect(_value(tester), isTrue);
    expect(_denied, findsNothing);

    // Turning it off asks nothing.
    await tester.tap(_toggle);
    await tester.pumpAndSettle();
    expect(notifier.requests, 1);
    expect(_value(tester), isFalse);
  });

  testWidgets('denied stays off with message', (tester) async {
    final store = FakeSettingsRepository();
    final notifier = FakeContinueNotifier();
    await _start(tester, settings: store, notifier: notifier);
    await _openSettings(tester);
    await _showToggle(tester);
    await tester.tap(_toggle);
    await tester.pumpAndSettle();

    expect(notifier.requests, 1);
    expect(_value(tester), isFalse);
    expect(store.stored.continueNotification, isFalse);
    expect(find.text(_deniedText), findsOneWidget);
  });

  testWidgets('revoked shows off', (tester) async {
    final store = FakeSettingsRepository(stored: _on);
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, settings: store, notifier: notifier);
    await _openSettings(tester);
    await _showToggle(tester);
    expect(_value(tester), isTrue);

    // Taken back in the phone's settings while the app was away.
    notifier.granted = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(_value(tester), isFalse);
    expect(store.stored.continueNotification, isFalse);

    // Opening the screen finds it too.
    store.stored = _on;
    await tester.pumpWidget(const SizedBox());
    await _start(tester, settings: store, notifier: notifier);
    await _openSettings(tester);
    await _showToggle(tester);
    expect(_value(tester), isFalse);
    expect(notifier.requests, 0); // never asked by itself
  });

  testWidgets('one semantics node', (tester) async {
    final semantics = tester.ensureSemantics();
    await _start(tester, notifier: FakeContinueNotifier(grantOnRequest: true));
    await _openSettings(tester);
    await _showToggle(tester);

    final node = tester.getSemantics(_toggle);
    expect(node.label, contains(_title));
    expect(node.label, contains(_subtitle));
    expect(node, isSemantics(hasToggledState: true, isToggled: false));
    await tester.tap(_toggle);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(_toggle),
      isSemantics(hasToggledState: true, isToggled: true),
    );
    expect(
      tester.getSemantics(find.text('Bildirimler')),
      isSemantics(isHeader: true),
    );
    expect(tester.getSize(_toggle).height, greaterThanOrEqualTo(48));
    semantics.dispose();
  });

  testWidgets('denied message announced', (tester) async {
    final semantics = tester.ensureSemantics();
    await _start(tester);
    await _openSettings(tester);
    await _showToggle(tester);
    await tester.tap(_toggle);
    await tester.pumpAndSettle();

    // A live region: TalkBack reads it when it appears.
    final live = find.ancestor(
      of: find.text(_deniedText),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && (w.properties.liveRegion ?? false),
      ),
    );
    expect(live, findsWidgets);
    semantics.dispose();
  });

  testWidgets('largest text at 320 dp', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _start(tester);
    await _openSettings(tester);
    await _showToggle(tester);

    for (final p in tester.renderObjectList<RenderParagraph>(
      find.descendant(of: _toggle, matching: find.byType(RichText)),
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
    expect(tester.takeException(), isNull); // no overflow
  });

  testWidgets('light and dark', (tester) async {
    for (final choice in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        settings: FakeSettingsRepository(
          stored: AppSettings(vibration: true, theme: choice),
        ),
      );
      await _openSettings(tester);
      await _showToggle(tester);
      final bg = Theme.of(tester.element(_toggle)).colorScheme.surface;
      for (final text in ['Bildirimler', _title, _subtitle]) {
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
