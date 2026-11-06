import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/esma/esma.dart';

// Sensitive area: Dini metin bütünlüğü (docs/testing.md, "Hassas alan").
// Spec 0007, Requirements 1–2 / AC-2: the 99 names of assets/data/esma.json,
// byte for byte as in the spec's approved table (source:
// https://yasin.suresi.gen.tr/dualar/esmaul-husna/, accessed 2026-11-07).
//
// For each name and field the expected value is the CRC-32 of its UTF-8 bytes
// and its number of code points (plan 0007, R2). They were computed once, from
// the approved spec table, outside the repo. Numbers, not letters: no editor or
// tool normalization (e.g. NFD) can change both sides at once (plan 0006, F-1).
// Any changed byte turns this test red and names the entry and field.

/// CRC-32 (IEEE 802.3), the same as zlib's.
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

// (number, arabic, reading, meaning)
// dart format off
const List<(int, _Field, _Field, _Field)> _expected = [
  (1, (0x51ADD929, 7), (0xAC034F97, 5), (0x4C3C4A84, 88)),
  (2, (0x963799CC, 11), (0xDA5CB688, 9), (0x4A62F23E, 57)),
  (3, (0x74656576, 10), (0x3B0A9282, 8), (0x9102F782, 59)),
  (4, (0xD357EE3C, 9), (0x8904807C, 8), (0x5DC3EA95, 45)),
  (5, (0x927752BE, 11), (0x94A1D1B1, 9), (0x54A4AE04, 49)),
  (6, (0xD89F54A2, 10), (0xEAAB3F22, 8), (0xC0C5A369, 49)),
  (7, (0x2EC55B46, 11), (0x08286C86, 9), (0x09C585F7, 38)),
  (8, (0x71AB5A77, 13), (0xEA108E66, 11), (0x5B57259F, 25)),
  (9, (0x735F83DC, 10), (0x78A15192, 7), (0x0A72A910, 44)),
  (10, (0x3136829F, 11), (0xE2B4AEBF, 9), (0x3AAA959D, 62)),
  (11, (0xAF274522, 14), (0xF92BE847, 13), (0xDCC6F032, 59)),
  (12, (0x796A916B, 10), (0x26F76889, 8), (0x431F28F3, 25)),
  (13, (0x68864D84, 10), (0x94D40CB4, 8), (0x3CD46497, 45)),
  (14, (0x4E05964B, 12), (0xC35128E2, 11), (0x1839EB42, 42)),
  (15, (0x31DA341F, 11), (0xF788F92D, 9), (0x2FA5DB24, 36)),
  (16, (0x7429029B, 11), (0x6FC75A0B, 9), (0x238AFA57, 57)),
  (17, (0x00D1E772, 11), (0xEFE8F577, 9), (0x0E02223F, 56)),
  (18, (0x6CC99092, 11), (0xE649ABD5, 9), (0x29079C77, 31)),
  (19, (0xA6C5BC49, 11), (0xD73C1203, 9), (0x055B2C2D, 57)),
  (20, (0x582EC5CA, 10), (0x8E00DC16, 7), (0x020E7328, 36)),
  (21, (0x92C8FB4C, 10), (0x677F18B6, 8), (0x1C3D8ABE, 40)),
  (22, (0xE2FD95EA, 10), (0x07F57DFB, 8), (0x2E51B0FE, 54)),
  (23, (0xB08C94E5, 10), (0xD9F5957C, 8), (0x510A61BD, 41)),
  (24, (0x9F7F8C20, 10), (0xE51C269A, 8), (0x75073E0B, 21)),
  (25, (0x04457B44, 10), (0x3D2EFA3F, 7), (0x478E1623, 35)),
  (26, (0x4DDB539C, 10), (0x3A59576D, 8), (0x5557EE6E, 48)),
  (27, (0x9FC5E4F3, 10), (0x68ABBFC5, 8), (0xD61C3746, 16)),
  (28, (0x7CE92F13, 10), (0x5BFD6E6B, 8), (0x809D8A1F, 15)),
  (29, (0x6A57A71E, 9), (0x8E1F64E7, 8), (0xFBAF34E1, 39)),
  (30, (0x141D5395, 9), (0xD3ACB6C2, 6), (0x0B5C01FE, 21)),
  (31, (0x1BCA8B8E, 10), (0xE6FAE3DF, 8), (0x1352DD8E, 55)),
  (32, (0x818355E8, 10), (0x12C37DF7, 8), (0x00503C26, 37)),
  (33, (0x2C900986, 10), (0x7F140731, 8), (0x1B1815AB, 47)),
  (34, (0x7FE99D32, 10), (0xFB72D455, 7), (0xCDAB300A, 25)),
  (35, (0xDFFB7925, 10), (0x5B42BE61, 8), (0x67965935, 29)),
  (36, (0x929B7C9C, 10), (0x8DA2B441, 8), (0x1A618847, 53)),
  (37, (0xAFB67D7F, 10), (0xB1599FD6, 6), (0x2EF00CF6, 15)),
  (38, (0xE8DE9F15, 10), (0x61D7A999, 8), (0x50813FCA, 49)),
  (39, (0xF2085D6F, 10), (0x937A6292, 8), (0x275CCC1B, 25)),
  (40, (0x61DBB09A, 10), (0x430537B9, 8), (0x4B371BC8, 42)),
  (41, (0x012B7D75, 10), (0xE7D15D69, 8), (0xAFCF8A44, 41)),
  (42, (0xF0C4BA34, 10), (0x975461A4, 8), (0x31B4E66B, 23)),
  (43, (0x73634116, 10), (0xBCC6F3F3, 8), (0x57EDEC6B, 35)),
  (44, (0x4EC6F1EC, 10), (0xB90020FD, 8), (0x564C09B2, 46)),
  (45, (0xC7AE56FB, 10), (0x42B5DE24, 8), (0x75C20D7A, 23)),
  (46, (0xC6121263, 10), (0x0D51260E, 8), (0xF4D21390, 61)),
  (47, (0x48F1644F, 10), (0xE2C33F88, 8), (0x1E07CB1A, 22)),
  (48, (0x96987C42, 10), (0x3895B445, 8), (0xBD64425B, 38)),
  (49, (0x036F9FBE, 10), (0xFBE698B0, 8), (0xA761A765, 29)),
  (50, (0x53B190B0, 10), (0xEB097268, 7), (0x48732082, 40)),
  (51, (0x32991CAD, 10), (0x5C7648EA, 8), (0x8AA54F06, 20)),
  (52, (0x7C5A6C42, 8), (0x3F6EECAB, 6), (0x7BBACCE1, 50)),
  (53, (0x7A6D17E8, 10), (0x5998CA35, 8), (0x46216FED, 51)),
  (54, (0x343D3D91, 10), (0x2771A671, 7), (0x75EEB417, 20)),
  (55, (0xFF55FC3E, 10), (0xD6FD1E88, 8), (0xF40FF148, 31)),
  (56, (0xE856A8A3, 10), (0x21D244B3, 7), (0x84418006, 31)),
  (57, (0xB68DB996, 10), (0xBE74D8F0, 8), (0x6FBC9E33, 28)),
  (58, (0x4DC988A1, 10), (0x22BB4867, 8), (0x74BA0EDB, 33)),
  (59, (0x03498E48, 11), (0xA4330632, 9), (0x7C2CD65A, 44)),
  (60, (0x24B64740, 10), (0x1F3D91A6, 7), (0x8551FEE8, 47)),
  (61, (0xA5E47453, 10), (0x2F2CCDB1, 8), (0x5E28EF01, 12)),
  (62, (0x05BADD53, 10), (0x56BE1C46, 8), (0x7E3632C3, 14)),
  (63, (0x4C2A2783, 8), (0xC214424A, 7), (0x310CA856, 25)),
  (64, (0xBBD51A86, 11), (0xCCEA702E, 9), (0x4F5F1B2B, 46)),
  (65, (0x4F2F2186, 10), (0xFEA29554, 8), (0x3108B237, 61)),
  (66, (0x080341F8, 10), (0x97B3670C, 8), (0x75F6EEEE, 29)),
  (67, (0xE9582A32, 10), (0xF2F77AB5, 8), (0xBD65D3BF, 46)),
  (68, (0x2041B2B5, 9), (0x75E8EA45, 8), (0x3FB3313F, 62)),
  (69, (0x5220D347, 10), (0xB07127C5, 8), (0x0A92A019, 20)),
  (70, (0x05A37B3C, 13), (0xD9DA3F89, 11), (0x75B88616, 41)),
  (71, (0x3B8C3237, 12), (0x446E4DEB, 11), (0xA54F55C5, 20)),
  (72, (0x39BD7903, 12), (0x6463F1C9, 10), (0x5CAF29DF, 24)),
  (73, (0x1151DD15, 10), (0xD8B8CFC5, 8), (0x9D872CC2, 63)),
  (74, (0xD692CCEF, 8), (0xAF18F712, 7), (0xE16A5687, 54)),
  (75, (0x84CEFFCD, 10), (0xCB353733, 8), (0x37756455, 33)),
  (76, (0x8BA7593B, 10), (0x6740BC38, 8), (0x4361D266, 67)),
  (77, (0xD1565840, 9), (0xDAA7ADA4, 7), (0xA35C2516, 25)),
  (78, (0xA2F86547, 13), (0x8E12AD91, 10), (0xE2D85737, 58)),
  (79, (0x1B1038FE, 8), (0xDE860AB1, 7), (0x77FF5DD7, 27)),
  (80, (0x1214E651, 11), (0x00790D78, 9), (0xA229C7CA, 59)),
  (81, (0x76C16CB4, 13), (0x4C9B56F3, 11), (0xA5CD472A, 45)),
  (82, (0x0E778777, 10), (0x132C854D, 7), (0x4274255B, 31)),
  (83, (0x3499C4B6, 10), (0xCCAC3196, 7), (0x44D5D46E, 18)),
  (84, (0x94AA0D39, 17), (0x8108F29C, 13), (0x6FB139B4, 20)),
  (85, (0x8F3BDAF9, 29), (0x4D3BA1FE, 22), (0xDE9B155E, 22)),
  (86, (0x41452A89, 11), (0x02E08820, 9), (0x809A34C4, 66)),
  (87, (0x2FC34280, 10), (0x48F23B5C, 8), (0x8A0E093B, 72)),
  (88, (0x3C8A3937, 10), (0xF0B4B9B8, 7), (0x109DA160, 29)),
  (89, (0xA8B5B6EA, 10), (0x1815791F, 8), (0xC403F8D2, 23)),
  (90, (0xB7CFF876, 10), (0x70BEE475, 8), (0x3702C5C3, 27)),
  (91, (0x9BD01644, 9), (0x899732A3, 7), (0x22D7FE4B, 86)),
  (92, (0x66B1B37A, 10), (0xBA1CC01E, 8), (0xC130F1B8, 42)),
  (93, (0x96D07C0A, 8), (0x1E5559D7, 6), (0x59A42E2B, 52)),
  (94, (0x3FE36136, 9), (0xED689FF7, 7), (0x021F05E6, 18)),
  (95, (0x4B14B644, 10), (0x78B202F6, 8), (0xCD7E3907, 39)),
  (96, (0x432F6E58, 9), (0x47AFFBAC, 7), (0xD5B8DCBF, 43)),
  (97, (0x4E2F7454, 10), (0x6095D9D4, 8), (0x25788911, 61)),
  (98, (0xF960350F, 10), (0xA975D787, 8), (0x25F5367F, 48)),
  (99, (0xC406D034, 10), (0xE9FC4A3C, 8), (0x7CA6317E, 42)),
];
// dart format on

