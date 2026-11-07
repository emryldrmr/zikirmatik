import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/suggested/suggested.dart';

import '../../../support/test_app.dart';

// Spec 0008 — Önerilen Zikirler.

final _list = find.byKey(const Key('suggested-list'));
final _title = find.descendant(
  of: find.byType(AppBar),
  matching: find.byType(Text),
);
final _added = find.byKey(const Key('suggested-added'));
final _countAction = find.byKey(const Key('suggested-count'));
final _dhikrName = find.byKey(const Key('dhikr-name'));
final _value = find.byKey(const Key('counter-value'));
final _tapArea = find.byKey(const Key('counter-tap-area'));
final _targetButton = find.byKey(const Key('counter-target'));

const _fields = ['reading', 'meaning', 'target', 'reference'];

Finder _row(int n) => find.byKey(Key('suggested-row-$n'));
Finder _add(int n) => find.byKey(Key('suggested-add-$n'));
Finder _field(String f, int n) => find.byKey(Key('suggested-$f-$n'));

/// The stored dhikrs, read straight from the bundled file.
final List<SuggestedDhikr> _dhikrs = switch (AssetSuggestedRepository.parse(
  File(AssetSuggestedRepository.asset).readAsStringSync(),
)) {
  Ok(:final value) => value,
  Err() => throw StateError('suggested_dhikrs.json rejected'),
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

String _targetText(WidgetTester tester) => _text(
  tester,
  find.descendant(of: _targetButton, matching: find.byType(Text)),
);

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

Future<void> _openSuggested(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('section-suggested')));
  await tester.pumpAndSettle();
  // The bundled file loads asynchronously.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

