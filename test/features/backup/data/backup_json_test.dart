import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/backup/data/backup_json.dart';
import 'package:zikirmatik/features/backup/domain/backup_ports.dart';
import 'package:zikirmatik/features/backup/domain/backup_snapshot.dart';

// Spec 0018 — JSON yedekleme, the file format (AC-3, AC-6, AC-8).

const _settings = BackupSettings(
  vibration: false,
  theme: 'dark',
  tapVibration: true,
  keepScreenOn: true,
  largeCount: true,
  handLayout: 'left',
  continueNotification: true,
);

BackupSnapshot _snapshot({
  List<BackupDhikr>? dhikrs,
  int? selected = 2,
  BackupTesbihat tesbihat = const BackupTesbihat(
    step: 1,
    count: 5,
    completions: 3,
    selected: true,
  ),
  List<BackupDay>? days,
}) => BackupSnapshot(
  createdAt: DateTime(2026, 11, 19, 14, 3),
  appVersion: '1.0.0',
  data: BackupData(
    dhikrs:
        dhikrs ??
        const [
          BackupDhikr(
            id: 2,
            name: 'Sübhânallah',
            target: 33,
            count: 12,
            rounds: 4,
            total: 144,
          ),
          BackupDhikr(
            id: 5,
            name: 'Estağfirullah',
            target: null,
            count: 250,
            rounds: 0,
            total: 250,
          ),
        ],
    selectedDhikrId: selected,
    tesbihat: tesbihat,
    days:
        days ?? const [BackupDay('2026-11-18', 40), BackupDay('2026-11-19', 7)],
    settings: _settings,
  ),
);

/// The JSON of a valid backup, changed by [edit] before it is encoded.
Uint8List _file(void Function(Map<String, Object?> json) edit) {
  final json =
      jsonDecode(utf8.decode(encodeBackup(_snapshot())))
          as Map<String, Object?>;
  edit(json);
  return utf8.encode(jsonEncode(json));
}

Map<String, Object?> _firstDhikr(Map<String, Object?> json) =>
    (json['dhikrs']! as List<Object?>).first! as Map<String, Object?>;

BackupSnapshot _valid(Uint8List bytes) => switch (decodeBackup(bytes)) {
  Valid(:final snapshot) => snapshot,
  final other => fail('expected Valid, got $other'),
};

void _expectInvalid(Uint8List bytes) =>
    expect(decodeBackup(bytes), isA<Invalid>());

