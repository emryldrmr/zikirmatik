import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/storage_notice.dart';
import 'package:zikirmatik/features/counter/counter.dart';

import '../../../support/test_app.dart';

// Spec 0015 — Depolama hatası geri bildirimi: the list group on Zikirlerim,
// Önerilen Zikirler and Esmaü'l-Hüsna (AC-6, AC-7).

const _notSaved = 'Kaydedilemedi.';

final _pickerButton = find.byKey(const Key('dhikr-picker-button'));
final _name = find.byKey(const Key('dhikr-name'));
final _value = find.byKey(const Key('counter-value'));
final _nameField = find.byKey(const Key('dhikr-name-field'));
final _targetField = find.byKey(const Key('dhikr-target-field'));
final _save = find.byKey(const Key('dhikr-save'));
final _addForm = find.byKey(const Key('dhikr-add-form'));
final _notice = find.byKey(const Key('storage-notice'));
final _stepText = find.byKey(const Key('tesbihat-text'));

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

FakeDhikrStore _three({int selected = 2}) => FakeDhikrStore([
  ('Zikir', CounterState(count: const DhikrCount(1), total: 1)),
  ('Sabah', CounterState(count: const DhikrCount(7), total: 7)),
  ('Akşam', CounterState(count: const DhikrCount(3), total: 3)),
], selectedId: selected);

