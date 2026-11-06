import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat.dart';

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
}
