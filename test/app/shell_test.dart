import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

const _sections = [
  'Zikirlerim',
  'Önerilen Zikirler',
  "Esmaü'l-Hüsna",
  "Kur'an + Meal",
  'Ayarlar',
];

final _menuButton = find.byKey(const Key('open-menu'));

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(_menuButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('drawer lists five sections in order', (tester) async {
    await tester.pumpWidget(testApp(tester, repo: FakeCounterRepository()));
    await tester.pump();
    await _openMenu(tester);

    final tiles = tester.widgetList<ListTile>(
      find.descendant(of: find.byType(Drawer), matching: find.byType(ListTile)),
    );
    final titles = tiles.map((t) => (t.title! as Text).data).toList();
    expect(titles, _sections);
  });

  testWidgets('each section shows coming soon and counter keeps its value', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(tester, repo: FakeCounterRepository(stored: 4)),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('counter-tap-area')));
    await tester.pump();

    // Spec 0004: Ayarlar is no longer "coming soon" (settings_test.dart, AC-1).
    for (final section in _sections.skip(1).where((s) => s != 'Ayarlar')) {
      await _openMenu(tester);
      await tester.tap(
        find.descendant(of: find.byType(Drawer), matching: find.text(section)),
      );
      await tester.pumpAndSettle();

      final appBar = find.byType(AppBar);
      expect(
        find.descendant(of: appBar, matching: find.text(section)),
        findsOneWidget,
      );
      expect(find.text('Bu bölüm yakında.'), findsOneWidget);
      expect(find.byKey(const Key('counter-value')), findsNothing);
    }

    await _openMenu(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Zikirlerim'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bu bölüm yakında.'), findsNothing);
    expect(
      tester.widget<Text>(find.byKey(const Key('counter-value'))).data,
      '5',
    );
  });

  testWidgets('menu button label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(testApp(tester, repo: FakeCounterRepository()));
    await tester.pump();

    // The button's accessible name comes from its tooltip; TalkBack reads it.
    expect(
      tester.getSemantics(_menuButton),
      isSemantics(tooltip: 'Menüyü aç', isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });
}
