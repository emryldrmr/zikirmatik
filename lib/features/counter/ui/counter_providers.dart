import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/counter_repository.dart';
import '../domain/dhikr_list_repository.dart';
import '../domain/tesbihat_repository.dart';

/// Builds the storage of one dhikr's counter (spec 0003). Has no default: the
/// composition root (`lib/app/`) overrides it with the on-device
/// implementation, tests with a fake.
final counterRepositoryForProvider = Provider<CounterRepository Function(int)>(
  (ref) => throw UnimplementedError(
    'counterRepositoryForProvider must be overridden in the composition root.',
  ),
);

/// Storage of the user's dhikrs and the selection (spec 0003). Overridden like
/// [counterRepositoryForProvider].
final dhikrListRepositoryProvider = Provider<DhikrListRepository>(
  (ref) => throw UnimplementedError(
    'dhikrListRepositoryProvider must be overridden in the composition root.',
  ),
);

/// Told about every tap that changed a count, on a dhikr or the tesbihat
/// (spec 0014): [counted] after a tap added one, [uncounted] after an undo
/// took one back. Reset, target changes and restarts are never reported
/// (AC-3). Calls are synchronous and never fail; a listener does its own
/// work unawaited, so counting is never held up (spec 0014, G5).
abstract interface class CountLog {
  void counted();

  void uncounted();
}

final class _NoCountLog implements CountLog {
  const _NoCountLog();

  @override
  void counted() {}

  @override
  void uncounted() {}
}

/// Defaults to a log that does nothing; the composition root binds it to the
/// daily history, so the counter need not import that feature (FD-2).
final countLogProvider = Provider<CountLog>((ref) => const _NoCountLog());

/// Storage of the tesbihat's progress and selection (spec 0006). Overridden
/// like [counterRepositoryForProvider].
final tesbihatRepositoryProvider = Provider<TesbihatRepository>(
  (ref) => throw UnimplementedError(
    'tesbihatRepositoryProvider must be overridden in the composition root.',
  ),
);
