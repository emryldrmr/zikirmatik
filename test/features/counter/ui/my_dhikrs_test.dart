import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';

import '../../../support/test_app.dart';

// Spec 0003 — Zikirlerim.

final _pickerButton = find.byKey(const Key('dhikr-picker-button'));
final _name = find.byKey(const Key('dhikr-name'));
final _value = find.byKey(const Key('counter-value'));
final _total = find.byKey(const Key('counter-total'));
final _targetButton = find.byKey(const Key('counter-target'));
final _button = find.byKey(const Key('counter-tap-area'));
final _device = find.byKey(const Key('counter-device'));
final _nameField = find.byKey(const Key('dhikr-name-field'));
final _targetField = find.byKey(const Key('dhikr-target-field'));
final _save = find.byKey(const Key('dhikr-save'));

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

String _targetText(WidgetTester tester) => _text(
  tester,
  find.descendant(of: _targetButton, matching: find.byType(Text)),
);

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

Future<void> _start(WidgetTester tester, FakeDhikrStore store) async {
  await tester.pumpWidget(testApp(tester, store: store));
  await tester.pump();
  await tester.pump();
}

Future<void> _openPicker(WidgetTester tester) async {
  await tester.tap(_pickerButton);
  await tester.pumpAndSettle();
}

Finder _row(int id) => find.byKey(Key('dhikr-row-$id'));

Future<void> _choose(WidgetTester tester, int id) async {
  await _openPicker(tester);
  await tester.tap(_row(id));
  await tester.pumpAndSettle();
}

bool _saveEnabled(WidgetTester tester) =>
    tester.widget<FilledButton>(_save).onPressed != null;

Future<void> _addViaPicker(
  WidgetTester tester,
  String name, {
  String target = '',
}) async {
  await _openPicker(tester);
  await tester.tap(find.byKey(const Key('dhikr-add')));
  await tester.pumpAndSettle();
  await tester.enterText(_nameField, name);
  await tester.enterText(_targetField, target);
  await tester.pump();
  await tester.tap(_save);
  await tester.pumpAndSettle();
}

