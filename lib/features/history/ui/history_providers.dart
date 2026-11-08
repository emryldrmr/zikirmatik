import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/history_repository.dart';

/// Storage of the daily counts (spec 0014). Has no default: the composition
/// root (`lib/app/`) overrides it with the on-device implementation, tests
/// with a fake.
final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => throw UnimplementedError(
    'historyRepositoryProvider must be overridden in the composition root.',
  ),
);
