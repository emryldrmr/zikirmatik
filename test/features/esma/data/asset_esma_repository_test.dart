import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/esma/esma.dart';

/// A bundle whose only file is [text], or that fails to read.
class _Bundle extends CachingAssetBundle {
  _Bundle(this.text);

  final String? text;

  @override
  Future<ByteData> load(String key) async {
    final t = text;
    if (t == null) throw StateError('unable to load $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(t)));
  }
}

Map<String, Object?> _bundled() =>
    jsonDecode(File(AssetEsmaRepository.asset).readAsStringSync())
        as Map<String, Object?>;

List<Map<String, Object?>> _rows(Map<String, Object?> doc) => [
  for (final r in doc['names']! as List<Object?>) r! as Map<String, Object?>,
];

Future<Result<List<AsmaName>>> _load(Map<String, Object?> doc) =>
    AssetEsmaRepository(_Bundle(jsonEncode(doc))).load();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the bundled file and font load without network', () async {
    final result = await AssetEsmaRepository(rootBundle).load();
    expect(result, isA<Ok<List<AsmaName>>>());
    final names = (result as Ok<List<AsmaName>>).value;
    expect(names.first.reading, 'Allah');
    expect(names.last.reading, 'es-Sabûr');

    final font = await rootBundle.load('assets/fonts/AmiriQuran-Regular.ttf');
    expect(font.lengthInBytes, greaterThan(100000));
  });

  test('the text is passed on exactly as stored', () async {
    final doc = _bundled();
    final rows = _rows(doc);
    rows[0] = {...rows[0], 'reading': ' Allah ', 'meaning': 'â'};
    final names =
        (await _load({...doc, 'names': rows}) as Ok<List<AsmaName>>).value;
    expect(names.first.reading, ' Allah ');
    expect(names.first.meaning, 'â');
  });

  test('an incomplete or misnumbered file is rejected', () async {
    final doc = _bundled();
    final rows = _rows(doc);
    final cases = <String, List<Map<String, Object?>>>{
      '98 names': rows.sublist(1),
      '100 names': [...rows, rows.last],
      'gap in numbering': [
        for (final r in rows) r['number'] == 50 ? {...r, 'number': 51} : r,
      ],
      'swapped order': [rows[1], rows[0], ...rows.sublist(2)],
      'empty reading': [
        for (final r in rows) r['number'] == 7 ? {...r, 'reading': ''} : r,
      ],
      'missing meaning': [
        for (final r in rows)
          r['number'] == 99 ? ({...r}..remove('meaning')) : r,
      ],
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      expect(
        await _load({...doc, 'names': value}),
        isA<Err<List<AsmaName>>>().having(
          (e) => e.failure,
          'failure',
          isA<StorageFailure>(),
        ),
        reason: key,
      );
    }
  });

  test('an unreadable or broken file is a StorageFailure', () async {
    for (final bundle in [_Bundle(null), _Bundle('{not json')]) {
      expect(
        await AssetEsmaRepository(bundle).load(),
        isA<Err<List<AsmaName>>>().having(
          (e) => e.failure,
          'failure',
          isA<StorageFailure>(),
        ),
      );
    }
  });
}
