import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';

// Spec 0006 — Namaz sonrası tesbihat.

final _pickerButton = find.byKey(const Key('dhikr-picker-button'));
final _tesbihatRow = find.byKey(const Key('tesbihat-row'));
final _button = find.byKey(const Key('counter-tap-area'));
final _value = find.byKey(const Key('counter-value'));
final _stepText = find.byKey(const Key('tesbihat-text'));
final _step = find.byKey(const Key('tesbihat-step'));
final _target = find.byKey(const Key('tesbihat-target'));
final _completions = find.byKey(const Key('tesbihat-completions'));
final _finished = find.byKey(const Key('tesbihat-finished'));
final _restart = find.byKey(const Key('tesbihat-restart'));
final _undo = find.byKey(const Key('tesbihat-undo'));
final _reset = find.byKey(const Key('tesbihat-reset'));

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

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

Future<void> _start(
  WidgetTester tester, {
  FakeDhikrStore? store,
  FakeTesbihatRepository? tesbihat,
  FakeHaptics? haptics,
  FakeSettingsRepository? settings,
}) async {
  await tester.pumpWidget(
    testApp(
      tester,
      store: store ?? _two(),
      tesbihat: tesbihat,
      haptics: haptics,
      settings: settings,
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _openPicker(WidgetTester tester) async {
  await tester.tap(_pickerButton);
  await tester.pumpAndSettle();
}

Future<void> _chooseTesbihat(WidgetTester tester) async {
  await _openPicker(tester);
  await tester.tap(_tesbihatRow);
  await tester.pumpAndSettle();
}

Future<void> _chooseDhikr(WidgetTester tester, int id) async {
  await _openPicker(tester);
  await tester.tap(find.byKey(Key('dhikr-row-$id')));
  await tester.pumpAndSettle();
}

Future<void> _taps(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.tap(_button);
    await tester.pump();
  }
}

/// Opens the tesbihat at [state] (selected).
FakeTesbihatRepository _at(TesbihatState state) =>
    FakeTesbihatRepository(stored: state.selecting(true));

void main() {
  testWidgets('picker shows the tesbihat row first without an edit button', (
    tester,
  ) async {
    await _start(tester);
    await _openPicker(tester);

    final tiles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .where((t) => t.onTap != null)
        .map((t) => t.key)
        .toList();
    expect(tiles.first, const Key('tesbihat-row'));
    expect(tiles.sublist(1, 3), [
      const Key('dhikr-row-1'),
      const Key('dhikr-row-2'),
    ]);
    expect(
      find.descendant(
        of: _tesbihatRow,
        matching: find.text('Namaz sonrası tesbihat'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: _tesbihatRow, matching: find.byType(IconButton)),
      findsNothing,
    );
    expect(tester.widget<ListTile>(_tesbihatRow).selected, isFalse);
  });

  testWidgets(
    'choosing the tesbihat shows step 1 of 3 without total, rounds or target button',
    (tester) async {
      await _start(tester);
      await _chooseTesbihat(tester);

      expect(
        find.descendant(
          of: _pickerButton,
          matching: find.text('Namaz sonrası tesbihat'),
        ),
        findsOneWidget,
      );
      expect(_text(tester, _stepText), 'Sübhânallah');
      expect(_text(tester, _step), 'Adım 1/3');
      expect(_text(tester, _value), '0');
      expect(_text(tester, _target), 'Hedef 33');
      expect(_text(tester, _completions), 'Tamamlanan 0');
      expect(find.byKey(const Key('counter-total')), findsNothing);
      expect(find.byKey(const Key('counter-target')), findsNothing);
      expect(find.textContaining('Tur'), findsNothing);
      expect(find.textContaining('Toplam'), findsNothing);
    },
  );

  testWidgets('the selection at launch is unchanged', (tester) async {
    await _start(tester);
    expect(_text(tester, find.byKey(const Key('dhikr-name'))), 'Sabah');
    expect(_stepText, findsNothing);
  });

  testWidgets("each step's text on screen equals the stored text", (
    tester,
  ) async {
    final steps = namazSonrasiTesbihat.steps;
    for (var i = 0; i < steps.length; i++) {
      await tester.pumpWidget(const SizedBox());
      await _start(tester, tesbihat: _at(TesbihatState(step: i)));
      expect(
        _text(tester, _stepText).codeUnits,
        steps[i].text.codeUnits,
        reason: 'step ${i + 1}',
      );
    }
  });

  testWidgets('step changes vibrate once', (tester) async {
    final haptics = FakeHaptics();
    final repo = _at(TesbihatState.initial);
    await _start(tester, tesbihat: repo, haptics: haptics);

    await _taps(tester, 32);
    expect(_text(tester, _stepText), 'Sübhânallah');
    expect(_text(tester, _value), '32');
    expect(haptics.roundsCompleted, 0);

    await _taps(tester, 1);
    expect(haptics.roundsCompleted, 1);
    expect(_text(tester, _stepText), 'Elhamdülillâh');
    expect(_text(tester, _step), 'Adım 2/3');
    expect(_text(tester, _value), '0');

    await _taps(tester, 33);
    expect(haptics.roundsCompleted, 2);
    expect(_text(tester, _stepText), 'Allâhu ekber');
    expect(_text(tester, _step), 'Adım 3/3');
    expect(repo.stored, const TesbihatState(step: 2, selected: true));
  });

  testWidgets('a tap during a slow vibration is stored in order', (
    tester,
  ) async {
    // Review round 1, F-2 (Known traps): the step change's save must not wait
    // for the vibration.
    final haptics = FakeHaptics()..hold = Completer<void>();
    final repo = _at(const TesbihatState(count: DhikrCount(32)));
    await _start(tester, tesbihat: repo, haptics: haptics);

    await tester.tap(_button); // moves to step 2; vibration still running
    await tester.tap(_button); // the next tap, no pump in between
    await tester.pump();
    haptics.hold!.complete();
    await tester.pump();

    expect(_text(tester, _stepText), 'Elhamdülillâh');
    expect(_text(tester, _value), '1');
    expect(
      repo.stored,
      const TesbihatState(step: 1, count: DhikrCount(1), selected: true),
    );
    expect(repo.saves.map((s) => (s.step, s.count.value)), [(1, 0), (1, 1)]);
  });

  testWidgets('a failing vibration does not stop the step change', (
    tester,
  ) async {
    final haptics = FakeHaptics()..fail = true;
    final repo = _at(const TesbihatState(count: DhikrCount(32)));
    await _start(tester, tesbihat: repo, haptics: haptics);

    await _taps(tester, 1);
    expect(haptics.roundsCompleted, 1);
    expect(_text(tester, _stepText), 'Elhamdülillâh');
    expect(repo.stored, const TesbihatState(step: 1, selected: true));
  });

  testWidgets('with vibration off the step still changes', (tester) async {
    final haptics = FakeHaptics();
    await _start(
      tester,
      tesbihat: _at(const TesbihatState(count: DhikrCount(32))),
      haptics: haptics,
      settings: FakeSettingsRepository(
        stored: const AppSettings(vibration: false, theme: ThemeChoice.system),
      ),
    );

    await _taps(tester, 1);
    expect(haptics.roundsCompleted, 0);
    expect(_text(tester, _stepText), 'Elhamdülillâh');
  });

  testWidgets('completion shows the finished state and restart begins again', (
    tester,
  ) async {
    final haptics = FakeHaptics();
    final repo = _at(const TesbihatState(step: 2, count: DhikrCount(32)));
    await _start(tester, tesbihat: repo, haptics: haptics);

    await _taps(tester, 1);
    expect(haptics.roundsCompleted, 1);
    expect(_text(tester, _finished), 'Tesbihat tamamlandı');
    expect(_text(tester, _completions), 'Tamamlanan 1');
    expect(_restart, findsOneWidget);
    expect(_undo, findsNothing);

    await _taps(tester, 3); // taps change nothing
    expect(haptics.roundsCompleted, 1);
    expect(_text(tester, _completions), 'Tamamlanan 1');
    expect(_text(tester, _value), '0');
    expect(
      repo.stored,
      const TesbihatState(
        step: 2,
        finished: true,
        completions: 1,
        selected: true,
      ),
    );

    await tester.tap(_restart);
    await tester.pumpAndSettle();
    expect(_text(tester, _stepText), 'Sübhânallah');
    expect(_text(tester, _step), 'Adım 1/3');
    expect(_text(tester, _value), '0');
    expect(_text(tester, _completions), 'Tamamlanan 1');

    await _taps(tester, 99);
    expect(_text(tester, _completions), 'Tamamlanan 2');
  });

  testWidgets('undo is hidden when finished', (tester) async {
    await _start(
      tester,
      tesbihat: _at(const TesbihatState(step: 1, count: DhikrCount(2))),
    );

    await tester.tap(_undo);
    await tester.pump();
    expect(_text(tester, _value), '1');
    await tester.tap(_undo);
    await tester.pump();
    expect(_text(tester, _value), '0');
    expect(tester.widget<IconButton>(_undo).onPressed, isNull);
    expect(_text(tester, _stepText), 'Elhamdülillâh'); // no return to step 1

    await tester.pumpWidget(const SizedBox());
    await _start(
      tester,
      tesbihat: _at(
        const TesbihatState(step: 2, finished: true, completions: 1),
      ),
    );
    expect(_undo, findsNothing);
    expect(_reset, findsNothing);
  });

  testWidgets('reset asks and keeps the completed count', (tester) async {
    final repo = _at(
      const TesbihatState(step: 1, count: DhikrCount(10), completions: 4),
    );
    await _start(tester, tesbihat: repo);

    await tester.tap(_reset);
    await tester.pumpAndSettle();
    expect(find.text('Tesbihat baştan başlasın mı?'), findsOneWidget);
    await tester.tap(find.text('Sıfırla').last);
    await tester.pumpAndSettle();

    expect(_text(tester, _stepText), 'Sübhânallah');
    expect(_text(tester, _value), '0');
    expect(_text(tester, _completions), 'Tamamlanan 4');
    expect(repo.stored, const TesbihatState(completions: 4, selected: true));
  });

  testWidgets('reset cancel changes nothing', (tester) async {
    const midway = TesbihatState(
      step: 1,
      count: DhikrCount(10),
      completions: 4,
    );
    final repo = _at(midway);
    await _start(tester, tesbihat: repo);

    await tester.tap(_reset);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(_text(tester, _stepText), 'Elhamdülillâh');
    expect(_text(tester, _value), '10');
    expect(repo.stored, midway.selecting(true));
  });

  testWidgets('restart opens the tesbihat where it was', (tester) async {
    final store = _two();
    final repo = FakeTesbihatRepository();
    await _start(tester, store: store, tesbihat: repo);
    await _chooseTesbihat(tester);
    await _taps(tester, 40);

    await tester.pumpWidget(const SizedBox()); // "restart"
    await _start(tester, store: store, tesbihat: repo);

    expect(_text(tester, _stepText), 'Elhamdülillâh');
    expect(_text(tester, _value), '7');
    expect(_text(tester, _completions), 'Tamamlanan 0');
  });

  testWidgets('counting the tesbihat changes no dhikr', (tester) async {
    final store = _two();
    await _start(tester, store: store);
    await _chooseTesbihat(tester);

    await _taps(tester, 99); // the whole tesbihat
    await tester.tap(_restart);
    await tester.pumpAndSettle();
    await _taps(tester, 5);
    await tester.tap(_reset);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sıfırla').last);
    await tester.pumpAndSettle();

    expect(store.stateOf(1), _state(count: 1, total: 1));
    expect(
      store.stateOf(2),
      _state(count: 7, rounds: 2, total: 73, target: 33),
    );
    expect(store.selectedId, 2);
  });

  testWidgets('switching keeps both values', (tester) async {
    final store = _two();
    await _start(tester, store: store);
    await _chooseTesbihat(tester);
    await _taps(tester, 5);

    await _chooseDhikr(tester, 2);
    expect(_text(tester, find.byKey(const Key('dhikr-name'))), 'Sabah');
    expect(_text(tester, _value), '7');
    await tester.tap(_button);
    await tester.pump();
    expect(_text(tester, _value), '8');

    await _openPicker(tester);
    expect(tester.widget<ListTile>(_tesbihatRow).selected, isFalse);
    expect(
      tester.widget<ListTile>(find.byKey(const Key('dhikr-row-2'))).selected,
      isTrue,
    );
    await tester.tap(_tesbihatRow);
    await tester.pumpAndSettle();
    expect(_text(tester, _stepText), 'Sübhânallah');
    expect(_text(tester, _value), '5');
    expect(
      store.stateOf(2),
      _state(count: 8, rounds: 2, total: 74, target: 33),
    );
  });

  testWidgets('the empty state opens the tesbihat', (tester) async {
    await _start(tester, store: FakeDhikrStore([]));
    expect(find.text('Henüz zikir yok.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tesbihat-empty-open')));
    await tester.pumpAndSettle();
    expect(_text(tester, _stepText), 'Sübhânallah');
    await _taps(tester, 3);
    expect(_text(tester, _value), '3');
  });

  testWidgets('adding a dhikr from the tesbihat selects it', (tester) async {
    final store = FakeDhikrStore([]);
    await _start(tester, store: store);
    await tester.tap(find.byKey(const Key('tesbihat-empty-open')));
    await tester.pumpAndSettle();

    await _openPicker(tester);
    await tester.tap(find.byKey(const Key('dhikr-add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('dhikr-name-field')), 'Sabah');
    await tester.pump();
    await tester.tap(find.byKey(const Key('dhikr-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dhikr-picker')), findsNothing);
    expect(_text(tester, find.byKey(const Key('dhikr-name'))), 'Sabah');
    expect(_text(tester, _value), '0');
    expect(_stepText, findsNothing);
  });

  testWidgets('step semantics, live announcements and touch targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _start(
      tester,
      tesbihat: _at(const TesbihatState(count: DhikrCount(31))),
    );

    expect(
      find.bySemanticsLabel('Sübhânallah, adım 1/3, 31 / 33'),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(_stepText),
      isSemantics(label: 'Sübhânallah, adım 1/3', isLiveRegion: true),
    );
    expect(
      find.bySemanticsLabel(
        'Zikir: Namaz sonrası tesbihat. Değiştirmek için dokunun.',
      ),
      findsOneWidget,
    );

    await _taps(tester, 2);
    expect(
      tester.getSemantics(_stepText),
      isSemantics(label: 'Elhamdülillâh, adım 2/3', isLiveRegion: true),
    );

    for (final f in [_pickerButton, _undo, _reset, _button]) {
      final size = tester.getSize(f);
      expect(size.width, greaterThanOrEqualTo(48), reason: '$f');
      expect(size.height, greaterThanOrEqualTo(48), reason: '$f');
    }
    await _openPicker(tester);
    expect(tester.getSemantics(_tesbihatRow), isSemantics(isSelected: true));
    expect(tester.getSize(_tesbihatRow).height, greaterThanOrEqualTo(48));
    await tester.tapAt(const Offset(10, 10)); // close the picker
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await _start(
      tester,
      tesbihat: _at(
        const TesbihatState(step: 2, finished: true, completions: 1),
      ),
    );
    expect(
      tester.getSemantics(_finished),
      isSemantics(label: 'Tesbihat tamamlandı', isLiveRegion: true),
    );
    final restart = tester.getSize(_restart);
    expect(restart.width, greaterThanOrEqualTo(48));
    expect(restart.height, greaterThanOrEqualTo(48));
    semantics.dispose();
  });
}
