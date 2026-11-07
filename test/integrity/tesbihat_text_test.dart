import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/hand_layout.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../support/test_app.dart';

// Sensitive area: Dini metin bütünlüğü (docs/testing.md, "Hassas alan").
// Spec 0006, Requirements 1 / AC-2: the steps of "Namaz sonrası tesbihat",
// their order and targets, byte for byte as in the spec's source table
// (Müslim, Mesâcid 146; spelling: Diyanet İşleri Başkanlığı).
//
// The expected text is written as Unicode code point numbers (0xFC is the
// precomposed "ü", 0xE2 the precomposed "â"), never as letters or string
// escapes, so no editor or tool normalization (e.g. "â" as "a" + U+0302) can
// change both sides at once and slip past the test (review round 1, F-1).

// dart format off
const _expected = <(List<int>, int)>[
  // Sübhânallah
  ([0x53, 0xFC, 0x62, 0x68, 0xE2, 0x6E, 0x61, 0x6C, 0x6C, 0x61, 0x68], 33),
  // Elhamdülillâh
  ([0x45, 0x6C, 0x68, 0x61, 0x6D, 0x64, 0xFC, 0x6C, 0x69, 0x6C, 0x6C, 0xE2, 0x68], 33),
  // Allâhu ekber
  ([0x41, 0x6C, 0x6C, 0xE2, 0x68, 0x75, 0x20, 0x65, 0x6B, 0x62, 0x65, 0x72], 33),
];
// dart format on

