import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/counter_repository.dart';

/// The counter's storage. Has no default: the composition root (`lib/app/`)
/// overrides it with the on-device implementation, tests with a fake.
final counterRepositoryProvider = Provider<CounterRepository>(
  (ref) => throw UnimplementedError(
    'counterRepositoryProvider must be overridden in the composition root.',
  ),
);
