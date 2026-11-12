import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/storage_notice.dart';
import 'package:zikirmatik/features/counter/counter.dart';

import '../../../support/test_app.dart';

// Spec 0015 — Depolama hatası geri bildirimi: the counting group on the
// counter and the tesbihat (AC-1, AC-2, AC-3, AC-9).

const _mayBeLost =
    'Kaydedilemedi. Bu değişiklik uygulama kapanınca kaybolabilir.';
const _tesbihatNotLoaded = 'Tesbihat yüklenemedi.';

final _button = find.byKey(const Key('counter-tap-area'));
final _value = find.byKey(const Key('counter-value'));
final _total = find.byKey(const Key('counter-total'));
final _undo = find.byKey(const Key('counter-undo'));
final _reset = find.byKey(const Key('counter-reset'));
final _notice = find.byKey(const Key('storage-notice'));
final _pickerButton = find.byKey(const Key('dhikr-picker-button'));
final _tesbihatRow = find.byKey(const Key('tesbihat-row'));
final _stepText = find.byKey(const Key('tesbihat-text'));
final _tesbihatUndo = find.byKey(const Key('tesbihat-undo'));
final _tesbihatReset = find.byKey(const Key('tesbihat-reset'));
final _tesbihatRestart = find.byKey(const Key('tesbihat-restart'));

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

FakeDhikrStore _sabah({int count = 7, int total = 7}) => FakeDhikrStore([
  ('Sabah', CounterState(count: DhikrCount(count), total: total)),
]);

FakeCounterRepository _counter(FakeDhikrStore store) =>
    store.counters[1]! as FakeCounterRepository;

Future<void> _start(
  WidgetTester tester, {
  required FakeDhikrStore store,
  FakeTesbihatRepository? tesbihat,
}) async {
  await tester.pumpWidget(testApp(tester, store: store, tesbihat: tesbihat));
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f, [int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(f);
    await tester.pump();
  }
}

Future<void> _confirm(WidgetTester tester, Finder button, String ok) async {
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.text(ok).last);
  await tester.pumpAndSettle();
}

/// Waits until the message has closed by itself.
Future<void> _noticeGone(WidgetTester tester) async {
  await tester.pump(storageNoticeDuration);
  expect(_notice, findsNothing);
}

void main() {
  testWidgets('failed tap save keeps the count and keeps counting', (
    tester,
  ) async {
    final store = _sabah();
    await _start(tester, store: store);
    _counter(store).failWrites = true;

    await _tap(tester, _button);
    expect(_text(tester, _value), '8');
    expect(find.text(_mayBeLost), findsOneWidget);

    await _tap(tester, _button, 3);
    expect(_text(tester, _value), '11');
    expect(_text(tester, _total), contains('11'));
    expect(_notice, findsOneWidget); // not repeated (AC-8)
    expect(store.stateOf(1).count.value, 7); // nothing was stored
  });

  testWidgets('failed undo and reset keep the screen', (tester) async {
    final store = _sabah();
    await _start(tester, store: store);
    _counter(store).failWrites = true;

    await _tap(tester, _undo);
    expect(_text(tester, _value), '6');
    expect(find.text(_mayBeLost), findsOneWidget);
    await _noticeGone(tester);

    await _confirm(tester, _reset, 'Sıfırla');
    expect(_text(tester, _value), '0');
    expect(find.text(_mayBeLost), findsOneWidget);
    expect(store.stateOf(1).count.value, 7);
  });

  testWidgets('next good save stores what the screen shows after restart', (
    tester,
  ) async {
    final store = _sabah();
    await _start(tester, store: store);
    _counter(store).failWrites = true;
    await _tap(tester, _button, 2);
    expect(_text(tester, _value), '9');
    expect(store.stateOf(1).count.value, 7);

    _counter(store).failWrites = false;
    await _tap(tester, _button);
    expect(_text(tester, _value), '10');

    // Restart: a new app on the same storage.
    await tester.pumpWidget(const SizedBox());
    await _start(tester, store: store);
    expect(_text(tester, _value), '10');
    expect(_text(tester, _total), contains('10'));
    expect(_notice, findsNothing);
  });

  testWidgets('failed tesbihat start, tap, undo and restart keep the screen', (
    tester,
  ) async {
    final tesbihat = FakeTesbihatRepository()..failWrites = true;
    await _start(tester, store: _sabah(), tesbihat: tesbihat);

    // Start: "Tesbihat çek" from the picker.
    await tester.tap(_pickerButton);
    await tester.pumpAndSettle();
    await tester.tap(_tesbihatRow);
    await tester.pumpAndSettle();
    expect(_text(tester, _stepText), 'Sübhânallah');
    expect(find.text(_mayBeLost), findsOneWidget);
    await _noticeGone(tester);

    await _tap(tester, _button, 3);
    expect(_text(tester, _value), '3');
    expect(find.text(_mayBeLost), findsOneWidget);
    await _noticeGone(tester);

    await _tap(tester, _tesbihatUndo);
    expect(_text(tester, _value), '2');
    expect(find.text(_mayBeLost), findsOneWidget);
    await _noticeGone(tester);

    await _confirm(tester, _tesbihatReset, 'Sıfırla');
    expect(_text(tester, _value), '0');
    expect(find.text(_mayBeLost), findsOneWidget);
    await _noticeGone(tester);

    // "Baştan başla" on a finished tesbihat (99 taps).
    await _tap(tester, _button, 99);
    expect(_tesbihatRestart, findsOneWidget);
    await _noticeGone(tester);
    await tester.tap(_tesbihatRestart);
    await tester.pumpAndSettle();
    expect(_text(tester, _stepText), 'Sübhânallah');
    expect(find.text(_mayBeLost), findsOneWidget);

    expect(tesbihat.stored, TesbihatState.initial); // nothing was stored
  });

  testWidgets('unreadable tesbihat says so and the counter still counts', (
    tester,
  ) async {
    final store = _sabah();
    await _start(
      tester,
      store: store,
      tesbihat: FakeTesbihatRepository(failLoad: true),
    );
    expect(_text(tester, _value), '7');

    await tester.tap(_pickerButton);
    await tester.pumpAndSettle();
    await tester.tap(_tesbihatRow);
    await tester.pumpAndSettle();
    expect(find.text(_tesbihatNotLoaded), findsOneWidget);
    expect(_stepText, findsNothing); // the tesbihat did not open

    await _tap(tester, _button, 2);
    expect(_text(tester, _value), '9');
    expect(store.stateOf(1).count.value, 9);
    await _noticeGone(tester);

    // From the empty list's "Tesbihat çek" too.
    await tester.pumpWidget(const SizedBox());
    await _start(
      tester,
      store: FakeDhikrStore([]),
      tesbihat: FakeTesbihatRepository(failLoad: true),
    );
    await tester.tap(find.byKey(const Key('tesbihat-empty-open')));
    await tester.pumpAndSettle();
    expect(find.text(_tesbihatNotLoaded), findsOneWidget);
    expect(_stepText, findsNothing);
    expect(find.byKey(const Key('dhikr-empty')), findsOneWidget);
  });
}
