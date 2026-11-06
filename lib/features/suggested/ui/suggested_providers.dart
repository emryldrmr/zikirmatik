import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../domain/suggested_dhikr.dart';
import '../domain/suggested_repository.dart';

/// The embedded suggested dhikrs (spec 0008). Has no default: the composition
/// root (`lib/app/`) binds the bundled file (as plan 0007, A-1; FD-4).
final suggestedRepositoryProvider = Provider<SuggestedRepository>(
  (ref) => throw UnimplementedError(
    'suggestedRepositoryProvider must be overridden in the composition root.',
  ),
);

/// The 7 dhikrs, loaded once.
final suggestedDhikrsProvider = FutureProvider<List<SuggestedDhikr>>((
  ref,
) async {
  return switch (await ref.read(suggestedRepositoryProvider).load()) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});