/// Scrolls [target] into view from wherever the list is: an off-screen row
/// above is not reached by scrolling down, so the list goes back to its top
/// first.
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  if (target.hitTestable().evaluate().isEmpty) {
    tester
        .state<ScrollableState>(
          find.descendant(of: _list, matching: find.byType(Scrollable)),
        )
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
  }
  await tester.scrollUntilVisible(
    target,
    200,
    maxScrolls: 500,
    scrollable: find.descendant(of: _list, matching: find.byType(Scrollable)),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapAdd(WidgetTester tester, int n) async {
  await _scrollTo(tester, _add(n));
  await tester.tap(_add(n));
  await tester.pumpAndSettle();
}

Future<void> _count(WidgetTester tester) async {
  await tester.tap(_countAction);
  await tester.pumpAndSettle();
}

/// The target as the row shows it.
String _shownTarget(SuggestedDhikr d) =>
    d.target == null ? 'Hedefsiz' : 'Hedef: ${d.target}';

void main() {
  testWidgets('the menu opens the 7 suggested dhikrs in order', (tester) async {
    await _start(tester);
    await _openSuggested(tester);

    expect(_text(tester, _title), 'Önerilen Zikirler');
    expect(find.text('Bu bölüm yakında.'), findsNothing);
    const targets = [
      'Hedef: 33',
      'Hedef: 33',
      'Hedef: 33',
      'Hedef: 100',
      'Hedef: 100',
      'Hedefsiz',
      'Hedefsiz',
    ];
    for (var n = 1; n <= 7; n++) {
      await _scrollTo(tester, _row(n));
      for (final f in _fields) {
        expect(_field(f, n), findsOneWidget, reason: '$f $n');
      }
      expect(_text(tester, _field('target', n)), targets[n - 1]);
      expect(_add(n), findsOneWidget);
      expect(
        find.descendant(of: _add(n), matching: find.text('Ekle')),
        findsOneWidget,
      );
    }
    expect(_row(8), findsNothing);
    // Order on screen: each row below the previous one.
    for (var n = 1; n < 7; n++) {
      await _scrollTo(tester, _row(n + 1));
      await _scrollTo(tester, _row(n));
      expect(
        tester.getTopLeft(_row(n + 1)).dy,
        greaterThan(tester.getTopLeft(_row(n)).dy),
        reason: 'row ${n + 1} below row $n',
      );
    }
  });

  testWidgets('the text on screen equals the stored text', (tester) async {
    await _start(tester);
    await _openSuggested(tester);

    for (final d in _dhikrs) {
      final n = d.number;
      await _scrollTo(tester, _row(n));
      expect(_text(tester, _field('reading', n)), d.reading, reason: '$n');
      expect(_text(tester, _field('meaning', n)), d.meaning, reason: '$n');
      expect(_text(tester, _field('reference', n)), d.reference, reason: '$n');
      expect(_text(tester, _field('target', n)), _shownTarget(d), reason: '$n');
    }
  });

  testWidgets('long text wraps without ellipsis at the largest text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _start(tester);
    await _openSuggested(tester);

    for (var n = 1; n <= 7; n++) {
      await _scrollTo(tester, _row(n));
      for (final f in _fields) {
        final text = tester.widget<Text>(_field(f, n));
        expect(text.maxLines, isNull, reason: '$f $n');
        expect(text.overflow, isNot(TextOverflow.ellipsis), reason: '$f $n');
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: _field(f, n), matching: find.byType(RichText)),
        );
        expect(paragraph.didExceedMaxLines, isFalse, reason: '$f $n');
        // Nothing is clipped: the box is as tall as the whole text wrapped at
        // its width (as spec 0007, VERIFY round 1, V-1).
        final whole = TextPainter(
          text: paragraph.text,
          textDirection: paragraph.textDirection,
          textScaler: paragraph.textScaler,
        )..layout(maxWidth: paragraph.size.width);
        addTearDown(whole.dispose);
        expect(
          paragraph.size.height,
          greaterThanOrEqualTo(whole.height - 0.5),
          reason: '$f $n unclipped',
        );
        expect(whole.width, lessThanOrEqualTo(paragraph.size.width + 0.5));
      }
    }
    // 7 has the longest reading and meaning: both wrap onto several lines.
    await _scrollTo(tester, _row(7));
    for (final f in ['reading', 'meaning']) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: _field(f, 7), matching: find.byType(RichText)),
      );
      // The same text on one unbounded line.
      final oneLine = TextPainter(
        text: paragraph.text,
        textDirection: paragraph.textDirection,
        textScaler: paragraph.textScaler,
      )..layout();
      addTearDown(oneLine.dispose);
      expect(oneLine.width, greaterThan(paragraph.size.width), reason: f);
      expect(
        paragraph.size.height,
        greaterThanOrEqualTo(2 * oneLine.height - 0.5),
        reason: '$f 7 wraps',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    "add appends a dhikr named by the reading with the table's target and keeps the selection and scroll",
    (tester) async {
      final store = _two();
      await _start(tester, store: store);
      await _openSuggested(tester);

      await _scrollTo(tester, _row(4));
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: _list, matching: find.byType(Scrollable)),
      );
      final offset = scrollable.position.pixels;
      await tester.tap(_add(4));
      await tester.pumpAndSettle();

      expect(store.entries.length, 3);
      final added = store.entries.last;
      expect(added.name.value, _dhikrs[3].reading);
      expect(added.name.value, 'sübhânallāhi ve bi-hamdihî');
      expect(store.stateOf(added.id), _state(target: 100));
      expect(store.selectedId, 2);
      expect(scrollable.position.pixels, offset);
      expect(_text(tester, _title), 'Önerilen Zikirler');

      // Every targeted row stores its own target.
      for (final n in [1, 2, 3, 5]) {
        await _tapAdd(tester, n);
        expect(
          store.stateOf(store.entries.last.id),
          _state(target: _dhikrs[n - 1].target),
          reason: '$n',
        );
        expect(store.entries.last.name.value, _dhikrs[n - 1].reading);
      }
      expect(store.selectedId, 2);

      // A restart (same storage) still has it, and Sabah stays selected.
      await tester.pumpWidget(const SizedBox());
      await _start(tester, store: store);
      expect(_text(tester, _dhikrName), 'Sabah');
      expect(store.entries[2], added);
    },
  );

  testWidgets('an untargeted row adds a dhikr without target', (tester) async {
    final store = _two();
    await _start(tester, store: store);
    await _openSuggested(tester);

    for (final n in [6, 7]) {
      await _tapAdd(tester, n);
      final added = store.entries.last;
      expect(added.name.value, _dhikrs[n - 1].reading, reason: '$n');
      expect(store.stateOf(added.id), _state(), reason: '$n');
      expect(store.stateOf(added.id).target, isNull, reason: '$n');
    }
    expect(store.selectedId, 2);
  });

  testWidgets('an added targeted dhikr completes a round at its target', (
    tester,
  ) async {
    final store = _two();
    await _start(tester, store: store);
    await _openSuggested(tester);

    await _tapAdd(tester, 1);
    await _count(tester);
    final id = store.entries.last.id;
    for (var i = 0; i < 32; i++) {
      await tester.tap(_tapArea);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(store.stateOf(id), _state(count: 32, total: 32, target: 33));

    await tester.tap(_tapArea); // the 33rd
    await tester.pumpAndSettle();
    expect(store.stateOf(id), _state(rounds: 1, total: 33, target: 33));
    expect(_text(tester, _value), '0');
    expect(_targetText(tester), 'Hedef 33 · Tur 1');
  });

  testWidgets("the snackbar's count action opens the added dhikr", (
    tester,
  ) async {
    final store = _two();
    await _start(tester, store: store);
    await _openSuggested(tester);

    await _tapAdd(tester, 5);
    expect(_added, findsOneWidget);
    expect(find.text("Zikirlerim'e eklendi"), findsOneWidget);
    expect(
      find.descendant(of: _countAction, matching: find.text('Say')),
      findsOneWidget,
    );
    await _count(tester);

    final added = store.entries.last;
    expect(_text(tester, _title), 'Zikirlerim');
    expect(_text(tester, _dhikrName), 'estağfirullah');
    expect(_text(tester, _value), '0');
    expect(_targetText(tester), 'Hedef 100 · Tur 0');
    expect(store.selectedId, added.id);

    // An untargeted one opens without a target.
    await _openSuggested(tester);
    await _tapAdd(tester, 6);
    await _count(tester);
    expect(_text(tester, _dhikrName), 'Lâ havle ve lâ kuvvete illâ billâh');
    expect(_text(tester, _value), '0');
    expect(find.text('Hedef yok'), findsOneWidget);
    expect(store.selectedId, store.entries.last.id);
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
    await _openSuggested(tester);

    await _tapAdd(tester, 2);
    await _count(tester);

    expect(_text(tester, _dhikrName), 'Elhamdülillâh');
    expect(_targetText(tester), 'Hedef 33 · Tur 0');
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
    await _openSuggested(tester);

    await _tapAdd(tester, 3);
    await _tapAdd(tester, 3);
    await _count(tester);

    final first = store.entries[2];
    final second = store.entries[3];
    expect(first.name, second.name);
    expect(first.id, isNot(second.id));
    expect(store.selectedId, second.id);
    await tester.tap(_tapArea);
    await tester.pumpAndSettle();
    expect(store.stateOf(second.id), _state(count: 1, total: 1, target: 33));
    expect(store.stateOf(first.id), _state(target: 33));
  });

  testWidgets('adding changes no dhikr and not the tesbihat', (tester) async {
    final store = _two();
    // A tesbihat with progress, so a reset would show.
    final progress = TesbihatState(
      step: 2,
      count: const DhikrCount(11),
      completions: 3,
    );
    final tesbihat = FakeTesbihatRepository(stored: progress);
    await _start(tester, store: store, tesbihat: tesbihat);
    final before = [store.stateOf(1), store.stateOf(2)];
    await _openSuggested(tester);

    await _tapAdd(tester, 1);
    await _tapAdd(tester, 7);

    expect([store.stateOf(1), store.stateOf(2)], before);
    expect(store.entries.take(2).map((e) => e.name.value), ['Zikir', 'Sabah']);
    expect(tesbihat.saves, isEmpty);
    expect(tesbihat.stored, progress);
  });

  testWidgets('the source line is shown at the end of the list', (
    tester,
  ) async {
    await _start(tester);
    await _openSuggested(tester);

    final source = find.byKey(const Key('suggested-source'));
    await _scrollTo(tester, source);
    expect(
      _text(tester, source),
      'Okunuş, anlam ve sayılar: Diyanet, Hadislerle İslâm (c. 2) · Diyanet '
      'Aylık Dergi (Kasım 2024) · TDV İslâm Ansiklopedisi',
    );
    expect(
      tester.getTopLeft(source).dy,
      greaterThan(tester.getTopLeft(_row(7)).dy),
    );
  });

  testWidgets('row and add button labels, announcement and touch targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _start(tester);
    await _openSuggested(tester);

    for (final d in _dhikrs) {
      final n = d.number;
      await _scrollTo(tester, _row(n));
      expect(
        find.bySemanticsLabel('${d.reading}, ${d.meaning}, ${_shownTarget(d)}'),
        findsOneWidget,
        reason: 'row $n',
      );
      expect(
        tester.getSemantics(_add(n)),
        isSemantics(
          label: "${d.reading} Zikirlerim'e ekle",
          isButton: true,
          hasTapAction: true,
        ),
        reason: 'add $n',
      );
      final size = tester.getSize(_add(n));
      expect(size.width, greaterThanOrEqualTo(48), reason: 'add $n');
      expect(size.height, greaterThanOrEqualTo(48), reason: 'add $n');
    }

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
