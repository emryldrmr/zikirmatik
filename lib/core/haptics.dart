import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vibration, behind an interface so tests can prove it without a platform
/// channel (docs/conventions.md, Known traps).
abstract interface class Haptics {
  /// BR-4: a round was completed.
  Future<void> roundCompleted();
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
