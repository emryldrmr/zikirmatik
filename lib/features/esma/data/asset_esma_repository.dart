import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/result.dart';
import '../domain/asma_name.dart';
import '../domain/esma_repository.dart';

/// [EsmaRepository] reading the bundled `assets/data/esma.json` (spec 0007,
/// plan R1). The file is checked before use — exactly 99 names numbered 1–99
/// without gaps, no empty field — and rejected as a whole otherwise. The text
/// is passed on exactly as stored (BR-12).
final class AssetEsmaRepository implements EsmaRepository {
  AssetEsmaRepository(this._bundle);

  static const String asset = 'assets/data/esma.json';
  static const int count = 99;

  final AssetBundle _bundle;

  @override
  Future<Result<List<AsmaName>>> load() async {
    try {
      final text = await _bundle.loadString(asset, cache: false);
      return parse(text);
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }

  /// Parses and checks the file's text.
  static Result<List<AsmaName>> parse(String text) {
    try {
      final doc = jsonDecode(text) as Map<String, Object?>;
      final rows = doc['names']! as List<Object?>;
      if (rows.length != count) {
        return Err(StorageFailure('expected $count names, got ${rows.length}'));
      }
      final names = <AsmaName>[];
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i]! as Map<String, Object?>;
        final name = AsmaName(
          number: row['number']! as int,
          arabic: row['arabic']! as String,
          reading: row['reading']! as String,
          meaning: row['meaning']! as String,
        );
        if (name.number != i + 1 ||
            name.arabic.isEmpty ||
            name.reading.isEmpty ||
            name.meaning.isEmpty) {
          return Err(StorageFailure('bad entry at position ${i + 1}'));
        }
        names.add(name);
      }
      return Ok(List.unmodifiable(names));
    } on Object catch (e) {
      return Err(StorageFailure(e));
    }
  }
}
