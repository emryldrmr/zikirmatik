import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../domain/asma_name.dart';
import '../domain/esma_repository.dart';

/// The embedded Esma content (spec 0007). Has no default: the composition
/// root (`lib/app/`) binds the bundled file (plan 0007, A-1; FD-4).
final esmaRepositoryProvider = Provider<EsmaRepository>(
  (ref) => throw UnimplementedError(
    'esmaRepositoryProvider must be overridden in the composition root.',
  ),
);

/// The 99 names, loaded once.
final esmaNamesProvider = FutureProvider<List<AsmaName>>((ref) async {
  return switch (await ref.read(esmaRepositoryProvider).load()) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});
