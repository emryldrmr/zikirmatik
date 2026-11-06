import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/haptics.dart';
import '../features/counter/counter.dart';
import '../features/esma/esma.dart';
import '../features/settings/settings.dart';
import 'database/app_database.dart';

/// Composition root: binds every feature's abstract dependencies to their
/// on-device implementations. Tests build their own overrides instead, but
/// share [featureWiring].
List<Override> appOverrides(AppDatabase db) => [
  counterRepositoryForProvider.overrideWithValue(
    (dhikrId) => DriftCounterRepository(db, dhikrId: dhikrId),
  ),
  dhikrListRepositoryProvider.overrideWithValue(DriftDhikrListRepository(db)),
  tesbihatRepositoryProvider.overrideWithValue(DriftTesbihatRepository(db)),
  settingsRepositoryProvider.overrideWithValue(DriftSettingsRepository(db)),
  esmaRepositoryProvider.overrideWithValue(AssetEsmaRepository(rootBundle)),
  hapticsProvider.overrideWithValue(const SystemHaptics()),
  ...featureWiring(),
];

/// Connections between features that the features themselves may not make
/// (docs/architecture.md, FD-2). The app and the tests use the same list.
List<Override> featureWiring() => [
  // Spec 0004, AC-2: the round vibration follows the user's setting.
  vibrationEnabledProvider.overrideWith(
    (ref) =>
        ref.watch(settingsControllerProvider).valueOrNull?.vibration ??
        AppSettings.defaults.vibration,
  ),
];

/// [Haptics] through the platform's haptic feedback (plan 0002, R1): needs no
/// permission and no package.
final class SystemHaptics implements Haptics {
  const SystemHaptics();

  @override
  Future<void> roundCompleted() => HapticFeedback.heavyImpact();
}
