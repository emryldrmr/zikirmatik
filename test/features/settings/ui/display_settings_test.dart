import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/hand_layout.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';
import 'keep_screen_on_test.dart' show contrast;

// Spec 0011 — Görünüm seçenekleri, Ayarlar (AC-1, AC-9, AC-10).

final _largeCount = find.byKey(const Key('settings-large-count'));
Finder _hand(HandLayout h) => find.byKey(Key('hand-${h.name}'));

Future<void> _start(
  WidgetTester tester, {
  FakeSettingsRepository? store,
  FakeDhikrStore? dhikrs,
}) async {
  await tester.pumpWidget(
    testApp(tester, store: dhikrs, settings: store ?? FakeSettingsRepository()),
  );
  await tester.pumpAndSettle();
}

Future<void> _goTo(WidgetTester tester, String section) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('section-$section')));
  await tester.pumpAndSettle();
}

Future<void> _show(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    100,
    scrollable: find.descendant(
      of: find.byKey(const Key('settings-screen')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
}

HandLayout? _selectedHand(WidgetTester tester) => tester
    .widget<RadioGroup<HandLayout>>(find.byType(RadioGroup<HandLayout>))
    .groupValue;

void main() {
  testWidgets('display options sit under keep screen on', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await _start(tester);
    await _goTo(tester, 'settings');

    expect(find.text('Büyük rakam'), findsOneWidget);
    expect(find.text('Sayım daha büyük görünür'), findsOneWidget);
    expect(find.text('El yerleşimi'), findsOneWidget);
    final order = [
      find.byKey(const Key('settings-keep-screen-on')),
      _largeCount,
      find.text('El yerleşimi'),
      _hand(HandLayout.center),
      _hand(HandLayout.right),
      _hand(HandLayout.left),
      find.text('Tema'),
    ];
    for (var i = 1; i < order.length; i++) {
      expect(
        tester.getTopLeft(order[i]).dy,
        greaterThan(tester.getTopLeft(order[i - 1]).dy),
        reason: '$i',
      );
    }
    expect(
      find.descendant(
        of: _hand(HandLayout.center),
        matching: find.text('Ortada'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _hand(HandLayout.right),
        matching: find.text('Sağ el'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _hand(HandLayout.left),
        matching: find.text('Sol el'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('display options default to normal digits and centre', (
    tester,
  ) async {
    final store = FakeSettingsRepository();
    await _start(tester, store: store);
    await _goTo(tester, 'settings');
    await _show(tester, _largeCount);
    expect(tester.widget<SwitchListTile>(_largeCount).value, isFalse);
    await _show(tester, _hand(HandLayout.left));
    expect(_selectedHand(tester), HandLayout.center);

    // Choosing stores at once, the other settings unchanged; a "restart"
    // with the same store keeps them.
    await _show(tester, _largeCount);
    await tester.tap(_largeCount);
    await tester.pumpAndSettle();
    await _show(tester, _hand(HandLayout.right));
    await tester.tap(_hand(HandLayout.right));
    await tester.pumpAndSettle();
    expect(
      store.stored,
      AppSettings.defaults.copyWith(
        largeCount: true,
        handLayout: HandLayout.right,
      ),
    );

    await tester.pumpWidget(const SizedBox());
    await _start(tester, store: store);
    await _goTo(tester, 'settings');
    await _show(tester, _largeCount);
    expect(tester.widget<SwitchListTile>(_largeCount).value, isTrue);
    await _show(tester, _hand(HandLayout.left));
    expect(_selectedHand(tester), HandLayout.right);
  });

  testWidgets('unreadable settings mean the display defaults', (tester) async {
    await _start(
      tester,
      store: FakeSettingsRepository(
        stored: AppSettings.defaults.copyWith(
          largeCount: true,
          handLayout: HandLayout.left,
        ),
        failLoad: true,
      ),
    );
    expect(find.byType(SnackBar), findsNothing);
    // Applied on Zikirlerim: the device in the middle.
    final device = tester.getCenter(find.byKey(const Key('counter-device')));
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(device.dx, moreOrLessEquals(width / 2, epsilon: 0.5));

    await _goTo(tester, 'settings');
    await _show(tester, _largeCount);
    expect(tester.widget<SwitchListTile>(_largeCount).value, isFalse);
    await _show(tester, _hand(HandLayout.left));
    expect(_selectedHand(tester), HandLayout.center);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('display options semantics, targets and contrast', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    await _start(tester);
    await _goTo(tester, 'settings');

    expect(tester.getSemantics(_largeCount).label, startsWith('Büyük rakam'));
    expect(
      tester.getSemantics(_largeCount),
      isSemantics(hasToggledState: true, isToggled: false),
    );
    await tester.tap(_largeCount);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(_largeCount),
      isSemantics(hasToggledState: true, isToggled: true),
    );
    final labels = {
      HandLayout.center: 'Ortada',
      HandLayout.right: 'Sağ el',
      HandLayout.left: 'Sol el',
    };
    for (final MapEntry(key: hand, value: label) in labels.entries) {
      final node = tester.getSemantics(_hand(hand));
      expect(node.label, label);
      expect(
        node,
        isSemantics(
          hasCheckedState: true,
          isChecked: hand == HandLayout.center,
          isInMutuallyExclusiveGroup: true,
        ),
        reason: label,
      );
    }
    await tester.tap(_hand(HandLayout.left));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(_hand(HandLayout.left)),
      isSemantics(hasCheckedState: true, isChecked: true),
    );
    expect(
      tester.getSemantics(_hand(HandLayout.center)),
      isSemantics(hasCheckedState: true, isChecked: false),
    );
    expect(
      tester.getSemantics(find.text('El yerleşimi')),
      isSemantics(isHeader: true),
    );
    for (final f in [_largeCount, ...HandLayout.values.map(_hand)]) {
      final size = tester.getSize(f);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
    semantics.dispose();

    for (final choice in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        store: FakeSettingsRepository(
          stored: AppSettings(vibration: true, theme: choice),
        ),
      );
      await _goTo(tester, 'settings');
      final bg = Theme.of(tester.element(_largeCount)).colorScheme.surface;
      for (final text in labels.values.followedBy([
        'Büyük rakam',
        'Sayım daha büyük görünür',
        'El yerleşimi',
      ])) {
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
