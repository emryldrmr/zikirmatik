import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vibration, behind an interface so tests can prove it without a platform
/// channel (docs/conventions.md, Known traps).
abstract interface class Haptics {
  /// BR-4: a round was completed.
  Future<void> roundCompleted();

  /// Spec 0009: a short vibration for one counted tap.
  Future<void> tap();
}

/// Has no default: the composition root (`lib/app/`) overrides it with the
/// device implementation, tests with a fake.
final hapticsProvider = Provider<Haptics>(
  (ref) => throw UnimplementedError(
    'hapticsProvider must be overridden in the composition root.',
  ),
);

/// Whether a completed round vibrates (BR-4; spec 0004, AC-2). Defaults to on;
/// the composition root binds it to the user's setting, so features that
/// vibrate need not import the settings feature (docs/architecture.md, FD-2).
final vibrationEnabledProvider = Provider<bool>((ref) => true);

/// Whether every counted tap vibrates briefly (spec 0009). Defaults to off;
/// bound to the user's setting by the composition root, like
/// [vibrationEnabledProvider].
final tapVibrationEnabledProvider = Provider<bool>((ref) => false);

/// The vibration after one tap that changed the count (spec 0009, Req. 2–3,
/// AC-4): a round vibration when the tap completed a round and round
/// vibration is on — only that one; otherwise a short one when vibration per
/// count is on. Best effort: a failing vibration is swallowed (AC-7). Callers
/// never await it before the save (docs/conventions.md, Known traps).
Future<void> vibrateAfterTap(
  Ref<Object?> ref, {
  required bool roundCompleted,
}) async {
  final haptics = ref.read(hapticsProvider);
  try {
    if (roundCompleted && ref.read(vibrationEnabledProvider)) {
      await haptics.roundCompleted();
    } else if (ref.read(tapVibrationEnabledProvider)) {
      await haptics.tap();
    }
  } on Object catch (_) {
    // Haptics are best effort.
  }
}
