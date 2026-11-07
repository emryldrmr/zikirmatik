import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeping the screen from dimming (spec 0010, Req. 8), behind an interface so
/// tests can prove it without a platform channel (docs/conventions.md, Known
/// traps).
abstract interface class ScreenAwake {
  /// Keeps the screen on ([on] true) or gives it back to the system.
  Future<void> set({required bool on});
}

/// Has no default: the composition root (`lib/app/`) overrides it with the
/// device implementation, tests with a fake.
final screenAwakeProvider = Provider<ScreenAwake>(
  (ref) => throw UnimplementedError(
    'screenAwakeProvider must be overridden in the composition root.',
  ),
);

/// Whether the screen stays on while Zikirlerim is in front (spec 0010,
/// AC-9). Defaults to off; the composition root binds it to the user's
/// setting, so the counter need not import the settings feature (FD-2).
final keepScreenOnEnabledProvider = Provider<bool>((ref) => false);

/// The phone's status and navigation bars (spec 0010, Req. 2 and 6).
abstract interface class SystemBars {
  /// Hides both bars (full screen).
  Future<void> hide();

  /// Brings both bars back as the rest of the app shows them.
  Future<void> show();
}

/// Has no default, like [screenAwakeProvider].
final systemBarsProvider = Provider<SystemBars>(
  (ref) => throw UnimplementedError(
    'systemBarsProvider must be overridden in the composition root.',
  ),
);
