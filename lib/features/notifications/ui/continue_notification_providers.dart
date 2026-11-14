import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/continue_notifier.dart';

/// The phone's notifications (spec 0017). Defaults to one that has no
/// permission and shows nothing; the composition root binds the device's,
/// tests a fake.
final continueNotifierProvider = Provider<ContinueNotifier>(
  (ref) => const NoContinueNotifier(),
);

/// Whether the continue notification is on (spec 0017, Req. 7). Off by
/// default (G3); the composition root binds it to the user's setting, so this
/// feature need not import the settings feature (FD-2).
final continueNotificationEnabledProvider = Provider<bool>((ref) => false);