Future<void> _start(
  WidgetTester tester,
  FakeDhikrStore store, {
  FakeTesbihatRepository? tesbihat,
}) async {
  await tester.pumpWidget(testApp(tester, store: store, tesbihat: tesbihat));
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _openPicker(WidgetTester tester) async {
  await tester.tap(_pickerButton);
  await tester.pumpAndSettle();
}

Future<void> _closePicker(WidgetTester tester) async {
  await tester.tapAt(const Offset(10, 10)); // the barrier above the sheet
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, int id) async {
  await _openPicker(tester);
  await tester.tap(find.byKey(Key('dhikr-row-$id')));
  await tester.pumpAndSettle();
}

Future<void> _rename(WidgetTester tester, int id, String name) async {
  await _openPicker(tester);
  await tester.tap(find.byKey(Key('dhikr-edit-$id')));
  await tester.pumpAndSettle();
  await tester.enterText(_nameField, name);
  await tester.pump();
  await tester.tap(_save);
  await tester.pumpAndSettle();
  await _closePicker(tester);
}

Future<void> _delete(WidgetTester tester, int id) async {
  await _openPicker(tester);
  await tester.tap(find.byKey(Key('dhikr-edit-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('dhikr-delete')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sil').last);
  await tester.pumpAndSettle();
  await _closePicker(tester);
}

List<String> _rowTitles(WidgetTester tester) => [
  for (final tile in tester.widgetList<ListTile>(
    find.byWidgetPredicate(
      (w) =>
          w is ListTile && (w.key?.toString().contains('dhikr-row-') ?? false),
    ),
  ))
    (tile.title! as Text).data!,
];

/// The rows' names in the picker, then closes it.
Future<List<String>> _rows(WidgetTester tester) async {
  await _openPicker(tester);
  final rows = _rowTitles(tester);
  await _closePicker(tester);
  return rows;
}

Future<void> _noticeGone(WidgetTester tester) async {
  await tester.pump(storageNoticeDuration);
  expect(_notice, findsNothing);
}

DhikrListController _controller(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byType(ZikirmatikApp)),
    ).read(dhikrListControllerProvider.notifier);

Future<void> _openSection(WidgetTester tester, String section) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('section-$section')));
  await tester.pumpAndSettle();
  // The bundled file loads asynchronously.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('failed select, show, rename and delete restore the screen', (
    tester,
  ) async {
    final store = _three();
    await _start(tester, store);
    expect(_text(tester, _name), 'Sabah');
    store.failWrites = true;

    // Select.
    await _choose(tester, 3);
    expect(_text(tester, _name), 'Sabah');
    expect(_text(tester, _value), '7');
    expect(find.text(_notSaved), findsOneWidget);
    await _noticeGone(tester);

    // Rename.
    await _rename(tester, 1, 'Öğle');
    expect(await _rows(tester), ['Zikir', 'Sabah', 'Akşam']);
    expect(find.text(_notSaved), findsOneWidget);
    await _noticeGone(tester);

    // Delete of another one.
    await _delete(tester, 3);
    expect(await _rows(tester), ['Zikir', 'Sabah', 'Akşam']);
    expect(_text(tester, _name), 'Sabah');
    expect(find.text(_notSaved), findsOneWidget);
    await _noticeGone(tester);

    expect(store.entries.map((e) => e.name.value), ['Zikir', 'Sabah', 'Akşam']);
    expect(store.selectedId, 2);

    // Show: "Say" from Esmaü'l-Hüsna over the tesbihat (plan R2).
    await tester.pumpWidget(const SizedBox());
    store.failWrites = false;
    await _start(
      tester,
      store,
      tesbihat: FakeTesbihatRepository(
        stored: const TesbihatState(selected: true),
      ),
    );
    await _openSection(tester, 'asma');
    final add = find.byKey(const Key('esma-add-1'));
    await tester.scrollUntilVisible(
      add,
      500,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('esma-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('esma-added')), findsOneWidget);

    store.failWrites = true;
    await tester.tap(find.byKey(const Key('esma-count')));
    await tester.pumpAndSettle();
    expect(find.text(_notSaved), findsOneWidget);
    // Back on Zikirlerim: the tesbihat as before, the selection unchanged.
    expect(_stepText, findsOneWidget);
    expect(store.selectedId, 2);
    final list = await ProviderScope.containerOf(
      tester.element(find.byType(ZikirmatikApp)),
    ).read(dhikrListControllerProvider.future);
    expect(list.selectedId, 2);
  });

  testWidgets('failed delete of the selected brings back dhikr and selection', (
    tester,
  ) async {
    final store = _three();
    await _start(tester, store);
    store.failWrites = true;

    await _delete(tester, 2);
    expect(_text(tester, _name), 'Sabah');
    expect(_text(tester, _value), '7');
    expect(await _rows(tester), ['Zikir', 'Sabah', 'Akşam']);
    expect(find.text(_notSaved), findsOneWidget);

    // The only dhikr.
    await tester.pumpWidget(const SizedBox());
    final one = FakeDhikrStore([
      ('Zikir', CounterState(count: const DhikrCount(4), total: 4)),
    ]);
    await _start(tester, one);
    one.failWrites = true;
    await _delete(tester, 1);
    expect(find.byKey(const Key('dhikr-empty')), findsNothing);
    expect(_text(tester, _name), 'Zikir');
    expect(_text(tester, _value), '4');
  });

  testWidgets('only the failed change is undone', (tester) async {
    final store = _three();
    await _start(tester, store);
    final dhikrs = _controller(tester);

    // A rename that will fail; a selection made meanwhile is stored.
    store
      ..holdWrites = Completer<void>()
      ..failWrites = true;
    final rename = dhikrs.rename(1, DhikrName.stored('Öğle'));
    store.failWrites = false;
    final select = dhikrs.select(3);
    await tester.pump();
    expect(_text(tester, _name), 'Akşam');
    store.holdWrites!.complete();
    await rename;
    expect(await select, isTrue);
    await tester.pumpAndSettle();
    expect(_text(tester, _name), 'Akşam'); // kept
    expect(await _rows(tester), ['Zikir', 'Sabah', 'Akşam']); // name undone
    expect(find.text(_notSaved), findsOneWidget);
    await _noticeGone(tester);

    // A selection that will fail; a rename and a delete made meanwhile are
    // stored, and a later selection is not overwritten.
    store
      ..holdWrites = Completer<void>()
      ..failWrites = true;
    final failing = dhikrs.select(1);
    store.failWrites = false;
    final renamed = dhikrs.rename(2, DhikrName.stored('Sabah zikri'));
    final again = dhikrs.select(2);
    await tester.pump();
    store.holdWrites!.complete();
    expect(await failing, isFalse);
    await renamed;
    await again;
    await tester.pumpAndSettle();
    expect(_text(tester, _name), 'Sabah zikri'); // the later selection
    expect(store.selectedId, 2);
    expect(find.text(_notSaved), findsOneWidget);
    await _noticeGone(tester);

    // A delete that will fail; another delete made meanwhile is stored.
    store
      ..holdWrites = Completer<void>()
      ..failWrites = true;
    final del = dhikrs.delete(3);
    store.failWrites = false;
    final other = dhikrs.delete(1);
    await tester.pump();
    store.holdWrites!.complete();
    await del;
    await other;
    await tester.pumpAndSettle();
    expect(await _rows(tester), ['Sabah zikri', 'Akşam']);
    expect(store.entries.map((e) => e.id), [2, 3]);
  });

  testWidgets('failed add keeps the form and its input', (tester) async {
    final store = _three();
    await _start(tester, store);
    await _openPicker(tester);
    await tester.tap(find.byKey(const Key('dhikr-add')));
    await tester.pumpAndSettle();
    await tester.enterText(_nameField, 'Öğle');
    await tester.enterText(_targetField, '33');
    await tester.pump();

    store.failWrites = true;
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(_addForm, findsOneWidget);
    expect(tester.widget<TextField>(_nameField).controller!.text, 'Öğle');
    expect(tester.widget<TextField>(_targetField).controller!.text, '33');
    expect(find.text(_notSaved), findsOneWidget);
    expect(store.entries, hasLength(3));

    // While storing, "Kaydet" cannot store twice.
    store
      ..failWrites = false
      ..holdWrites = Completer<void>();
    await tester.tap(_save);
    await tester.pump();
    expect(tester.widget<FilledButton>(_save).onPressed, isNull);
    await tester.tap(_save, warnIfMissed: false);
    store.holdWrites!.complete();
    store.holdWrites = null;
    await tester.pumpAndSettle();

    // Tried again: stored, the form closes, the new dhikr is selected.
    expect(_addForm, findsNothing);
    expect(store.entries.map((e) => e.name.value), [
      'Zikir',
      'Sabah',
      'Akşam',
      'Öğle',
    ]);
    expect(_text(tester, _name), 'Öğle');
  });

  testWidgets('failed add from suggested or esma shows no added', (
    tester,
  ) async {
    for (final (section, list, row, added) in const [
      ('suggested', 'suggested-list', 'suggested-add-1', 'suggested-added'),
      ('asma', 'esma-list', 'esma-add-1', 'esma-added'),
    ]) {
      final store = _three()..failWrites = true;
      await tester.pumpWidget(const SizedBox());
      await _start(tester, store);
      await _openSection(tester, section);
      final add = find.byKey(Key(row));
      await tester.scrollUntilVisible(
        add,
        500,
        scrollable: find
            .descendant(
              of: find.byKey(Key(list)),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(add);
      await tester.pumpAndSettle();

      expect(find.byKey(Key(added)), findsNothing, reason: section);
      expect(find.text(_notSaved), findsOneWidget, reason: section);
      expect(store.entries, hasLength(3), reason: section);
      await tester.pump(storageNoticeDuration);
    }
  });
}
