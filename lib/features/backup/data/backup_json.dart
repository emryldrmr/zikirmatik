import 'dart:convert';
import 'dart:typed_data';

import '../../../core/hand_layout.dart';
import '../../../core/result.dart';
import '../../counter/counter.dart';
import '../../history/history.dart';
import '../../settings/settings.dart';
import '../domain/backup_ports.dart';
import '../domain/backup_snapshot.dart';

/// The file's marker and the format version this app writes (plan 0018, R5).
const String backupFormat = 'zikirmatik-yedek';
const int backupFormatVersion = 1;

/// The backup as indented, human-readable UTF-8 JSON (spec 0018, Req. 2).
Uint8List encodeBackup(BackupSnapshot snapshot) {
  final d = snapshot.data;
  final s = d.settings;
  final json = <String, Object?>{
    'format': backupFormat,
    'formatVersion': backupFormatVersion,
    'appVersion': snapshot.appVersion,
    'createdAt': localIso(snapshot.createdAt),
    'dhikrs': [
      for (final x in d.dhikrs)
        {
          'id': x.id,
          'name': x.name,
          'target': x.target,
          'count': x.count,
          'rounds': x.rounds,
          'total': x.total,
        },
    ],
    'selectedDhikrId': d.selectedDhikrId,
    'tesbihat': {
      'step': d.tesbihat.step,
      'count': d.tesbihat.count,
      'finished': d.tesbihat.finished,
      'completions': d.tesbihat.completions,
      'selected': d.tesbihat.selected,
    },
    'days': [
      for (final x in d.days) {'day': x.day, 'count': x.count},
    ],
    'settings': {
      'vibration': s.vibration,
      'theme': s.theme,
      'tapVibration': s.tapVibration,
      'keepScreenOn': s.keepScreenOn,
      'largeCount': s.largeCount,
      'handLayout': s.handLayout,
      'continueNotification': s.continueNotification,
    },
  };
  return utf8.encode(const JsonEncoder.withIndent('  ').convert(json));
}

/// [moment] as local ISO-8601 with its offset, e.g.
/// `2026-11-19T14:03:00+03:00` (plan 0018, R5).
String localIso(DateTime moment) {
  final local = moment.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final minutes = offset.inMinutes.abs();
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
      '${two(local.day)}T${two(local.hour)}:${two(local.minute)}:'
      '${two(local.second)}$sign${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// The JSON [BackupFormat] (plan 0018, A-2): [encodeBackup] and
/// [decodeBackup] behind the port, so the UI never imports this file (FD-4).
final class JsonBackupFormat implements BackupFormat {
  const JsonBackupFormat();

  @override
  Uint8List encode(BackupSnapshot snapshot) => encodeBackup(snapshot);

  @override
  DecodedBackup decode(Uint8List bytes) => decodeBackup(bytes);
}

/// Checks the whole file before anything is written (Req. 5): the marker, the
/// format version, every required field and the business rules (BR-1, BR-2,
/// no negatives, a count below its target, unique ids and days, a selection
/// that exists, tesbihat progress that fits its steps, real calendar days,
/// known setting values). Settings keys are optional: a missing one takes its
/// default (G7). A file over [maxBackupBytes] is rejected unread (G4).
DecodedBackup decodeBackup(Uint8List bytes) {
  if (bytes.length > maxBackupBytes) return const Invalid();
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    return const Invalid();
  }
  if (json is! Map<String, Object?> || json['format'] != backupFormat) {
    return const Invalid();
  }
  final version = json['formatVersion'];
  if (version is! int || version < 1) return const Invalid();
  if (version > backupFormatVersion) return const TooNew();
  try {
    return Valid(_snapshot(json));
  } on _Reject {
    return const Invalid();
  }
}

/// Thrown inside the decoder only; [decodeBackup] turns it into [Invalid].
final class _Reject implements Exception {
  const _Reject();
}

Never _reject() => throw const _Reject();