void main() {
  test('encode decode round trip', () {
    final snapshot = _snapshot();
    final back = _valid(encodeBackup(snapshot));
    expect(back.data, snapshot.data);
    expect(back.appVersion, '1.0.0');
    expect(back.createdAt.isAtSameMomentAs(snapshot.createdAt), isTrue);
  });

  test('file is indented readable json with format and versions', () {
    final text = utf8.decode(encodeBackup(_snapshot()));
    expect(text, contains('\n  "format": "zikirmatik-yedek"'));
    final json = jsonDecode(text) as Map<String, Object?>;
    expect(json['formatVersion'], 1);
    expect(json['appVersion'], '1.0.0');
    // Local time with its offset (TZ=Europe/Istanbul in check: +03:00).
    expect(json['createdAt'], matches(r'^2026-11-19T14:03:00[+-]\d{2}:\d{2}$'));
  });

  test('empty backup', () {
    final empty = _snapshot(
      dhikrs: const [],
      selected: null,
      tesbihat: const BackupTesbihat(),
      days: const [],
    );
    final back = _valid(encodeBackup(empty));
    expect(back.data.dhikrs, isEmpty);
    expect(back.data.selectedDhikrId, isNull);
    expect(back.data.days, isEmpty);
  });

  test('fifty char name and max target kept', () {
    final name = 'ş' * 50;
    final back = _valid(
      encodeBackup(
        _snapshot(
          dhikrs: [
            BackupDhikr(
              id: 2,
              name: name,
              target: 100000,
              count: 99999,
              rounds: 1,
              total: 199999,
            ),
          ],
        ),
      ),
    );
    expect(back.data.dhikrs.single.name, name);
    expect(back.data.dhikrs.single.target, 100000);
    expect(back.data.dhikrs.single.count, 99999);
  });

  test('large totals kept', () {
    const big = 9007199254740991; // 2^53 - 1
    final back = _valid(
      encodeBackup(
        _snapshot(
          dhikrs: const [
            BackupDhikr(
              id: 2,
              name: 'Zikir',
              target: null,
              count: big,
              rounds: big,
              total: big,
            ),
          ],
          days: const [BackupDay('2026-11-19', big)],
        ),
      ),
    );
    expect(back.data.dhikrs.single.total, big);
    expect(back.data.dhikrs.single.rounds, big);
    expect(back.data.days.single.count, big);
  });

  test('missing settings keys take defaults', () {
    final back = _valid(
      _file((json) => json['settings'] = <String, Object?>{'theme': 'dark'}),
    );
    expect(
      back.data.settings,
      const BackupSettings(
        vibration: true,
        theme: 'dark',
        tapVibration: false,
        keepScreenOn: false,
        largeCount: false,
        handLayout: 'center',
        continueNotification: false,
      ),
    );
  });

  test('newer format is too new', () {
    expect(
      decodeBackup(_file((json) => json['formatVersion'] = 2)),
      isA<TooNew>(),
    );
    // Even when the rest has changed beyond recognition.
    expect(
      decodeBackup(
        utf8.encode('{"format":"zikirmatik-yedek","formatVersion":7}'),
      ),
      isA<TooNew>(),
    );
  });

  group('rejects', () {
    test('not json', () => _expectInvalid(utf8.encode('merhaba')));

    test('not utf-8', () => _expectInvalid(Uint8List.fromList([0xff, 0xfe])));

    test('json that is not a zikirmatik backup', () {
      _expectInvalid(utf8.encode('{"name":"Zikir","count":3}'));
      _expectInvalid(utf8.encode('[1,2,3]'));
      _expectInvalid(_file((json) => json['format'] = 'baska-uygulama'));
    });

    test('format version below one', () {
      _expectInvalid(_file((json) => json['formatVersion'] = 0));
      _expectInvalid(_file((json) => json['formatVersion'] = '1'));
    });

    test('missing required field', () {
      _expectInvalid(_file((json) => json.remove('dhikrs')));
      _expectInvalid(_file((json) => json.remove('tesbihat')));
      _expectInvalid(_file((json) => json.remove('days')));
      _expectInvalid(_file((json) => json.remove('settings')));
      _expectInvalid(_file((json) => json.remove('createdAt')));
      _expectInvalid(_file((json) => _firstDhikr(json).remove('name')));
      _expectInvalid(_file((json) => _firstDhikr(json).remove('total')));
    });

    test('larger than five megabytes', () {
      final big = Uint8List(maxBackupBytes + 1);
      _expectInvalid(big);
    });

    test('fifty one char name', () {
      _expectInvalid(_file((json) => _firstDhikr(json)['name'] = 'a' * 51));
    });

    test('empty name', () {
      _expectInvalid(_file((json) => _firstDhikr(json)['name'] = ''));
      _expectInvalid(_file((json) => _firstDhikr(json)['name'] = '   '));
    });

    test('target zero', () {
      _expectInvalid(_file((json) => _firstDhikr(json)['target'] = 0));
    });

    test('target 100001', () {
      _expectInvalid(_file((json) => _firstDhikr(json)['target'] = 100001));
    });

    test('negative count rounds or total', () {
      _expectInvalid(_file((json) => _firstDhikr(json)['count'] = -1));
      _expectInvalid(_file((json) => _firstDhikr(json)['rounds'] = -1));
      _expectInvalid(_file((json) => _firstDhikr(json)['total'] = -1));
    });

    test('count equal to target', () {
      _expectInvalid(_file((json) => _firstDhikr(json)['count'] = 33));
    });

    test('count that is not a whole number', () {
      _expectInvalid(_file((json) => _firstDhikr(json)['count'] = 1.5));
      _expectInvalid(_file((json) => _firstDhikr(json)['count'] = '12'));
    });

    test('duplicate dhikr id', () {
      _expectInvalid(_file((json) => _firstDhikr(json)['id'] = 5));
    });

    test('selection of a missing dhikr', () {
      _expectInvalid(_file((json) => json['selectedDhikrId'] = 99));
    });

    test('tesbihat progress that does not fit its steps', () {
      _expectInvalid(
        _file(
          (json) => (json['tesbihat']! as Map<String, Object?>)['count'] = 33,
        ),
      );
      _expectInvalid(
        _file(
          (json) => (json['tesbihat']! as Map<String, Object?>)['step'] = 3,
        ),
      );
    });

    test('invalid day', () {
      void day(String value) => _expectInvalid(
        _file(
          (json) =>
              ((json['days']! as List<Object?>).first!
                      as Map<String, Object?>)['day'] =
                  value,
        ),
      );
      day('2026-02-30');
      day('2026-11-19T00:00');
      day('19.11.2026');
    });

    test('duplicate day', () {
      _expectInvalid(
        _file(
          (json) => (json['days']! as List<Object?>).add({
            'day': '2026-11-19',
            'count': 1,
          }),
        ),
      );
    });

    test('unknown setting value', () {
      _expectInvalid(
        _file(
          (json) =>
              (json['settings']! as Map<String, Object?>)['theme'] = 'sepia',
        ),
      );
      _expectInvalid(
        _file(
          (json) => (json['settings']! as Map<String, Object?>)['handLayout'] =
              'both',
        ),
      );
      _expectInvalid(
        _file(
          (json) =>
              (json['settings']! as Map<String, Object?>)['vibration'] = 'yes',
        ),
      );
    });
  });
}
