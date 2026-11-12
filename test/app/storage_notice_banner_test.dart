import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/storage_notice.dart';
import 'package:zikirmatik/features/counter/counter.dart';

import '../support/test_app.dart';

// Spec 0015 — Depolama hatası geri bildirimi: where and how the message shows
// (AC-8, AC-10).

const _mayBeLost =
    'Kaydedilemedi. Bu değişiklik uygulama kapanınca kaybolabilir.';

final _notice = find.byKey(const Key('storage-notice'));
final _button = find.byKey(const Key('counter-tap-area'));
final _fullOpen = find.byKey(const Key('full-screen-open'));
final _full = find.byKey(const Key('full-screen'));

const _phone = Size(400, 800);

void _screen(WidgetTester tester, {double scale = 1}) {
  tester.view.physicalSize = _phone;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

FakeDhikrStore _store() => FakeDhikrStore([
  ('Sabah', CounterState(count: const DhikrCount(7), total: 7)),
]);

Future<void> _start(WidgetTester tester, FakeDhikrStore store) async {
  await tester.pumpWidget(testApp(tester, store: store));
  await tester.pumpAndSettle();
}

void _report(WidgetTester tester, StorageNotice notice) =>
    ProviderScope.containerOf(
      tester.element(find.byType(ZikirmatikApp)),
    ).read(storageNoticeProvider.notifier).report(notice);

void main() {
  testWidgets('shows the three messages', (tester) async {
    _screen(tester);
    await _start(tester, _store());
    expect(_notice, findsNothing);

    for (final (notice, text) in const [
      (StorageNotice.mayBeLost, _mayBeLost),
      (StorageNotice.notSaved, 'Kaydedilemedi.'),
      (StorageNotice.tesbihatNotLoaded, 'Tesbihat yüklenemedi.'),
    ]) {
      _report(tester, notice);
      await tester.pump();
      expect(find.text(text), findsOneWidget);
      await tester.pump(storageNoticeDuration);
      expect(_notice, findsNothing);
    }
  });

  testWidgets('repeated failures show one message', (tester) async {
    _screen(tester);
    await _start(tester, _store());
    for (var i = 0; i < 3; i++) {
      _report(tester, StorageNotice.mayBeLost);
      _report(tester, StorageNotice.notSaved);
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(_notice, findsOneWidget);
    expect(find.text(_mayBeLost), findsOneWidget);
    expect(find.text('Kaydedilemedi.'), findsNothing);
  });

  testWidgets('closes by itself after about four seconds', (tester) async {
    _screen(tester);
    await _start(tester, _store());
    _report(tester, StorageNotice.mayBeLost);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3900));
    expect(_notice, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_notice, findsNothing);
  });

  testWidgets('shows in full screen and a tap on it counts', (tester) async {
    _screen(tester);
    final store = _store();
    await _start(tester, store);
    await tester.ensureVisible(_fullOpen);
    await tester.tap(_fullOpen);
    await tester.pumpAndSettle();
    expect(_full, findsOneWidget);

    _report(tester, StorageNotice.mayBeLost);
    await tester.pump();
    expect(_notice, findsOneWidget);
    expect(find.text(_mayBeLost), findsOneWidget);

    // The message is over the full screen tap area; a tap on it still counts.
    final at = tester.getCenter(_notice);
    expect(tester.getRect(_full).contains(at), isTrue);
    await tester.tapAt(at);
    await tester.pump();
    expect(store.stateOf(1).count.value, 8);
    await tester.tapAt(at);
    await tester.pump();
    expect(store.stateOf(1).count.value, 9);
    expect(_full, findsOneWidget);
  });

  testWidgets('is a live region', (tester) async {
    final semantics = tester.ensureSemantics();
    _screen(tester);
    await _start(tester, _store());
    _report(tester, StorageNotice.mayBeLost);
    await tester.pump();
    expect(
      tester.getSemantics(_notice),
      isSemantics(isLiveRegion: true, label: _mayBeLost),
    );
    semantics.dispose();
  });

  testWidgets('largest text is not clipped', (tester) async {
    _screen(tester, scale: 2);
    await _start(tester, _store());
    _report(tester, StorageNotice.mayBeLost);
    await tester.pump();

    expect(tester.takeException(), isNull);
    final rect = tester.getRect(_notice);
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(_phone.height));
    final text = find.descendant(of: _notice, matching: find.text(_mayBeLost));
    final paragraph = tester.renderObject<RenderParagraph>(text);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(paragraph.size.height, greaterThan(paragraph.preferredLineHeight));
    expect(rect.contains(tester.getTopLeft(text)), isTrue);
    expect(rect.contains(tester.getBottomRight(text)), isTrue);
  });

  testWidgets('does not cover the count button', (tester) async {
    for (final scale in const [1.0, 2.0]) {
      _screen(tester, scale: scale);
      await tester.pumpWidget(const SizedBox());
      await _start(tester, _store());
      _report(tester, StorageNotice.mayBeLost);
      await tester.pump();
      final button = tester.getRect(_button);
      final notice = tester.getRect(_notice);
      expect(
        button.overlaps(notice),
        isFalse,
        reason: '×$scale button $button notice $notice',
      );
      // Plan A-1: at the bottom like a snackbar; at the top only when at the
      // bottom it would cover the button (the largest text).
      expect(
        notice.center.dy > _phone.height / 2,
        scale == 1.0,
        reason: '×$scale notice $notice',
      );
      await tester.pump(storageNoticeDuration);
    }
  });

  testWidgets('does not cover the count button after a sheet closes under it', (
    tester,
  ) async {
    // Review round 1, F-1: the message shows while the picker is open (no
    // count button on the current route), then the picker closes and the
    // button is back under it.
    _screen(tester, scale: 2);
    await tester.pumpWidget(
      testApp(
        tester,
        store: _store(),
        tesbihat: FakeTesbihatRepository()..failWrites = true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dhikr-picker-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tesbihat-row')));
    await tester.pumpAndSettle();

    expect(find.text(_mayBeLost), findsOneWidget);
    final button = tester.getRect(_button);
    final notice = tester.getRect(_notice);
    expect(
      button.overlaps(notice),
      isFalse,
      reason: 'button $button notice $notice',
    );
  });

  testWidgets('stays at the bottom in full screen with the largest text', (
    tester,
  ) async {
    // The device's count button is under the full screen page, not shown.
    _screen(tester, scale: 2);
    await _start(tester, _store());
    await tester.ensureVisible(_fullOpen);
    await tester.tap(_fullOpen);
    await tester.pumpAndSettle();
    _report(tester, StorageNotice.mayBeLost);
    await tester.pump();
    final notice = tester.getRect(_notice);
    expect(notice.bottom, greaterThan(_phone.height - 40), reason: '$notice');
  });
}
