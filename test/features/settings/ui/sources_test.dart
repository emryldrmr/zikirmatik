import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';
import 'keep_screen_on_test.dart' show contrast;

// Spec 0019 — the Kaynaklar page and its entry in Ayarlar (AC-1, AC-2, AC-3,
// AC-5, AC-7, AC-8). The texts byte for byte: test/integrity/sources_text_test.

final _entry = find.byKey(const Key('settings-sources'));
final _page = find.byKey(const Key('sources-screen'));
Finder _header(int i) => find.byKey(Key('sources-header-$i'));
Finder _text(int i) => find.byKey(Key('sources-text-$i'));

String _data(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

Future<void> _start(
  WidgetTester tester, {
  FakeSettingsRepository? settings,
}) async {
  await tester.pumpWidget(testApp(tester, settings: settings));
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _openSection(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  // With large text on a small screen the menu item may be below the fold.
  final item = find.byKey(Key('section-$name'));
  await tester.scrollUntilVisible(
    item,
    100,
    scrollable: find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(item);
  await tester.pumpAndSettle();
  // Esma and suggested load their bundled file asynchronously.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

Future<void> _scrollIn(WidgetTester tester, Finder target, Finder list) async {
  await tester.scrollUntilVisible(
    target,
    300,
    maxScrolls: 1000,
    scrollable: find.descendant(of: list, matching: find.byType(Scrollable)),
  );
  await tester.pumpAndSettle();
}

Future<void> _openSources(WidgetTester tester) async {
  await _openSection(tester, 'settings');
  await _scrollIn(tester, _entry, find.byKey(const Key('settings-screen')));
  await tester.tap(_entry);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'about section is last after backup with sources row and subtitle',
    (tester) async {
      // A tall screen shows every setting at once, so every position is real.
      tester.view.physicalSize = const Size(400, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _start(tester);
      await _openSection(tester, 'settings');

      final about = find.text('Hakkında');
      expect(about, findsOneWidget);
      expect(
        find.descendant(of: _entry, matching: find.text('Kaynaklar')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _entry,
          matching: find.text(
            'Uygulamadaki dini metinlerin ve yazı tipinin kaynakları',
          ),
        ),
        findsOneWidget,
      );
      // After the backup section, the entry under its header, nothing below.
      final backup = find.byKey(const Key('backup-section'));
      expect(
        tester.getTopLeft(about).dy,
        greaterThan(tester.getBottomLeft(backup).dy),
      );
      expect(
        tester.getTopLeft(_entry).dy,
        greaterThan(tester.getBottomLeft(about).dy),
      );
      final list = find.byKey(const Key('settings-screen'));
      final last = tester.widget<ListView>(list);
      final children =
          (last.childrenDelegate as SliverChildListDelegate).children;
      expect((children.last as ListTile).key, const Key('settings-sources'));
    },
  );

  testWidgets('tapping sources opens the page', (tester) async {
    await _start(tester);
    await _openSources(tester);

    expect(_page, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Kaynaklar'),
      ),
      findsOneWidget,
    );
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('app bar back returns to settings', (tester) async {
    await _start(tester);
    await _openSources(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(_page, findsNothing);
    expect(find.byKey(const Key('settings-screen')), findsOneWidget);
    expect(_entry, findsOneWidget);
  });

  testWidgets('system back returns to settings', (tester) async {
    await _start(tester);
    await _openSources(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_page, findsNothing);
    expect(find.byKey(const Key('settings-screen')), findsOneWidget);
    expect(_entry, findsOneWidget);
  });

  testWidgets('four section headers in order', (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _start(tester);
    await _openSources(tester);

    const headers = [
      'Esmaü\'l-Hüsna',
      'Önerilen Zikirler',
      'Tesbihat',
      'Yazı tipi',
    ];
    for (var i = 0; i < headers.length; i++) {
      expect(_data(tester, _header(i)), headers[i], reason: 'header $i');
      // Each text sits under its own header, above the next one.
      expect(
        tester.getTopLeft(_text(i)).dy,
        greaterThan(tester.getTopLeft(_header(i)).dy),
      );
      if (i > 0) {
        expect(
          tester.getTopLeft(_header(i)).dy,
          greaterThan(tester.getTopLeft(_text(i - 1)).dy),
        );
      }
    }
    expect(_header(4), findsNothing);
  });

  // AC-5: one text, two places. Both screens are read in the same app run.
  testWidgets('esma text mirrors the esma screen source line', (tester) async {
    await _start(tester);
    await _openSection(tester, 'asma');
    final source = find.byKey(const Key('esma-source'));
    await _scrollIn(tester, source, find.byKey(const Key('esma-list')));
    final onScreen = _data(tester, source);

    await _openSources(tester);
    expect(_data(tester, _text(0)), onScreen);
  });

  testWidgets('suggested text mirrors the suggested screen source line', (
    tester,
  ) async {
    await _start(tester);
    await _openSection(tester, 'suggested');
    final source = find.byKey(const Key('suggested-source'));
    await _scrollIn(tester, source, find.byKey(const Key('suggested-list')));
    final onScreen = _data(tester, source);

    await _openSources(tester);
    expect(_data(tester, _text(1)), onScreen);
  });

  // AC-7: the test environment has no network (flutter_test answers every
  // HTTP request with 400); the page still shows every text.
  testWidgets('page renders from bundled text only', (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _start(tester);
    await _openSources(tester);

    for (var i = 0; i < 4; i++) {
      expect(_data(tester, _text(i)), isNotEmpty, reason: 'text $i');
    }
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping addresses does nothing', (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _start(tester);
    await _openSources(tester);

    final routeBefore = ModalRoute.of(tester.element(_page));
    // Esma (yasin.suresi.gen.tr) and font (github.com/aliftype/amiri).
    for (final i in const [0, 3]) {
      expect(
        find.ancestor(of: _text(i), matching: find.byType(GestureDetector)),
        findsNothing,
        reason: 'text $i',
      );
      expect(
        find.ancestor(of: _text(i), matching: find.byType(InkWell)),
        findsNothing,
        reason: 'text $i',
      );
      await tester.tap(_text(i));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'text $i');
      expect(_page, findsOneWidget, reason: 'text $i');
      expect(ModalRoute.of(tester.element(_page)), same(routeBefore));
      expect(ModalRoute.of(tester.element(_page))!.isCurrent, isTrue);
    }
    expect(find.byType(SelectableText), findsNothing);
  });

  testWidgets('section headers are semantic headers', (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    await _start(tester);
    await _openSources(tester);

    for (var i = 0; i < 4; i++) {
      expect(
        tester.getSemantics(_header(i)),
        isSemantics(isHeader: true, label: _data(tester, _header(i))),
        reason: 'header $i',
      );
      expect(
        tester.getSemantics(_text(i)),
        isSemantics(isHeader: false),
        reason: 'text $i',
      );
    }
    semantics.dispose();
  });

  testWidgets(
    'text scale two at 320 dp is not clipped and scrolls to the end',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _start(tester);
      await _openSources(tester);

      for (var i = 0; i < 4; i++) {
        for (final f in [_header(i), _text(i)]) {
          await _scrollIn(tester, f, _page);
          final text = tester.widget<Text>(f);
          expect(text.maxLines, isNull, reason: '$f');
          expect(text.overflow, isNull, reason: '$f');
          expect(text.softWrap, isNot(isFalse), reason: '$f');
          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(of: f, matching: find.byType(RichText)),
          );
          expect(paragraph.didExceedMaxLines, isFalse, reason: '$f');
          expect(tester.getTopLeft(f).dx, greaterThanOrEqualTo(0));
          expect(tester.getTopRight(f).dx, lessThanOrEqualTo(320));
        }
        // Each long text wraps onto more than one 28 dp line (14 × 2).
        expect(tester.getSize(_text(i)).height, greaterThan(28 * 1.5));
      }
      // Scrolled to the end, the last text is whole: its bottom is on screen.
      await tester.drag(_page, const Offset(0, -10000));
      await tester.pumpAndSettle();
      expect(tester.getBottomLeft(_text(3)).dy, lessThanOrEqualTo(480));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('light and dark', (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final choice in [ThemeChoice.light, ThemeChoice.dark]) {
      await tester.pumpWidget(const SizedBox());
      await _start(
        tester,
        settings: FakeSettingsRepository(
          stored: AppSettings(vibration: true, theme: choice),
        ),
      );
      await _openSources(tester);

      final theme = Theme.of(tester.element(_page));
      expect(
        theme.brightness,
        choice == ThemeChoice.light ? Brightness.light : Brightness.dark,
      );
      final bg = theme.colorScheme.surface;
      for (var i = 0; i < 4; i++) {
        for (final f in [_header(i), _text(i)]) {
          final color = tester
              .renderObject<RenderParagraph>(
                find.descendant(of: f, matching: find.byType(RichText)),
              )
              .text
              .style!
              .color!;
          expect(
            contrast(color, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$choice $f',
          );
        }
      }
    }
  });
}
