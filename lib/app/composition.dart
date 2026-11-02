import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/counter/counter.dart';
import 'database/app_database.dart';

/// Composition root: binds every feature's abstract dependencies to their
/// on-device implementations. Tests build their own overrides instead.
List<Override> appOverrides(AppDatabase db) => [
  counterRepositoryProvider.overrideWithValue(DriftCounterRepository(db)),
];
