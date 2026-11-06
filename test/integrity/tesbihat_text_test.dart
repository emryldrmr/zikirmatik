import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat.dart';

// Sensitive area: Dini metin bütünlüğü (docs/testing.md, "Hassas alan").
// Spec 0006, Requirements 1 / AC-2: the steps of "Namaz sonrası tesbihat",
// their order and targets, byte for byte as in the spec's source table
// (Müslim, Mesâcid 146; spelling: Diyanet İşleri Başkanlığı).
//
// The expected text uses ASCII escapes for every non-ASCII letter (precomposed
// U+00FC ü, U+00E2 â), so an editor's normalization (e.g. "â" as "a" + U+0302)
// cannot slip past the test.

const _expected = <(String, int)>[
  ('Sübhânallah', 33), // Sübhânallah
  ('Elhamdülillâh', 33), // Elhamdülillâh
  ('Allâhu ekber', 33), // Allâhu ekber
];

void main() {
  test('the steps match the source table byte for byte', () {
    final steps = namazSonrasiTesbihat.steps;
    expect(steps.length, _expected.length);
    for (var i = 0; i < steps.length; i++) {
      final (text, target) = _expected[i];
      expect(steps[i].text.codeUnits, text.codeUnits, reason: 'step ${i + 1}');
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
