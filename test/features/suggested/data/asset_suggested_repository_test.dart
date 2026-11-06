import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/suggested/suggested.dart';

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
    jsonDecode(File(AssetSuggestedRepository.asset).readAsStringSync())
        as Map<String, Object?>;

List<Map<String, Object?>> _rows(Map<String, Object?> doc) => [
  for (final r in doc['dhikrs']! as List<Object?>) r! as Map<String, Object?>,
];

Future<Result<List<SuggestedDhikr>>> _load(Map<String, Object?> doc) =>
    AssetSuggestedRepository(_Bundle(jsonEncode(doc))).load();

/// [rows] with dhikr [n] changed by [change].
List<Map<String, Object?>> _with(
  List<Map<String, Object?>> rows,
  int n,
  Map<String, Object?> Function(Map<String, Object?>) change,
) => [
  for (final r in rows) r['number'] == n ? change({...r}) : r,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the bundled file loads without network', () async {
    final result = await AssetSuggestedRepository(rootBundle).load();
    expect(result, isA<Ok<List<SuggestedDhikr>>>());
    final dhikrs = (result as Ok<List<SuggestedDhikr>>).value;
    expect(dhikrs.length, 7);
    expect(dhikrs.first.reading, 'Sübhânallah');
    expect(dhikrs.first.target, 33);
    expect(dhikrs.last.reading, 'Lâ ilâhe illâllâhü vahdehû lâ şerîke leh');
    expect(dhikrs.last.target, isNull);
  });

  test('the text is passed on exactly as stored', () async {
    final doc = _bundled();
    final rows = _with(
      _rows(doc),
      1,
      (r) => r
        ..['meaning'] = ' â '
        ..['reference'] = 'x́',
    );
    final dhikrs =
        (await _load({...doc, 'dhikrs': rows}) as Ok<List<SuggestedDhikr>>)
            .value;
    expect(dhikrs.first.meaning, ' â ');
    expect(dhikrs.first.reference, 'x́');
  });

  test('an incomplete, misnumbered or out-of-range file is rejected', () async {
    final doc = _bundled();
    final rows = _rows(doc);
    final cases = <String, List<Map<String, Object?>>>{
      '6 dhikrs': rows.sublist(1),
      '8 dhikrs': [...rows, rows.last],
      'gap in numbering': _with(rows, 4, (r) => r..['number'] = 5),
      'swapped order': [rows[1], rows[0], ...rows.sublist(2)],
      'empty reading': _with(rows, 2, (r) => r..['reading'] = ''),
      'empty meaning': _with(rows, 3, (r) => r..['meaning'] = ''),
      'empty reference': _with(rows, 5, (r) => r..['reference'] = ''),
      'missing reference': _with(rows, 7, (r) => r..remove('reference')),
      'missing target': _with(rows, 6, (r) => r..remove('target')),
      'target 0': _with(rows, 1, (r) => r..['target'] = 0),
      'target 100001': _with(rows, 4, (r) => r..['target'] = 100001),
      'target as text': _with(rows, 1, (r) => r..['target'] = '33'),
      'reading of 51 characters': _with(
        rows,
        7,
        (r) => r..['reading'] = 'a' * 51,
      ),
      'reading the name rule would trim': _with(
        rows,
        1,
        (r) => r..['reading'] = ' Sübhânallah',
      ),
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      expect(
        await _load({...doc, 'dhikrs': value}),
        isA<Err<List<SuggestedDhikr>>>().having(
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
        await AssetSuggestedRepository(bundle).load(),
        isA<Err<List<SuggestedDhikr>>>().having(
          (e) => e.failure,
          'failure',
          isA<StorageFailure>(),
        ),
      );
    }
  });
}
