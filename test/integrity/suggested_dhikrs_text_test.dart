import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/suggested/suggested.dart';

// Sensitive area: Dini metin bütünlüğü (docs/testing.md, "Hassas alan").
// Spec 0008, Requirements 1–2, 4 / AC-2, AC-3: the 7 dhikrs of
// assets/data/suggested_dhikrs.json, byte for byte as in the spec's approved
// table (sources: spec 0008, Requirements 2; accessed 2026-11-07).
//
// For each dhikr and text field the expected value is the CRC-32 of its UTF-8
// bytes and its number of code points (plan 0008, R2). They were computed
// once, from the approved spec table, outside the repo. Numbers, not letters:
// no editor or tool normalization (e.g. NFD) can change both sides at once
// (plan 0006, F-1). Any changed byte turns this test red and names the entry
// and field.

/// CRC-32 (IEEE 802.3), the same as zlib's. A copy of the one in
/// esma_text_test.dart: moving it to a shared helper would change a shipped
/// test (plan 0008, R2).
int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final b in bytes) {
    crc ^= b;
    for (var k = 0; k < 8; k++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}

typedef _Field = (int crc, int codePoints);

(int, int) _measure(String s) => (_crc32(utf8.encode(s)), s.runes.length);

// (number, reading, meaning, reference, target)
// dart format off
const List<(int, _Field, _Field, _Field, int?)> _expected = [
  (1, (0x4635775F, 11), (0xF8E5819A, 43), (0x723D78CD, 31), 33),
  (2, (0x2EB1C7FD, 13), (0x60F1918E, 17), (0x723D78CD, 31), 33),
  (3, (0xABF66D25, 12), (0x13F381C6, 22), (0x723D78CD, 31), 33),
  (4, (0x622028D5, 26), (0xE62B4417, 30), (0x6DC2D73D, 19), 100),
  (5, (0x7C55F282, 13), (0xA5C0F9D8, 38), (0xE83ED331, 17), 100),
  (6, (0xFEAAC508, 34), (0xCE35075F, 41), (0x6ED83758, 36), null),
  (7, (0x1A8D1FB1, 40), (0x75ADD662, 87), (0xF8E2BD01, 17), null),
];
// dart format on

List<SuggestedDhikr> _stored() {
  final text = File(AssetSuggestedRepository.asset).readAsStringSync();
  return switch (AssetSuggestedRepository.parse(text)) {
    Ok(:final value) => value,
    Err(:final failure) => fail(
      'suggested_dhikrs.json rejected: ${failure.cause}',
    ),
  };
}

/// The code points of [s], to find a character by its number.
List<int> _cp(String s) => s.runes.toList();

void main() {
  test('the checksum is the standard CRC-32', () {
    expect(_crc32(ascii.encode('123456789')), 0xCBF43926);
  });

  test('7 dhikrs numbered 1 to 7', () {
    final dhikrs = _stored();
    expect(dhikrs.length, 7);
    expect(dhikrs.map((d) => d.number), [1, 2, 3, 4, 5, 6, 7]);
    expect(_expected.length, 7);
  });

  test('every field matches the approved table byte for byte', () {
    final dhikrs = _stored();
    for (var i = 0; i < _expected.length; i++) {
      final (number, reading, meaning, reference, _) = _expected[i];
      final d = dhikrs[i];
      expect(d.number, number);
      expect(_measure(d.reading), reading, reason: 'dhikr $number, reading');
      expect(_measure(d.meaning), meaning, reason: 'dhikr $number, meaning');
      expect(
        _measure(d.reference),
        reference,
        reason: 'dhikr $number, reference',
      );
    }
  });

  test('targets match the table', () {
    expect(_stored().map((d) => d.target), [33, 33, 33, 100, 100, null, null]);
    expect(_stored().map((d) => d.target), _expected.map((e) => e.$5));
  });

  test('the source characters are kept as they are', () {
    final d = _stored();
    // G2: the apostrophe is U+2019 wherever a source writes one.
    for (final (n, field) in [
      (1, d[0].meaning),
      (2, d[1].meaning),
      (4, d[3].meaning),
      (5, d[4].meaning),
      (6, d[5].meaning),
      (7, d[6].meaning),
      (7, d[6].reference),
    ]) {
      expect(_cp(field), contains(0x2019), reason: 'dhikr $n');
      expect(field, isNot(contains("'")), reason: 'dhikr $n');
    }
    // G1: ā (U+0101) and the lower-case starts of 4 and 5.
    expect(_cp(d[3].reading), contains(0x0101));
    expect(d[3].reading, startsWith('s'));
    expect(d[4].reading, startsWith('e'));
    // G5: “ ” (U+201C, U+201D) and Ẕ (U+1E94) in the references.
    for (final i in [0, 1, 2, 3]) {
      expect(_cp(d[i].reference), containsAll([0x201C, 0x201D]));
    }
    expect(_cp(d[3].reference), contains(0x1E94));
  });

  test('readings are valid dhikr names and targets are within range', () {
    for (final d in _stored()) {
      final parsed = DhikrName.parse(d.reading);
      expect(parsed, isA<Ok<DhikrName>>(), reason: 'dhikr ${d.number}');
      expect((parsed as Ok<DhikrName>).value.value, d.reading);
      expect(d.reading.runes.length, inInclusiveRange(1, 50));
      final t = d.target;
      if (t != null) expect(t, inInclusiveRange(Target.min, Target.max));
    }
  });

  test('the file names its sources', () {
    final doc =
        jsonDecode(File(AssetSuggestedRepository.asset).readAsStringSync())
            as Map<String, Object?>;
    final sources = doc['sources']! as Map<String, Object?>;
    final refs = (sources['references']! as List<Object?>).join('\n');
    for (final url in [
      'hadislerleislam.diyanet.gov.tr/sayfa.php?CILT=2&SAYFA=86',
      'dijital.diyanet.gov.tr/Dergilik/makale/dillerden-dusmeyen-zikirler',
      'islamansiklopedisi.org.tr/tesbih--allah',
      'islamansiklopedisi.org.tr/hamd',
      'islamansiklopedisi.org.tr/havkale',
    ]) {
      expect(refs, contains(url));
    }
    expect((sources['rows']! as Map<String, Object?>).keys, [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
    ]);
  });
}
