/// The phone's notifications for "where you left off" (spec 0017), behind an
/// interface so tests can prove them without a platform channel
/// (docs/conventions.md, Known traps).
abstract interface class ContinueNotifier {
  /// Shows the single continue notification, replacing an earlier one
  /// (Req. 4). [payload] comes back from [taps] or [launchPayload].
  Future<void> show({
    required String title,
    required String body,
    required String payload,
  });

  /// Removes the continue notification, if shown (Req. 6).
  Future<void> cancel();

  /// Whether the app may show notifications now (Req. 8).
  Future<bool> permitted();

  /// Asks the user, where the phone needs it (Android 13+); true when allowed.
  Future<bool> requestPermission();

  /// The payload of the notification that started the app, if one did
  /// (Req. 5, cold start).
  Future<String?> launchPayload();

  /// Payloads of notifications tapped while the app runs (Req. 5).
  Stream<String> get taps;
}

/// A notifier with no permission that shows nothing: the default until the
/// composition root binds the device's one.
final class NoContinueNotifier implements ContinueNotifier {
  const NoContinueNotifier();

  @override
  Future<void> show({
    required String title,
    required String body,
    required String payload,
  }) async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<bool> permitted() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> launchPayload() async => null;

  @override
  Stream<String> get taps => const Stream.empty();
}
