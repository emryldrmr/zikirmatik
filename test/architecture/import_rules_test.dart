// Forbidden dependencies FD-1…FD-4 (docs/architecture.md), checked on every
// Dart file under lib/.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// One Dart source file: its path relative to the repo root ('lib/...'),
/// its import/export URIs and its full text.
class SourceFile {
  SourceFile(this.path, this.uris, this.text);

  final String path;
  final List<String> uris;
  final String text;
}

final _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<String> directivesOf(String text) =>
    _directive.allMatches(text).map((m) => m.group(1)!).toList();

/// Resolves [uri] seen in [fromPath] to a repo-relative 'lib/...' path, or
/// returns null for SDK and third-party packages.
String? resolve(String fromPath, String uri) {
  if (uri.startsWith('package:zikirmatik/')) {
    return 'lib/${uri.substring('package:zikirmatik/'.length)}';
  }
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return null;
  final parts = fromPath.split('/')..removeLast();
  for (final segment in uri.split('/')) {
    if (segment == '..') {
      parts.removeLast();
    } else if (segment != '.') {
      parts.add(segment);
    }
  }
  return parts.join('/');
}

String? _featureOf(String path) {
  final m = RegExp(r'^lib/features/([^/]+)/').firstMatch(path);
  return m?.group(1);
}

/// Every rule violation in [file], as human-readable lines.
List<String> violations(SourceFile file) {
  final out = <String>[];
  final path = file.path;
  final inDomain = path.contains('/domain/');
  final inUi = path.contains('/ui/');
  final feature = _featureOf(path);

  for (final uri in file.uris) {
    final target = resolve(path, uri);

    // FD-1: domain is pure Dart.
    if (inDomain) {
      if (uri.startsWith('package:flutter/') ||
          uri.startsWith('package:drift') ||
          uri.startsWith('package:http')) {
        out.add('FD-1 $path imports $uri');
      }
      if (target != null &&
          (target.contains('/data/') || target.contains('/ui/'))) {
        out.add('FD-1 $path imports $target');
      }
    }

    // FD-2: another feature only through its public interface file.
    final other = target == null ? null : _featureOf(target);
    if (feature != null && other != null && other != feature) {
      if (target != 'lib/features/$other/$other.dart') {
        out.add('FD-2 $path imports internal $target');
      }
    }

    // FD-3: only quran/data talks HTTP.
    if (uri.startsWith('package:http') &&
        !path.startsWith('lib/features/quran/data/')) {
      out.add('FD-3 $path imports $uri');
    }

    // FD-4: ui never touches storage.
    if (inUi) {
      if (uri.startsWith('package:drift')) {
        out.add('FD-4 $path imports $uri');
      }
      if (target != null && target.contains('/data/')) {
        out.add('FD-4 $path imports $target');
      }
    }
  }

  // FD-3: the API address lives only in quran/data.
  if (file.text.contains('alquran.cloud') &&
      !path.startsWith('lib/features/quran/data/')) {
    out.add('FD-3 $path mentions alquran.cloud');
  }
  return out;
}

List<SourceFile> _libFiles() {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map((f) {
        final path = f.path.replaceAll(r'\', '/');
        final text = f.readAsStringSync();
        return SourceFile(path, directivesOf(text), text);
      })
      .toList();
}

void main() {
  test('lib obeys FD-1..FD-4', () {
    final files = _libFiles();
    expect(files, isNotEmpty, reason: 'run from the repository root');
    expect(files.expand(violations).toList(), isEmpty);
  });

  group('detects a violating import', () {
    List<String> check(String path, List<String> uris, [String text = '']) =>
        violations(SourceFile(path, uris, text));

    test('FD-1: domain imports Flutter, drift or a data/ui file', () {
      const p = 'lib/features/counter/domain/x.dart';
      expect(check(p, ['package:flutter/material.dart']), hasLength(1));
      expect(check(p, ['package:drift/drift.dart']), hasLength(1));
      expect(check(p, ['../data/repo.dart']), hasLength(1));
      expect(
        check(p, ['package:zikirmatik/features/counter/ui/s.dart']),
        hasLength(1),
      );
      expect(
        check(p, ['dhikr_count.dart', '../../../core/result.dart']),
        isEmpty,
      );
    });

    test('FD-2: a feature imports another feature internals', () {
      const p = 'lib/features/suggested/ui/list.dart';
      expect(check(p, ['../../counter/domain/dhikr_count.dart']), hasLength(1));
      expect(
        check(p, ['package:zikirmatik/features/counter/counter.dart']),
        isEmpty,
      );
      expect(check(p, ['../../counter/counter.dart']), isEmpty);
    });

    test('FD-3: http or the API address outside quran/data', () {
      expect(
        check('lib/features/counter/data/x.dart', ['package:http/http.dart']),
        hasLength(1),
      );
      expect(
        check('lib/app/x.dart', [], "const u = 'https://api.alquran.cloud';"),
        hasLength(1),
      );
      expect(
        check(
          'lib/features/quran/data/api.dart',
          ['package:http/http.dart'],
          "const u = 'https://api.alquran.cloud';",
        ),
        isEmpty,
      );
    });

    test('FD-4: ui imports drift or a data file', () {
      const p = 'lib/features/counter/ui/s.dart';
      expect(check(p, ['package:drift/drift.dart']), hasLength(1));
      expect(check(p, ['../data/drift_counter_repository.dart']), hasLength(1));
      expect(check(p, ['counter_controller.dart']), isEmpty);
    });

    test('relative paths resolve against the importing file', () {
      expect(
        resolve('lib/features/a/ui/x.dart', '../../b/b.dart'),
        'lib/features/b/b.dart',
      );
      expect(
        resolve('lib/app/x.dart', 'package:zikirmatik/core/result.dart'),
        'lib/core/result.dart',
      );
      expect(
        resolve('lib/app/x.dart', 'package:flutter/material.dart'),
        isNull,
      );
    });
  });
}
