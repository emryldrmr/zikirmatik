import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zikirmatik/app/composition.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../support/test_app.dart';

const _sections = [
  'Zikirlerim',
  'Geçmiş',
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
  testWidgets('drawer lists six sections in order', (tester) async {
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

    // Spec 0004: Ayarlar is no longer "coming soon" (settings_test.dart, AC-1);
    // spec 0007: nor is Esmaü'l-Hüsna (esma_test.dart, AC-1); spec 0008: nor
    // is Önerilen Zikirler (suggested_test.dart, AC-1); spec 0014: nor is
    // Geçmiş (history_test.dart, AC-6).
    for (final section
        in _sections
            .skip(1)
            .where(
              (s) =>
                  s != 'Geçmiş' &&
                  s != 'Ayarlar' &&
                  s != "Esmaü'l-Hüsna" &&
                  s != 'Önerilen Zikirler',
            )) {
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

  // --- Spec 0009: uygulama sürümü (AC-8, AC-9) ---

  final version = find.byKey(const Key('app-version'));
  final lastEntry = find.byKey(const Key('section-settings'));

  testWidgets('menu shows the app version at the bottom', (tester) async {
    await tester.pumpWidget(testApp(tester, version: '1.0.0'));
    await tester.pump();
    await _openMenu(tester);

    expect(find.text('Sürüm 1.0.0'), findsOneWidget);
    final drawer = tester.getRect(find.byType(Drawer));
    expect(tester.getRect(version).bottom, closeTo(drawer.bottom - 16, 1));
    expect(
      tester.getRect(version).top,
      greaterThan(tester.getRect(lastEntry).bottom),
    );
    expect(tester.widget<Text>(version).style?.color, isNotNull);

    // A short screen: the row moves below the entries and scrolls; never over them.
    tester.view.physicalSize = const Size(800, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      version,
      find.byType(CustomScrollView),
      const Offset(0, -50),
    );
    expect(
      tester.getRect(version).top,
      greaterThan(tester.getRect(lastEntry).bottom),
    );
    await tester.tap(lastEntry);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Ayarlar')),
      findsOneWidget,
    );
  });

  testWidgets('the shown version matches pubspec', (tester) async {
    final line = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    final name = line.substring('version:'.length).trim().split('+').first;
    expect(name, '1.0.0');
    PackageInfo.setMockInitialValues(
      appName: 'zikirmatik',
      packageName: 'com.example.zikirmatik',
      version: name,
      buildNumber: '1',
      buildSignature: '',
    );
    expect(await installedVersion(), name);

    await tester.pumpWidget(testApp(tester, version: name));
    await tester.pump();
    await _openMenu(tester);
    expect(find.text('Sürüm $name'), findsOneWidget);
  });

  testWidgets('no version row when the version is unreadable', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'zikirmatik',
      packageName: 'com.example.zikirmatik',
      version: '',
      buildNumber: '',
      buildSignature: '',
    );
    expect(await installedVersion(), isNull);

    await tester.pumpWidget(testApp(tester)); // no version, as when unreadable
    await tester.pump();
    await _openMenu(tester);
    expect(version, findsNothing);
    final titles = tester
        .widgetList<ListTile>(
          find.descendant(
            of: find.byType(Drawer),
            matching: find.byType(ListTile),
          ),
        )
        .map((t) => (t.title! as Text).data)
        .toList();
    expect(titles, _sections);
    await tester.tap(find.byKey(const Key('section-asma')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text("Esmaü'l-Hüsna"),
      ),
      findsOneWidget,
    );
  });

  testWidgets('version row semantics and contrast', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(testApp(tester, version: '1.0.0'));
    await tester.pump();
    await _openMenu(tester);
    final node = tester.getSemantics(version);
    expect(node.label, 'Sürüm 1.0.0');
    expect(node, isSemantics(hasTapAction: false, isButton: false));
    semantics.dispose();

    for (final choice in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        testApp(
          tester,
          version: '1.0.0',
          settings: FakeSettingsRepository(
            stored: AppSettings(vibration: true, theme: choice),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _openMenu(tester);
      final color = tester
          .renderObject<RenderParagraph>(version)
          .text
          .style!
          .color!;
      final bg = tester
          .widget<Material>(
            find
                .descendant(
                  of: find.byType(Drawer),
                  matching: find.byType(Material),
                )
                .first,
          )
          .color!;
      expect(
        _contrast(color, bg),
        greaterThanOrEqualTo(4.5),
        reason: '$choice',
      );
    }
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}
