import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/esma/esma.dart';
import 'package:zikirmatik/features/esma/ui/esma_screen.dart'
    show arabicFontFamily;

import '../../../support/test_app.dart';

// Spec 0007 — Esmaü'l-Hüsna.

final _list = find.byKey(const Key('esma-list'));
final _title = find.descendant(
  of: find.byType(AppBar),
  matching: find.byType(Text),
);
final _added = find.byKey(const Key('esma-added'));
final _countAction = find.byKey(const Key('esma-count'));
final _dhikrName = find.byKey(const Key('dhikr-name'));
final _value = find.byKey(const Key('counter-value'));

Finder _row(int n) => find.byKey(Key('esma-row-$n'));
Finder _add(int n) => find.byKey(Key('esma-add-$n'));
Finder _field(String f, int n) => find.byKey(Key('esma-$f-$n'));

/// The stored names, read straight from the bundled file.
final List<AsmaName> _names = switch (AssetEsmaRepository.parse(
  File(AssetEsmaRepository.asset).readAsStringSync(),
)) {
  Ok(:final value) => value,
  Err() => throw StateError('esma.json rejected'),
};

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

FakeDhikrStore _two() => FakeDhikrStore([
  ('Zikir', _state(count: 1, total: 1)),
  ('Sabah', _state(count: 7, rounds: 2, total: 73, target: 33)),
], selectedId: 2);

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

