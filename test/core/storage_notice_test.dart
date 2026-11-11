import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/storage_notice.dart';

// Spec 0015 — Depolama hatası geri bildirimi: the shared message state
// (AC-8, Req 7). testWidgets for its fake clock.

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  StorageNotice? shown() => container.read(storageNoticeProvider);
  void report(StorageNotice n) =>
      container.read(storageNoticeProvider.notifier).report(n);

  test('nothing is shown at first', () {
    expect(shown(), isNull);
  });

  testWidgets('a visible notice is not repeated', (tester) async {
    report(StorageNotice.mayBeLost);
    await tester.pump(const Duration(seconds: 3));
    report(StorageNotice.mayBeLost);
    report(StorageNotice.notSaved); // another kind does not replace it
    expect(shown(), StorageNotice.mayBeLost);
    // Not extended: it closes four seconds after the first failure.
    await tester.pump(const Duration(seconds: 1));
    expect(shown(), isNull);
  });

  testWidgets('closes by itself after four seconds', (tester) async {
    report(StorageNotice.notSaved);
    await tester.pump(const Duration(milliseconds: 3999));
    expect(shown(), StorageNotice.notSaved);
    await tester.pump(const Duration(milliseconds: 1));
    expect(shown(), isNull);
  });

  testWidgets('the first failure after it closes shows again', (tester) async {
    report(StorageNotice.mayBeLost);
    await tester.pump(storageNoticeDuration);
    expect(shown(), isNull);
    report(StorageNotice.tesbihatNotLoaded);
    expect(shown(), StorageNotice.tesbihatNotLoaded);
    await tester.pump(storageNoticeDuration);
    expect(shown(), isNull);
  });
}
