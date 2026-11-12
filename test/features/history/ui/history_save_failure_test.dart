import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/core/storage_notice.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/history/history.dart';

import '../../../support/test_app.dart';

// Spec 0015 — Depolama hatası geri bildirimi: the daily count (AC-5).

const _mayBeLost =
    'Kaydedilemedi. Bu değişiklik uygulama kapanınca kaybolabilir.';

final _button = find.byKey(const Key('counter-tap-area'));
final _undo = find.byKey(const Key('counter-undo'));
final _value = find.byKey(const Key('counter-value'));
final _total = find.byKey(const Key('counter-total'));
final _notice = find.byKey(const Key('storage-notice'));

/// A history whose writes throw instead of returning an error.
class _ThrowingHistory extends FakeHistoryRepository {
  @override
  Future<Result<void>> add(Day day) async => throw StateError('disk gone');

  @override
  Future<Result<void>> remove(Day day) async => throw StateError('disk gone');
}

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

Future<void> _tap(WidgetTester tester, Finder f, [int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(f);
    await tester.pump();
  }
}

void main() {
  testWidgets('failed daily count write warns and counting goes on', (
    tester,
  ) async {
    for (final history in [
      FakeHistoryRepository()..failWrites = true,
      _ThrowingHistory(),
    ]) {
      final store = FakeDhikrStore([
        ('Zikir', CounterState(count: const DhikrCount(4), total: 4)),
      ]);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(testApp(tester, store: store, history: history));
      await tester.pumpAndSettle();

      await _tap(tester, _button);
      expect(find.text(_mayBeLost), findsOneWidget);
      await _tap(tester, _button, 2);
      expect(_text(tester, _value), '7');
      expect(_text(tester, _total), contains('7'));
      expect(store.stateOf(1).count.value, 7); // the counter itself is stored
      expect(_notice, findsOneWidget);

      await tester.pump(storageNoticeDuration);
      expect(_notice, findsNothing);
      await _tap(tester, _undo); // a taken-back tap fails the same way
      expect(_text(tester, _value), '6');
      expect(store.stateOf(1).count.value, 6);
      expect(find.text(_mayBeLost), findsOneWidget);
      expect(history.stored, isEmpty);
      await tester.pump(storageNoticeDuration);
    }
  });
}