Future<void> _start(
  WidgetTester tester, {
  FakeDhikrStore? store,
  FakeTesbihatRepository? tesbihat,
}) async {
  await tester.pumpWidget(
    testApp(tester, store: store ?? _two(), tesbihat: tesbihat),
  );
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _openEsma(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('section-asma')));
  await tester.pumpAndSettle();
  // The bundled file loads asynchronously.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    500,
    maxScrolls: 1000,
    scrollable: find.descendant(of: _list, matching: find.byType(Scrollable)),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapAdd(WidgetTester tester, int n) async {
  await _scrollTo(tester, _add(n));
  await tester.tap(_add(n));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the menu opens the list of 99 names in order', (tester) async {
    await _start(tester);
    await _openEsma(tester);

    expect(_text(tester, _title), "Esmaü'l-Hüsna");
    expect(find.text('Bu bölüm yakında.'), findsNothing);
    for (final n in [1, 2, 50, 98, 99]) {
      await _scrollTo(tester, _row(n));
      for (final f in ['arabic', 'reading', 'meaning']) {
        expect(_field(f, n), findsOneWidget, reason: '$f $n');
      }
      expect(_add(n), findsOneWidget);
      expect(
        find.descendant(of: _row(n), matching: find.text('$n')),
        findsOneWidget,
      );
    }
    expect(_row(100), findsNothing);
    // Order on screen: each row below the previous one.
    await tester.drag(_list, const Offset(0, 100000));
    await tester.pumpAndSettle();
    await _scrollTo(tester, _row(1));
    expect(
      tester.getTopLeft(_row(2)).dy,
      greaterThan(tester.getTopLeft(_row(1)).dy),
    );
  });

  testWidgets('the text on screen equals the stored text', (tester) async {
    await _start(tester);
    await _openEsma(tester);

    for (final name in _names) {
      final n = name.number;
      await _scrollTo(tester, _row(n));
      expect(_text(tester, _field('arabic', n)), name.arabic, reason: '$n');
      expect(_text(tester, _field('reading', n)), name.reading, reason: '$n');
      expect(_text(tester, _field('meaning', n)), name.meaning, reason: '$n');
    }
  });

  testWidgets(
    'long readings and meanings wrap without ellipsis at the largest text size',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _start(tester);
      await _openEsma(tester);

      // 85 has the longest reading, 91 the longest meaning.
      for (final n in [85, 91]) {
        await _scrollTo(tester, _row(n));
        for (final f in ['arabic', 'reading', 'meaning']) {
          final text = tester.widget<Text>(_field(f, n));
          expect(text.maxLines, isNull, reason: '$f $n');
          expect(text.overflow, isNot(TextOverflow.ellipsis), reason: '$f $n');
          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(of: _field(f, n), matching: find.byType(RichText)),
          );
          expect(paragraph.didExceedMaxLines, isFalse, reason: '$f $n');
        }
        // Wrapped onto more than one line: taller than two lines of the
        // scaled body font (14 px × 2), all of it laid out.
        expect(
          tester.getSize(_field('meaning', n)).height,
          greaterThan(2 * 14 * 2),
          reason: 'meaning $n wraps',
        );
        // The number stays on one line: laid out as wide as its unbroken
        // text (review round 1, F-2).
        final number = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: find.byKey(Key('esma-number-$n')),
            matching: find.byType(RichText),
          ),
        );
        expect(
          number.size.width,
          moreOrLessEquals(number.getMaxIntrinsicWidth(double.infinity)),
          reason: 'number $n',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('arabic is drawn right to left with Amiri Quran', (tester) async {
    await _start(tester);
    await _openEsma(tester);

    for (final n in [1, 85]) {
      await _scrollTo(tester, _row(n));
      final arabic = tester.widget<Text>(_field('arabic', n));
      expect(arabic.textDirection, TextDirection.rtl);
      expect(arabic.style?.fontFamily, arabicFontFamily);
    }

    // The bundle binds that family to the embedded Amiri Quran file, so the
    // device draws it instead of a fallback font (review round 1, F-1).
    final manifest = await tester.runAsync(
      () => rootBundle.loadString('FontManifest.json'),
    );
    final families = [
      for (final f in jsonDecode(manifest!) as List<Object?>)
        f! as Map<String, Object?>,
    ];
    final amiri = families.where((f) => f['family'] == arabicFontFamily);
    expect(amiri, hasLength(1));
    expect(
      [
        for (final a in amiri.single['fonts']! as List<Object?>)
          (a! as Map<String, Object?>)['asset'],
      ],
      ['assets/fonts/AmiriQuran-Regular.ttf'],
    );
  });

  testWidgets(
    'add appends an untargeted dhikr named by the reading and keeps the selection and scroll',
    (tester) async {
      final store = _two();
      await _start(tester, store: store);
      await _openEsma(tester);

      await _scrollTo(tester, _row(40));
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: _list, matching: find.byType(Scrollable)),
      );
      final offset = scrollable.position.pixels;
      await tester.tap(_add(40));
      await tester.pumpAndSettle();

      expect(store.entries.length, 3);
      final added = store.entries.last;
      expect(added.name.value, _names[39].reading);
      expect(store.stateOf(added.id), _state());
      expect(store.selectedId, 2);
      expect(scrollable.position.pixels, offset);
      expect(_text(tester, _title), "Esmaü'l-Hüsna");

      // A restart (same storage) still has it, and Sabah stays selected.
      await tester.pumpWidget(const SizedBox());
      await _start(tester, store: store);
      expect(_text(tester, _dhikrName), 'Sabah');
      expect(store.entries.last, added);
    },
  );

  testWidgets("the snackbar's count action opens the added dhikr", (
    tester,
  ) async {
    final store = _two();
    await _start(tester, store: store);
    await _openEsma(tester);

    await _tapAdd(tester, 2);
    expect(_added, findsOneWidget);
    expect(find.text("Zikirlerim'e eklendi"), findsOneWidget);
    await tester.tap(_countAction);
    await tester.pumpAndSettle();

    final added = store.entries.last;
    expect(_text(tester, _title), 'Zikirlerim');
    expect(_text(tester, _dhikrName), 'er-Rahmân');
    expect(_text(tester, _value), '0');
    expect(find.text('Hedef yok'), findsOneWidget);
    expect(store.selectedId, added.id);
  });

  testWidgets('count action over the tesbihat keeps its progress', (
    tester,
  ) async {
    final store = _two();
    final progress = TesbihatState(
      step: 1,
      count: const DhikrCount(5),
      completions: 2,
      selected: true,
    );
    final tesbihat = FakeTesbihatRepository(stored: progress);
    await _start(tester, store: store, tesbihat: tesbihat);
    await _openEsma(tester);

    await _tapAdd(tester, 1);
    await tester.tap(_countAction);
    await tester.pumpAndSettle();

    expect(_text(tester, _dhikrName), 'Allah');
    expect(store.selectedId, store.entries.last.id);
    expect(
      tesbihat.stored,
      TesbihatState(
        step: 1,
        count: const DhikrCount(5),
        completions: 2,
        selected: false,
      ),
    );
  });

  testWidgets('adding twice creates two dhikrs counted separately', (
    tester,
  ) async {
    final store = _two();
    await _start(tester, store: store);
    await _openEsma(tester);

    await _tapAdd(tester, 3);
    await _tapAdd(tester, 3);
    await tester.tap(_countAction);
    await tester.pumpAndSettle();

    final first = store.entries[2];
    final second = store.entries[3];
    expect(first.name, second.name);
    expect(first.id, isNot(second.id));
    expect(store.selectedId, second.id);
    await tester.tap(find.byKey(const Key('counter-tap-area')));
    await tester.pumpAndSettle();
    expect(store.stateOf(second.id), _state(count: 1, total: 1));
    expect(store.stateOf(first.id), _state());
  });

  testWidgets('adding changes no dhikr and not the tesbihat', (tester) async {
    final store = _two();
    final tesbihat = FakeTesbihatRepository();
    await _start(tester, store: store, tesbihat: tesbihat);
    final before = [store.stateOf(1), store.stateOf(2)];
    await _openEsma(tester);

    await _tapAdd(tester, 10);
    await _tapAdd(tester, 99);

    expect([store.stateOf(1), store.stateOf(2)], before);
    expect(store.entries.take(2).map((e) => e.name.value), ['Zikir', 'Sabah']);
    expect(tesbihat.saves, isEmpty);
    expect(tesbihat.stored, TesbihatState.initial);
  });

  testWidgets('the source line is shown at the end of the list', (
    tester,
  ) async {
    await _start(tester);
    await _openEsma(tester);

    final source = find.byKey(const Key('esma-source'));
    await _scrollTo(tester, source);
    expect(
      _text(tester, source),
      'Liste: Tirmizî, Daavât 82 — Diyanet sırası (Hadislerle İslâm, c. 1, '
      's. 219) · Okunuş ve anlam: yasin.suresi.gen.tr · Arapça yazı: Amiri '
      'fontu',
    );
    expect(
      tester.getTopLeft(source).dy,
      greaterThan(tester.getTopLeft(_row(99)).dy),
    );
  });

  testWidgets('row and add button labels, announcement and touch targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _start(tester);
    await _openEsma(tester);

    final allah = _names.first;
    expect(find.bySemanticsLabel('1. Allah, ${allah.meaning}'), findsOneWidget);
    expect(find.bySemanticsLabel(allah.arabic), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(allah.arabic))),
      findsNothing,
    );
    expect(
      tester.getSemantics(_add(1)),
      isSemantics(
        label: "Allah Zikirlerim'e ekle",
        isButton: true,
        hasTapAction: true,
      ),
    );
    final size = tester.getSize(_add(1));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));

    await _tapAdd(tester, 1);
    expect(
      find.descendant(
        of: _added,
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.liveRegion ?? false),
        ),
      ),
      findsWidgets,
    );
    final count = tester.getSize(_countAction);
    expect(count.height, greaterThanOrEqualTo(48));
    semantics.dispose();
  });
}