Future<void> _openEdit(WidgetTester tester, int id) async {
  await _openPicker(tester);
  await tester.tap(find.byKey(Key('dhikr-edit-$id')));
  await tester.pumpAndSettle();
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

void main() {
  testWidgets('first launch shows Zikir selected with zero', (tester) async {
    await _start(tester, FakeDhikrStore([('Zikir', CounterState.initial)]));

    expect(_text(tester, _name), 'Zikir');
    expect(_text(tester, _value), '0');
    expect(_text(tester, _total), 'Toplam 0');
    expect(_targetText(tester), 'Hedef yok');
    expect(find.text('Zikirlerim'), findsOneWidget); // the title stays (G3)
  });

  testWidgets(
    'picker lists dhikrs in creation order with the selected one marked',
    (tester) async {
      final store = FakeDhikrStore([
        ('Zikir', CounterState.initial),
        ('Sabah', CounterState.initial),
        ('Akşam', CounterState.initial),
      ], selectedId: 2);
      await _start(tester, store);

      expect(_text(tester, _name), 'Sabah');
      await _openPicker(tester);
      expect(_rowTitles(tester), ['Zikir', 'Sabah', 'Akşam']);
      for (final id in [1, 2, 3]) {
        expect(tester.widget<ListTile>(_row(id)).selected, id == 2);
      }
    },
  );

  testWidgets(
    'adding a dhikr validates name and target and selects it at zero',
    (tester) async {
      final store = FakeDhikrStore([('Zikir', _state(count: 4, total: 4))]);
      await _start(tester, store);
      await _openPicker(tester);
      await tester.tap(find.byKey(const Key('dhikr-add')));
      await tester.pumpAndSettle();

      // An untouched empty form shows no warning yet, but Kaydet is disabled.
      expect(find.text('Ad 1–50 karakter olmalı.'), findsNothing);
      expect(_saveEnabled(tester), isFalse);
      await tester.enterText(_nameField, 'x'); // typed, then cleared below
      for (final bad in ['', '   ', 'x' * 51]) {
        await tester.enterText(_nameField, bad);
        await tester.pump();
        expect(
          find.text('Ad 1–50 karakter olmalı.'),
          findsOneWidget,
          reason: '"$bad"',
        );
        expect(_saveEnabled(tester), isFalse, reason: '"$bad"');
      }
      await tester.enterText(_nameField, '  Sabah  ');
      for (final bad in ['0', '100001', 'abc']) {
        await tester.enterText(_targetField, bad);
        await tester.pump();
        expect(
          find.text('1 ile 100.000 arasında bir sayı girin.'),
          findsOneWidget,
        );
        expect(_saveEnabled(tester), isFalse, reason: 'target "$bad"');
      }
      await tester.enterText(_targetField, '33');
      await tester.pump();
      expect(_saveEnabled(tester), isTrue);
      await tester.tap(_save);
      await tester.pumpAndSettle();
      // F-2: a successful add closes the picker; the device is ready.
      expect(find.byKey(const Key('dhikr-picker')), findsNothing);

      expect(_text(tester, _name), 'Sabah');
      expect(_text(tester, _value), '0');
      expect(_text(tester, _total), 'Toplam 0');
      expect(_targetText(tester), 'Hedef 33 · Tur 0');
      expect(store.entries.map((e) => e.name.value), ['Zikir', 'Sabah']);
      expect(store.selectedId, 2);
      expect(store.stateOf(1), _state(count: 4, total: 4)); // untouched

      // 1 and 50 characters are accepted; an empty target means no target.
      await _addViaPicker(tester, 'a');
      expect(_text(tester, _name), 'a');
      expect(_targetText(tester), 'Hedef yok');
      await _addViaPicker(tester, 'b' * 50);
      expect(store.entries.last.name.value, 'b' * 50);
    },
  );

  testWidgets("switching shows each dhikr's own values", (tester) async {
    final store = FakeDhikrStore([
      ('Zikir', _state(count: 5, total: 20)),
      ('Sabah', _state(count: 7, rounds: 2, total: 73, target: 33)),
    ]);
    await _start(tester, store);
    expect(_text(tester, _value), '5');

    await _choose(tester, 2);
    expect(_text(tester, _name), 'Sabah');
    expect(_text(tester, _value), '7');
    expect(_targetText(tester), 'Hedef 33 · Tur 2');
    expect(_text(tester, _total), 'Toplam 73');
    expect(store.selectedId, 2);

    await _choose(tester, 1);
    expect(_text(tester, _value), '5');
    expect(_targetText(tester), 'Hedef yok');
  });

  testWidgets('counter actions change only the selected dhikr', (tester) async {
    final store = FakeDhikrStore([
      ('Zikir', _state(count: 5, total: 20)),
      ('Sabah', _state(count: 7, total: 7)),
    ], selectedId: 2);
    await _start(tester, store);

    await tester.tap(_button);
    await tester.tap(_button);
    await tester.tap(find.byKey(const Key('counter-undo')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('counter-reset')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-ok')));
    await tester.pumpAndSettle();

    expect(store.stateOf(2), _state(total: 8));
    expect(store.stateOf(1), _state(count: 5, total: 20));
  });

  testWidgets('target change affects only the selected dhikr', (tester) async {
    // Review round 1, F-1: the target part of AC-4.
    final store = FakeDhikrStore([
      ('Zikir', _state(count: 5, total: 20, target: 33)),
      ('Sabah', _state(count: 7, total: 7)),
    ], selectedId: 2);
    await _start(tester, store);

    await tester.tap(_targetButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('target-option-99')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-ok'))); // Sabah has progress
    await tester.pumpAndSettle();

    expect(_targetText(tester), 'Hedef 99 · Tur 0');
    expect(store.stateOf(2), _state(total: 7, target: 99));
    expect(store.stateOf(1), _state(count: 5, total: 20, target: 33));

    await _choose(tester, 1);
    expect(_targetText(tester), 'Hedef 33 · Tur 0');
    expect(_text(tester, _value), '5');
  });

  testWidgets('renaming keeps the values', (tester) async {
    final store = FakeDhikrStore([
      ('Sabah', _state(count: 3, rounds: 1, total: 36, target: 33)),
    ]);
    await _start(tester, store);

    await _openEdit(tester, 1);
    expect(tester.widget<TextField>(_nameField).controller!.text, 'Sabah');
    await tester.enterText(_nameField, 'Sabah zikri');
    await tester.pump();
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(_rowTitles(tester), ['Sabah zikri']);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(_text(tester, _name), 'Sabah zikri');
    expect(_text(tester, _value), '3');
    expect(
      store.stateOf(1),
      _state(count: 3, rounds: 1, total: 36, target: 33),
    );
    expect(store.entries.single.name.value, 'Sabah zikri');
  });

  testWidgets('rename cancel changes nothing', (tester) async {
    final store = FakeDhikrStore([('Sabah', CounterState.initial)]);
    await _start(tester, store);

    await _openEdit(tester, 1);
    await tester.enterText(_nameField, 'Başka');
    await tester.tap(find.byKey(const Key('dhikr-cancel')));
    await tester.pumpAndSettle();

    expect(_rowTitles(tester), ['Sabah']);
    expect(store.entries.single.name.value, 'Sabah');
  });

  testWidgets('rename validates the name', (tester) async {
    await _start(tester, FakeDhikrStore([('Sabah', CounterState.initial)]));

    await _openEdit(tester, 1);
    for (final bad in ['', '  ', 'y' * 51]) {
      await tester.enterText(_nameField, bad);
      await tester.pump();
      expect(find.text('Ad 1–50 karakter olmalı.'), findsOneWidget);
      expect(_saveEnabled(tester), isFalse);
    }
  });

  testWidgets('delete asks and removes', (tester) async {
    final store = FakeDhikrStore([
      ('Zikir', _state(count: 1, total: 1)),
      ('Sabah', _state(count: 9, total: 9)),
      ('Akşam', CounterState.initial),
    ], selectedId: 2);
    await _start(tester, store);

    await _openEdit(tester, 2);
    await tester.tap(find.byKey(const Key('dhikr-delete')));
    await tester.pumpAndSettle();
    expect(
      find.text('“Sabah” silinsin mi? Sayımı ve toplamı da silinir.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('confirm-ok')));
    await tester.pumpAndSettle();

    expect(_rowTitles(tester), ['Zikir', 'Akşam']);
    expect(store.counters.containsKey(2), isFalse);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(_text(tester, _name), 'Zikir'); // first remaining is selected
    expect(_text(tester, _value), '1');
    expect(store.selectedId, 1);
  });

  testWidgets('delete cancel changes nothing', (tester) async {
    final store = FakeDhikrStore([('Sabah', _state(count: 9, total: 9))]);
    await _start(tester, store);

    await _openEdit(tester, 1);
    await tester.tap(find.byKey(const Key('dhikr-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-cancel')));
    await tester.pumpAndSettle();

    expect(_rowTitles(tester), ['Sabah']);
    expect(store.stateOf(1), _state(count: 9, total: 9));
  });

  testWidgets(
    'deleting the last dhikr shows the empty state and adding brings the device back',
    (tester) async {
      final store = FakeDhikrStore([('Zikir', _state(count: 2, total: 2))]);
      await _start(tester, store);

      await _openEdit(tester, 1);
      await tester.tap(find.byKey(const Key('dhikr-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-ok')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text('Henüz zikir yok.'), findsOneWidget);
      expect(_device, findsNothing);
      expect(_pickerButton, findsNothing);
      expect(store.selectedId, isNull);
      final emptyAdd = tester.getSize(find.byKey(const Key('dhikr-empty-add')));
      expect(emptyAdd.width, greaterThanOrEqualTo(48)); // I-5
      expect(emptyAdd.height, greaterThanOrEqualTo(48));

      await tester.tap(find.byKey(const Key('dhikr-empty-add')));
      await tester.pumpAndSettle();
      await tester.enterText(_nameField, 'Yeni');
      await tester.pump();
      await tester.tap(_save);
      await tester.pumpAndSettle();

      expect(find.text('Henüz zikir yok.'), findsNothing);
      expect(_device, findsOneWidget);
      expect(_text(tester, _name), 'Yeni');
      expect(_text(tester, _value), '0');
    },
  );

  testWidgets('restart shows the same dhikrs and selection', (tester) async {
    final store = FakeDhikrStore([('Zikir', CounterState.initial)]);
    await _start(tester, store);
    await _addViaPicker(tester, 'Sabah', target: '99');
    await tester.tap(_button);
    await tester.pump();

    await tester.pumpWidget(const SizedBox()); // "restart"
    await _start(tester, store);

    expect(_text(tester, _name), 'Sabah');
    expect(_text(tester, _value), '1');
    expect(_targetText(tester), 'Hedef 99 · Tur 0');
    await _openPicker(tester);
    expect(_rowTitles(tester), ['Zikir', 'Sabah']);
  });

  testWidgets('same names are separate dhikrs', (tester) async {
    final store = FakeDhikrStore([
      ('Zikir', _state(count: 3, total: 3)),
      ('Zikir', _state(count: 8, total: 8)),
    ]);
    await _start(tester, store);
    await _addViaPicker(tester, 'Zikir');

    await tester.tap(_button);
    await tester.pump();
    await _openPicker(tester);
    expect(_rowTitles(tester), ['Zikir', 'Zikir', 'Zikir']);
    expect(store.stateOf(3), _state(count: 1, total: 1));
    expect(store.stateOf(1), _state(count: 3, total: 3));
    expect(store.stateOf(2), _state(count: 8, total: 8));
  });

  testWidgets(
    'a 50-character name is ellipsized above the device and complete in the list',
    (tester) async {
      final long =
          'Sübhanallahi ve bihamdihi sübhanallahil azim zikri'; // 50 chars
      expect(long.runes.length, 50);
      await _start(tester, FakeDhikrStore([(long, CounterState.initial)]));

      final shown = tester.widget<Text>(_name);
      expect(shown.data, long);
      expect(shown.maxLines, 1);
      expect(shown.overflow, TextOverflow.ellipsis);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: _name, matching: find.byType(RichText)),
      );
      expect(paragraph.didExceedMaxLines, isTrue); // really cut with "…"

      await _openPicker(tester);
      final rowText = tester.widget<Text>(
        find.descendant(of: _row(1), matching: find.text(long)),
      );
      expect(rowText.maxLines, isNull); // the list shows it all
    },
  );

  testWidgets('semantics labels, selected state and touch targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _start(
      tester,
      FakeDhikrStore([
        ('Zikir', CounterState.initial),
        ('Sabah', CounterState.initial),
      ], selectedId: 2),
    );

    expect(
      find.bySemanticsLabel('Zikir: Sabah. Değiştirmek için dokunun.'),
      findsOneWidget,
    );
    expect(tester.getSize(_pickerButton).height, greaterThanOrEqualTo(48));

    await _openPicker(tester);
    expect(find.bySemanticsLabel('Sabah zikrini düzenle'), findsOneWidget);
    expect(find.bySemanticsLabel('Zikir zikrini düzenle'), findsOneWidget);
    expect(tester.getSemantics(_row(2)), isSemantics(isSelected: true));
    expect(tester.getSemantics(_row(1)), isSemantics(isSelected: false));
    for (final f in [
      _row(1),
      _row(2),
      find.byKey(const Key('dhikr-edit-1')),
      find.byKey(const Key('dhikr-add')),
    ]) {
      final size = tester.getSize(f);
      expect(size.width, greaterThanOrEqualTo(48), reason: '$f');
      expect(size.height, greaterThanOrEqualTo(48), reason: '$f');
    }
    // Review round 1, I-5: the form buttons too.
    Future<void> expectMinSize(Finder f) async {
      final size = tester.getSize(f);
      expect(size.width, greaterThanOrEqualTo(48), reason: '$f');
      expect(size.height, greaterThanOrEqualTo(48), reason: '$f');
    }

    await tester.tap(find.byKey(const Key('dhikr-add')));
    await tester.pumpAndSettle();
    await expectMinSize(_save);
    await expectMinSize(find.byKey(const Key('dhikr-cancel')));
    await tester.tap(find.byKey(const Key('dhikr-cancel')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dhikr-edit-1')));
    await tester.pumpAndSettle();
    await expectMinSize(find.byKey(const Key('dhikr-delete')));
    await expectMinSize(_save);
    await tester.tap(find.byKey(const Key('dhikr-cancel')));
    await tester.pumpAndSettle();
    semantics.dispose();
  });
}