void main() {
  test('the steps match the source table byte for byte', () {
    final steps = namazSonrasiTesbihat.steps;
    expect(steps.length, _expected.length);
    for (var i = 0; i < steps.length; i++) {
      final (codePoints, target) = _expected[i];
      expect(steps[i].text.runes.toList(), codePoints, reason: 'step ${i + 1}');
      expect(steps[i].target.value, target, reason: 'step ${i + 1}');
    }
  });

  test('the sequence cannot be changed at runtime', () {
    expect(
      () => namazSonrasiTesbihat.steps.add(namazSonrasiTesbihat.steps.first),
      throwsUnsupportedError,
    );
  });

  // Spec 0010, AC-5 (BR-12): full screen shows each step's text exactly as
  // stored — never cut, also on a small screen.
  testWidgets('full screen shows the step text unchanged', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();

    final steps = namazSonrasiTesbihat.steps;
    for (var i = 0; i < steps.length; i++) {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        testApp(
          tester,
          tesbihat: FakeTesbihatRepository(
            stored: TesbihatState(step: i, selected: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final open = find.byKey(const Key('full-screen-open'));
      await tester.ensureVisible(open);
      await tester.tap(open);
      await tester.pumpAndSettle();

      final (codePoints, _) = _expected[i];
      final text = tester.widget<Text>(
        find.byKey(const Key('full-screen-step-text')),
      );
      expect(text.data!.runes.toList(), codePoints, reason: 'step ${i + 1}');
      expect(text.maxLines, isNull, reason: 'step ${i + 1}');
      expect(text.overflow, isNull, reason: 'step ${i + 1}');
      expect(text.softWrap, isNot(isFalse), reason: 'step ${i + 1}');
      expect(tester.takeException(), isNull, reason: 'step ${i + 1}');
      // A screen reader hears the whole text too.
      expect(
        find.bySemanticsLabel(
          RegExp('^${RegExp.escape(String.fromCharCodes(codePoints))}, '),
        ),
        findsWidgets,
        reason: 'step ${i + 1}',
      );
    }
    semantics.dispose();
  });

  // Spec 0010, AC-5 (BR-12), review round 1 F-1: on a phone held upright and
  // with large text, the step's text stays readable — never shrunk away.
  testWidgets('full screen step text stays readable large', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final steps = namazSonrasiTesbihat.steps;
    for (final size in const [Size(393, 852), Size(360, 640), Size(320, 480)]) {
      for (final scale in const [1.0, 1.3, 2.0]) {
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        for (var i = 0; i < steps.length; i++) {
          final why = '$size × $scale, step ${i + 1}';
          await tester.pumpWidget(const SizedBox());
          await tester.pumpWidget(
            testApp(
              tester,
              tesbihat: FakeTesbihatRepository(
                stored: TesbihatState(step: i, selected: true),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final open = find.byKey(const Key('full-screen-open'));
          await tester.ensureVisible(open);
          await tester.pumpAndSettle();
          tester.takeException(); // the normal screen is not under test here
          await tester.tap(open);
          await tester.pumpAndSettle();

          final text = find.byKey(const Key('full-screen-step-text'));
          expect(
            tester.widget<Text>(text).data!.runes.toList(),
            _expected[i].$1,
            reason: why,
          );
          // The painted text: at least a normal body line tall, all on screen.
          final rect = Rect.fromPoints(
            tester.getTopLeft(text),
            tester.getBottomRight(text),
          );
          expect(rect.height, greaterThanOrEqualTo(20), reason: why);
          expect(rect.left, greaterThanOrEqualTo(0), reason: why);
          expect(rect.right, lessThanOrEqualTo(size.width), reason: why);
          expect(rect.bottom, lessThanOrEqualTo(size.height), reason: why);
          expect(tester.takeException(), isNull, reason: why);
        }
      }
    }
  });

  // Spec 0011, AC-8 (BR-12): with every display option — large digits, each
  // hand — the step's text is exactly as stored and whole, on the normal
  // screen and in full screen, upright, with large text.
  testWidgets('step text unchanged in every display combination', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final steps = namazSonrasiTesbihat.steps;
    for (final size in const [Size(400, 800), Size(320, 480)]) {
      for (final scale in const [1.0, 2.0]) {
        for (final large in const [false, true]) {
          for (final hand in HandLayout.values) {
            tester.view.physicalSize = size;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            for (var i = 0; i < steps.length; i++) {
              final why = '$size ×$scale large:$large $hand step ${i + 1}';
              await tester.pumpWidget(const SizedBox());
              await tester.pumpWidget(
                testApp(
                  tester,
                  tesbihat: FakeTesbihatRepository(
                    stored: TesbihatState(step: i, selected: true),
                  ),
                  settings: FakeSettingsRepository(
                    stored: AppSettings.defaults.copyWith(
                      largeCount: large,
                      handLayout: hand,
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();

              // The normal screen.
              final normal = find.byKey(const Key('tesbihat-text'));
              await tester.ensureVisible(normal);
              await tester.pumpAndSettle();
              _expectWholeText(tester, normal, _expected[i].$1, size, why);

              // Full screen.
              final open = find.byKey(const Key('full-screen-open'));
              await tester.ensureVisible(open);
              await tester.pumpAndSettle();
              await tester.tap(open);
              await tester.pumpAndSettle();
              _expectWholeText(
                tester,
                find.byKey(const Key('full-screen-step-text')),
                _expected[i].$1,
                size,
                why,
              );
              expect(tester.takeException(), isNull, reason: why);
            }
          }
        }
      }
    }
  });
}

/// The text on screen is the stored one byte for byte, never cut or
/// shortened, readable, and within the screen's width.
void _expectWholeText(
  WidgetTester tester,
  Finder f,
  List<int> codePoints,
  Size screen,
  String why,
) {
  final text = tester.widget<Text>(f);
  expect(text.data!.runes.toList(), codePoints, reason: why);
  expect(text.maxLines, isNull, reason: why);
  expect(text.overflow, isNull, reason: why);
  expect(text.softWrap, isNot(isFalse), reason: why);
  final rect = Rect.fromPoints(tester.getTopLeft(f), tester.getBottomRight(f));
  expect(rect.height, greaterThanOrEqualTo(20), reason: why);
  expect(rect.left, greaterThanOrEqualTo(0), reason: why);
  expect(rect.right, lessThanOrEqualTo(screen.width), reason: why);
}
