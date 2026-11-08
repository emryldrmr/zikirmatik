import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/database/app_database.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/ui/device_parts.dart'
    show deviceBodyColor, deviceBodyText;

import '../../../support/test_app.dart';

// Spec 0002 — Cihaz sayaç ekranı.

final _device = find.byKey(const Key('counter-device'));
final _lcd = find.byKey(const Key('counter-lcd'));
final _value = find.byKey(const Key('counter-value'));
final _button = find.byKey(const Key('counter-tap-area'));
final _targetButton = find.byKey(const Key('counter-target'));
final _total = find.byKey(const Key('counter-total'));
final _undo = find.byKey(const Key('counter-undo'));
final _reset = find.byKey(const Key('counter-reset'));
final _dialog = find.byKey(const Key('confirm-dialog'));

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

Future<FakeCounterRepository> _pump(
  WidgetTester tester,
  CounterState state, {
  FakeHaptics? haptics,
}) async {
  final repo = FakeCounterRepository(state: state);
  await tester.pumpWidget(testApp(tester, repo: repo, haptics: haptics));
  await tester.pump();
  return repo;
}

Future<void> _pick(WidgetTester tester, String optionKey) async {
  await tester.tap(_targetButton);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(optionKey)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the device with no target, count 0, total 0', (
    tester,
  ) async {
    await _pump(tester, CounterState.initial);

    expect(_device, findsOneWidget);
    expect(_lcd, findsOneWidget);
    expect(_text(tester, _value), '0');
    expect(_targetText(tester), 'Hedef yok');
    expect(_text(tester, _total), 'Toplam 0');
    expect(_undo, findsOneWidget);
    expect(_reset, findsOneWidget);
    expect(_button, findsOneWidget);
  });

  testWidgets('button taps count, rapid taps included', (tester) async {
    final repo = await _pump(tester, CounterState.initial);

    await tester.tap(_button);
    await tester.tap(_button);
    await tester.tap(_button);
    await tester.pump();

    expect(_text(tester, _value), '3');
    expect(_text(tester, _total), 'Toplam 3');
    expect(repo.stored, _state(count: 3, total: 3));
  });

  testWidgets('taps while a save is still running are all counted', (
    tester,
  ) async {
    // VERIFY round 1, G-1: on a device the save takes real time; taps that
    // arrive meanwhile must neither be dropped nor reordered.
    final repo = FakeCounterRepository()..holdSave = Completer<void>();
    await tester.pumpWidget(testApp(tester, repo: repo));
    await tester.pump();

    await tester.tap(_button);
    await tester.tap(_button);
    await tester.tap(_button);
    await tester.pump();

    expect(_text(tester, _value), '3');
    expect(_text(tester, _total), 'Toplam 3');
    expect(repo.saves.map((s) => s.total), [1, 2, 3]);

    repo.holdSave!.complete();
    await tester.pump();
    expect(repo.stored, _state(count: 3, total: 3));
  });

  testWidgets('tapping the device body does not count', (tester) async {
    final repo = await _pump(tester, CounterState.initial);

    await tester.tap(_lcd);
    await tester.tap(_total);
    await tester.tapAt(tester.getTopLeft(_device) + const Offset(20, 20));
    await tester.pump();

    expect(_text(tester, _value), '0');
    expect(_text(tester, _total), 'Toplam 0');
    expect(repo.saves, isEmpty);
  });

  testWidgets('preset targets can be chosen', (tester) async {
    final repo = await _pump(tester, CounterState.initial);

    for (final preset in [33, 99, 100]) {
      await _pick(tester, 'target-option-$preset');
      expect(_dialog, findsNothing); // nothing to lose at count 0
      expect(_targetText(tester), 'Hedef $preset · Tur 0');
      expect(repo.stored.target, Target.of(preset));
    }

    await _pick(tester, 'target-option-none');
    expect(_targetText(tester), 'Hedef yok');
    expect(repo.stored.target, isNull);
  });

  testWidgets('custom target accepts bounds and rejects invalid input', (
    tester,
  ) async {
    final repo = await _pump(tester, _state(target: 33));
    final field = find.byKey(const Key('custom-target-field'));
    final save = find.byKey(const Key('custom-target-save'));
    bool saveEnabled() => tester.widget<FilledButton>(save).onPressed != null;

    Future<void> openCustom() async {
      await tester.tap(_targetButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('target-option-custom')));
      await tester.pumpAndSettle();
    }

    await openCustom();
    for (final bad in ['0', '100001', '', 'abc', '0x21', '+33']) {
      await tester.enterText(field, bad);
      await tester.pump();
      expect(
        find.text('1 ile 100.000 arasında bir sayı girin.'),
        findsOneWidget,
        reason: 'input "$bad"',
      );
      expect(saveEnabled(), isFalse, reason: 'input "$bad"');
    }
    // Leaving with invalid input changes nothing.
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5)); // close the sheet
    await tester.pumpAndSettle();
    expect(_targetText(tester), 'Hedef 33 · Tur 0');
    expect(repo.saves, isEmpty);

    for (final (input, shown) in [('1', '1'), ('100000', '100.000')]) {
      await openCustom();
      await tester.enterText(field, input);
      await tester.pump();
      expect(saveEnabled(), isTrue);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(_targetText(tester), 'Hedef $shown · Tur 0');
      expect(repo.stored.target, Target.of(int.parse(input)));
    }
  });

  testWidgets('reaching the target vibrates once and completes a round', (
    tester,
  ) async {
    final haptics = FakeHaptics();
    final repo = await _pump(
      tester,
      _state(count: 32, total: 32, target: 33),
      haptics: haptics,
    );

    await tester.tap(_button);
    await tester.pump();

    expect(haptics.roundsCompleted, 1);
    expect(_text(tester, _value), '0');
    expect(_targetText(tester), 'Hedef 33 · Tur 1');
    expect(_text(tester, _total), 'Toplam 33');
    expect(repo.stored, _state(rounds: 1, total: 33, target: 33));

    await tester.tap(_button); // the next tap is an ordinary one
    await tester.pump();
    expect(haptics.roundsCompleted, 1);
    expect(_text(tester, _value), '1');
  });

  testWidgets('a tap during a slow vibration is stored in order', (
    tester,
  ) async {
    // Review round 1, F-1: the round's save must not wait for the vibration.
    final haptics = FakeHaptics()..hold = Completer<void>();
    final repo = await _pump(
      tester,
      _state(count: 32, total: 32, target: 33),
      haptics: haptics,
    );

    await tester.tap(_button); // completes the round; vibration still running
    await tester.tap(_button); // the next tap
    await tester.pump();
    haptics.hold!.complete();
    await tester.pump();

    expect(_text(tester, _value), '1');
    expect(repo.stored, _state(count: 1, rounds: 1, total: 34, target: 33));
    expect(repo.saves.map((s) => s.total), [33, 34]);
  });

  testWidgets('a failing vibration does not stop counting or saving', (
    tester,
  ) async {
    final haptics = FakeHaptics()..fail = true;
    final repo = await _pump(
      tester,
      _state(count: 32, total: 32, target: 33),
      haptics: haptics,
    );

    await tester.tap(_button);
    await tester.pump();

    expect(haptics.roundsCompleted, 1);
    expect(_targetText(tester), 'Hedef 33 · Tur 1');
    expect(repo.stored, _state(rounds: 1, total: 33, target: 33));
  });

  testWidgets('without a target no round and no vibration', (tester) async {
    final haptics = FakeHaptics();
    await _pump(tester, _state(count: 32, total: 32), haptics: haptics);

    await tester.tap(_button);
    await tester.pump();

    expect(haptics.roundsCompleted, 0);
    expect(_text(tester, _value), '33');
    expect(_targetText(tester), 'Hedef yok');
  });

  testWidgets('undo decrements and is disabled at zero', (tester) async {
    final repo = await _pump(tester, _state(count: 2, total: 10));
    bool undoEnabled() => tester.widget<IconButton>(_undo).onPressed != null;

    await tester.tap(_undo);
    await tester.pump();
    expect(_text(tester, _value), '1');
    expect(_text(tester, _total), 'Toplam 9');

    await tester.tap(_undo);
    await tester.pump();
    expect(_text(tester, _value), '0');
    expect(_text(tester, _total), 'Toplam 8');
    expect(undoEnabled(), isFalse);

    final savesBefore = repo.saves.length;
    await tester.tap(_undo, warnIfMissed: false);
    await tester.pump();
    expect(_text(tester, _value), '0');
    expect(_text(tester, _total), 'Toplam 8');
    expect(repo.saves.length, savesBefore);
  });

  testWidgets('undo right after a completed round does nothing', (
    tester,
  ) async {
    final repo = await _pump(tester, _state(count: 32, total: 32, target: 33));

    await tester.tap(_button); // completes round 1, count back to 0
    await tester.pump();
    expect(tester.widget<IconButton>(_undo).onPressed, isNull);
    await tester.tap(_undo, warnIfMissed: false);
    await tester.pump();

    expect(_targetText(tester), 'Hedef 33 · Tur 1');
    expect(repo.stored, _state(rounds: 1, total: 33, target: 33));
  });

  testWidgets('reset asks and keeps total and target', (tester) async {
    final repo = await _pump(
      tester,
      _state(count: 5, rounds: 2, total: 71, target: 33),
    );

    await tester.tap(_reset);
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);
    expect(find.text('Sayaç sıfırlansın mı?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-ok')));
    await tester.pumpAndSettle();

    expect(_text(tester, _value), '0');
    expect(_targetText(tester), 'Hedef 33 · Tur 0');
    expect(_text(tester, _total), 'Toplam 71');
    expect(repo.stored, _state(total: 71, target: 33));
  });

  testWidgets('reset cancel changes nothing', (tester) async {
    final repo = await _pump(
      tester,
      _state(count: 5, rounds: 2, total: 71, target: 33),
    );

    await tester.tap(_reset);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-cancel')));
    await tester.pumpAndSettle();

    expect(_text(tester, _value), '5');
    expect(_targetText(tester), 'Hedef 33 · Tur 2');
    expect(repo.saves, isEmpty);
  });

  testWidgets('target change asks when progress exists', (tester) async {
    final repo = await _pump(tester, _state(count: 5, total: 40, target: 33));

    await _pick(tester, 'target-option-99');
    expect(
      find.text('Hedef değişirse sayım ve tur sıfırlanır.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('confirm-ok')));
    await tester.pumpAndSettle();

    expect(_targetText(tester), 'Hedef 99 · Tur 0');
    expect(_text(tester, _value), '0');
    expect(_text(tester, _total), 'Toplam 40');
    expect(repo.stored, _state(total: 40, target: 99));
  });

  testWidgets('target change asks when only rounds exist', (tester) async {
    await _pump(tester, _state(rounds: 1, total: 33, target: 33));

    await _pick(tester, 'target-option-none');
    expect(_dialog, findsOneWidget);
  });

  testWidgets('target change cancel keeps everything', (tester) async {
    final repo = await _pump(
      tester,
      _state(count: 5, rounds: 1, total: 38, target: 33),
    );

    await _pick(tester, 'target-option-100');
    await tester.tap(find.byKey(const Key('confirm-cancel')));
    await tester.pumpAndSettle();

    expect(_targetText(tester), 'Hedef 33 · Tur 1');
    expect(_text(tester, _value), '5');
    expect(_text(tester, _total), 'Toplam 38');
    expect(repo.saves, isEmpty);
  });

  testWidgets('target change at zero does not ask', (tester) async {
    final repo = await _pump(tester, _state(total: 40, target: 33));

    await _pick(tester, 'target-option-99');

    expect(_dialog, findsNothing);
    expect(_targetText(tester), 'Hedef 99 · Tur 0');
    expect(repo.stored, _state(total: 40, target: 99));
  });

  testWidgets('restart shows persisted state', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.runAsync(
      () => DriftCounterRepository(
        db,
      ).save(_state(count: 31, rounds: 3, total: 130, target: 33)),
    );

    Future<void> start() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          testApp(tester, repo: DriftCounterRepository(db)),
        );
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pump();
    }

    await start();
    await tester.tap(_button);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    await tester.pumpWidget(const SizedBox()); // "restart"
    await start();

    expect(_text(tester, _value), '32');
    expect(_targetText(tester), 'Hedef 33 · Tur 3');
    expect(_text(tester, _total), 'Toplam 131');
  });

  testWidgets('loading and error show no device and change nothing', (
    tester,
  ) async {
    final loading = FakeCounterRepository(stored: 5)
      ..holdLoad = Completer<void>();
    await tester.pumpWidget(testApp(tester, repo: loading));
    await tester.pump();
    expect(_device, findsNothing);
    await tester.tap(find.byType(Scaffold), warnIfMissed: false);
    await tester.pump();
    expect(loading.saves, isEmpty);
    loading.holdLoad!.complete();
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
    final failing = FakeCounterRepository(stored: 5, failLoad: true);
    await tester.pumpWidget(testApp(tester, repo: failing));
    await tester.pump();
    await tester.pump();
    expect(_device, findsNothing);
    expect(find.text('Sayaç yüklenemedi.'), findsOneWidget);
    await tester.tap(find.byType(Scaffold), warnIfMissed: false);
    await tester.pump();
    expect(failing.saves, isEmpty);
  });

  testWidgets('semantics labels and touch targets', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, _state(count: 3, total: 3));

    expect(
      find.bySemanticsLabel('Sayım 3. Saymak için dokunun.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Geri al'), findsOneWidget);
    expect(find.bySemanticsLabel('Sıfırla'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Hedef: yok. Değiştirmek için dokunun.'),
      findsOneWidget,
    );
    for (final f in [_button, _undo, _reset, _targetButton]) {
      final size = tester.getSize(f);
      expect(size.width, greaterThanOrEqualTo(48), reason: '$f');
      expect(size.height, greaterThanOrEqualTo(48), reason: '$f');
    }

    await _pick(tester, 'target-option-33');
    await tester.tap(find.byKey(const Key('confirm-ok')));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel('Hedef: 33. Değiştirmek için dokunun.'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('total uses Turkish thousands separator', (tester) async {
    await _pump(tester, _state(count: 7, rounds: 37, total: 1250, target: 33));

    expect(_text(tester, _total), 'Toplam 1.250');
  });

  // Spec 0013, CB-1 and CB-3.
  testWidgets('the target row looks tappable', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _pump(tester, CounterState.initial);

    final icon = find.descendant(
      of: _targetButton,
      matching: find.byKey(const Key('counter-target-icon')),
    );
    Color frame() {
      final material = tester.widget<Material>(
        find.descendant(of: _targetButton, matching: find.byType(Material)),
      );
      return (material.shape! as OutlinedBorder).side.color;
    }

    Color iconColor() => tester.widget<Icon>(icon).color!;

    expect(tester.widget<Icon>(icon).icon, Icons.arrow_drop_down);
    expect(_targetText(tester), 'Hedef yok');
    expect(frame(), deviceBodyText);
    expect(iconColor(), deviceBodyText);
    expect(_contrast(frame(), deviceBodyColor), greaterThanOrEqualTo(3));

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(frame(), deviceBodyText);
    expect(iconColor(), deviceBodyText);

    await _pick(tester, 'target-option-33');
    expect(_targetText(tester), 'Hedef 33 · Tur 0');
    expect(icon, findsOneWidget);
  });

  // Plan 0013, R2: the frame and ▾ never push the longest row out.
  testWidgets('a long target row fits a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(
      tester,
      _state(count: 5, rounds: 99999, total: 999999, target: Target.max),
    );

    expect(tester.takeException(), isNull);
    expect(_targetButton, findsOneWidget);
    expect(find.byKey(const Key('counter-target-icon')), findsOneWidget);
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}