List<AsmaName> _stored() {
  final text = File(AssetEsmaRepository.asset).readAsStringSync();
  return switch (AssetEsmaRepository.parse(text)) {
    Ok(:final value) => value,
    Err(:final failure) => fail('esma.json rejected: ${failure.cause}'),
  };
}

void main() {
  test('the checksum is the standard CRC-32', () {
    expect(_crc32(ascii.encode('123456789')), 0xCBF43926);
  });

  test('99 names numbered 1 to 99', () {
    final names = _stored();
    expect(names.length, 99);
    expect(names.map((n) => n.number), List.generate(99, (i) => i + 1));
    expect(_expected.length, 99);
  });

  test('every field matches the approved table byte for byte', () {
    final names = _stored();
    for (var i = 0; i < _expected.length; i++) {
      final (number, arabic, reading, meaning) = _expected[i];
      final n = names[i];
      expect(n.number, number);
      expect(_measure(n.arabic), arabic, reason: 'name $number, arabic');
      expect(_measure(n.reading), reading, reason: 'name $number, reading');
      expect(_measure(n.meaning), meaning, reason: 'name $number, meaning');
    }
  });

  test('every reading is a valid dhikr name unchanged', () {
    for (final n in _stored()) {
      final parsed = DhikrName.parse(n.reading);
      expect(parsed, isA<Ok<DhikrName>>(), reason: 'name ${n.number}');
      expect((parsed as Ok<DhikrName>).value.value, n.reading);
    }
  });

  test('the file names its source', () {
    final doc =
        jsonDecode(File(AssetEsmaRepository.asset).readAsStringSync())
            as Map<String, Object?>;
    expect(doc['source'], contains('yasin.suresi.gen.tr/dualar/esmaul-husna'));
  });
}
