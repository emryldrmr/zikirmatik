import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat.dart';

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
}
