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
