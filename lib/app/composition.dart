import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/app_version.dart';
import '../core/haptics.dart';
import '../core/screen.dart';
import '../features/counter/counter.dart';
import '../features/esma/esma.dart';
import '../features/settings/settings.dart';
import '../features/suggested/suggested.dart';
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
  suggestedRepositoryProvider.overrideWithValue(
    AssetSuggestedRepository(rootBundle),
  ),
  hapticsProvider.overrideWithValue(const SystemHaptics()),
  screenAwakeProvider.overrideWithValue(const ChannelScreenAwake()),
  systemBarsProvider.overrideWithValue(const SystemChromeBars()),
  appVersionProvider.overrideWith((ref) => installedVersion()),
  ...featureWiring(),
];

/// The installed app's version name (spec 0009, plan R1); null when the
/// platform cannot tell (AC-8: then no version row).
Future<String?> installedVersion() async {
  try {
    final version = (await PackageInfo.fromPlatform()).version;
    return version.isEmpty ? null : version;
  } on Object catch (_) {
    return null;
  }
}

/// Connections between features that the features themselves may not make
/// (docs/architecture.md, FD-2). The app and the tests use the same list.
List<Override> featureWiring() => [
  // Spec 0004, AC-2: the round vibration follows the user's setting.
  vibrationEnabledProvider.overrideWith(
    (ref) =>
        ref.watch(settingsControllerProvider).valueOrNull?.vibration ??
        AppSettings.defaults.vibration,
  ),
  // Spec 0009, AC-2/AC-6: vibration per count follows the user's setting.
  tapVibrationEnabledProvider.overrideWith(
    (ref) =>
        ref.watch(settingsControllerProvider).valueOrNull?.tapVibration ??
        AppSettings.defaults.tapVibration,
  ),
  // Spec 0010, AC-8/AC-9: keeping the screen on follows the user's setting.
  keepScreenOnEnabledProvider.overrideWith(
    (ref) =>
        ref.watch(settingsControllerProvider).valueOrNull?.keepScreenOn ??
        AppSettings.defaults.keepScreenOn,
  ),
];

/// [ScreenAwake] through the app's own channel to `MainActivity`, which sets
/// or clears the window's keep-screen-on flag (plan 0010, R1): needs no
/// permission and no package. Best effort: a failing call is swallowed.
final class ChannelScreenAwake implements ScreenAwake {
  const ChannelScreenAwake();

  static const _channel = MethodChannel('zikirmatik/screen');

  @override
  Future<void> set({required bool on}) async {
    try {
      await _channel.invokeMethod<void>('setKeepScreenOn', on);
    } on Object catch (_) {
      // Keeping the screen on is a convenience; counting goes on without it.
    }
  }
}

/// [SystemBars] through Flutter's system chrome (plan 0010, R4).
final class SystemChromeBars implements SystemBars {
  const SystemChromeBars();

  @override
  Future<void> hide() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  /// Flutter cannot read the previous mode; this is the app's normal one.
  @override
  Future<void> show() => SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
}

/// [Haptics] through the platform's haptic feedback (plan 0002, R1): needs no
/// permission and no package.
final class SystemHaptics implements Haptics {
  const SystemHaptics();

  @override
  Future<void> roundCompleted() => HapticFeedback.heavyImpact();

  /// Spec 0009 (plan R2): lighter than a round, so the two feel different.
  @override
  Future<void> tap() => HapticFeedback.lightImpact();
}