BackupSnapshot _snapshot(Map<String, Object?> json) {
  final createdAt = DateTime.tryParse(_string(json['createdAt']));
  if (createdAt == null) _reject();
  final appVersion = json['appVersion'];
  if (appVersion != null && appVersion is! String) _reject();

  final dhikrs = [for (final x in _list(json['dhikrs'])) _dhikr(_map(x))];
  final ids = {for (final x in dhikrs) x.id};
  if (ids.length != dhikrs.length) _reject();
  final selected = json['selectedDhikrId'];
  if (selected != null && (selected is! int || !ids.contains(selected))) {
    _reject();
  }

  final days = [for (final x in _list(json['days'])) _day(_map(x))];
  if ({for (final x in days) x.day}.length != days.length) _reject();

  return BackupSnapshot(
    createdAt: createdAt,
    appVersion: appVersion as String?,
    data: BackupData(
      dhikrs: dhikrs,
      selectedDhikrId: selected as int?,
      tesbihat: _tesbihat(_map(json['tesbihat'])),
      days: days,
      settings: _settings(_map(json['settings'])),
    ),
  );
}

BackupDhikr _dhikr(Map<String, Object?> json) {
  final id = _int(json['id']);
  if (id < 1) _reject();
  final name = _string(json['name']);
  // BR-1, exactly as stored: trimmed, 1–50 characters.
  final parsed = DhikrName.parse(name);
  if (parsed is! Ok<DhikrName> || parsed.value.value != name) _reject();
  final rawTarget = json['target'];
  final target = rawTarget == null ? null : _int(rawTarget);
  if (target != null && (target < Target.min || target > Target.max)) {
    _reject(); // BR-2
  }
  final count = _count(json['count']);
  if (target != null && count >= target) _reject(); // BR-4
  return BackupDhikr(
    id: id,
    name: name,
    target: target,
    count: count,
    rounds: _count(json['rounds']),
    total: _count(json['total']),
  );
}

BackupTesbihat _tesbihat(Map<String, Object?> json) {
  final t = BackupTesbihat(
    step: _count(json['step']),
    count: _count(json['count']),
    finished: _bool(json['finished']),
    completions: _count(json['completions']),
    selected: _bool(json['selected']),
  );
  final state = TesbihatState(
    step: t.step,
    count: DhikrCount(t.count),
    finished: t.finished,
    completions: t.completions,
    selected: t.selected,
  );
  if (!state.fits(namazSonrasiTesbihat)) _reject();
  return t;
}

BackupDay _day(Map<String, Object?> json) {
  final day = _string(json['day']);
  if (Day.tryParse(day) == null) _reject();
  return BackupDay(day, _count(json['count']));
}

BackupSettings _settings(Map<String, Object?> json) {
  final d = AppSettings.defaults;
  bool flag(String key, bool fallback) =>
      json.containsKey(key) ? _bool(json[key]) : fallback;
  String name(String key, String fallback, bool Function(String) known) {
    if (!json.containsKey(key)) return fallback;
    final value = _string(json[key]);
    return known(value) ? value : _reject();
  }

  return BackupSettings(
    vibration: flag('vibration', d.vibration),
    theme: name('theme', d.theme.name, (n) => ThemeChoice.byName(n) != null),
    tapVibration: flag('tapVibration', d.tapVibration),
    keepScreenOn: flag('keepScreenOn', d.keepScreenOn),
    largeCount: flag('largeCount', d.largeCount),
    handLayout: name(
      'handLayout',
      d.handLayout.name,
      (n) => HandLayout.byName(n) != null,
    ),
    continueNotification: flag('continueNotification', d.continueNotification),
  );
}

Map<String, Object?> _map(Object? value) =>
    value is Map<String, Object?> ? value : _reject();

List<Object?> _list(Object? value) =>
    value is List<Object?> ? value : _reject();

String _string(Object? value) => value is String ? value : _reject();

bool _bool(Object? value) => value is bool ? value : _reject();

int _int(Object? value) => value is int ? value : _reject();

/// A count, rounds or total: never negative.
int _count(Object? value) {
  final n = _int(value);
  return n < 0 ? _reject() : n;
}
