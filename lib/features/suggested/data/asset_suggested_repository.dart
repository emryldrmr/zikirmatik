import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/result.dart';
import '../../counter/counter.dart';
import '../domain/suggested_dhikr.dart';
import '../domain/suggested_repository.dart';

/// [SuggestedRepository] reading the bundled `assets/data/suggested_dhikrs.json`
/// (spec 0008, plan R1). The file is checked before use — exactly 7 dhikrs
/// numbered 1–7 without gaps, no empty field, each target absent or within
/// BR-2, each reading a valid dhikr name as it stands (BR-1) — and rejected as
/// a whole otherwise. The text is passed on exactly as stored (BR-12).
final class AssetSuggestedRepository implements SuggestedRepository {
  AssetSuggestedRepository(this._bundle);

  static const String asset = 'assets/data/suggested_dhikrs.json';
  static const int count = 7;

  final AssetBundle _bundle;

  @override
  Future<Result<List<SuggestedDhikr>>> load() async {
    try {
      final text = await _bundle.loadString(asset, cache: false);
      return parse(text);
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }

  /// Parses and checks the file's text.
  static Result<List<SuggestedDhikr>> parse(String text) {
    try {
      final doc = jsonDecode(text) as Map<String, Object?>;
      final rows = doc['dhikrs']! as List<Object?>;
      if (rows.length != count) {
        return Err(
          StorageFailure('expected $count dhikrs, got ${rows.length}'),
        );
      }
      final dhikrs = <SuggestedDhikr>[];
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i]! as Map<String, Object?>;
        if (!row.containsKey('target')) {
          return Err(StorageFailure('no target at position ${i + 1}'));
        }
        final dhikr = SuggestedDhikr(
          number: row['number']! as int,
          reading: row['reading']! as String,
          meaning: row['meaning']! as String,
          target: row['target'] as int?,
          reference: row['reference']! as String,
        );
        if (dhikr.number != i + 1 ||
            dhikr.meaning.isEmpty ||
            dhikr.reference.isEmpty ||
            !_validName(dhikr.reading) ||
            !_validTarget(dhikr.target)) {
          return Err(StorageFailure('bad entry at position ${i + 1}'));
        }
        dhikrs.add(dhikr);
      }
      return Ok(List.unmodifiable(dhikrs));
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }

  /// BR-1, and unchanged by it: the added dhikr's name is the reading byte for
  /// byte (spec 0008, AC-4), so a reading the name rule would trim is refused.
  static bool _validName(String reading) => switch (DhikrName.parse(reading)) {
    Ok(:final value) => value.value == reading,
    Err() => false,
  };

  /// BR-2, or no target.
  static bool _validTarget(int? target) =>
      target == null || (target >= Target.min && target <= Target.max);
}
