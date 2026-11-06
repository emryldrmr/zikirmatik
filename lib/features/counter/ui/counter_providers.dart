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

/// Storage of the tesbihat's progress and selection (spec 0006). Overridden
/// like [counterRepositoryForProvider].
final tesbihatRepositoryProvider = Provider<TesbihatRepository>(
  (ref) => throw UnimplementedError(
    'tesbihatRepositoryProvider must be overridden in the composition root.',
  ),
);
