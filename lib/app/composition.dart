import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/haptics.dart';
import '../features/counter/counter.dart';
import 'database/app_database.dart';

/// Composition root: binds every feature's abstract dependencies to their
/// on-device implementations. Tests build their own overrides instead.
List<Override> appOverrides(AppDatabase db) => [
  counterRepositoryProvider.overrideWithValue(DriftCounterRepository(db)),
  hapticsProvider.overrideWithValue(const SystemHaptics()),
];

/// [Haptics] through the platform's haptic feedback (plan 0002, R1): needs no
/// permission and no package.
final class SystemHaptics implements Haptics {
  const SystemHaptics();

  @override
  Future<void> roundCompleted() => HapticFeedback.heavyImpact();
}
