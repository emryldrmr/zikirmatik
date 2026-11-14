import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/notifications/data/local_continue_notifier.dart';

// Spec 0017 — the continue notification is silent and replaceable (Req. 4;
// AC-5).

void main() {
  test('continue details are silent and replaceable', () {
    final android = continueDetails(channelName: 'Yarım kalan zikir').android!;

    expect(android.channelName, 'Yarım kalan zikir');
    // No sound, no vibration, no heads-up: low importance and priority.
    expect(android.playSound, isFalse);
    expect(android.enableVibration, isFalse);
    expect(android.enableLights, isFalse);
    expect(android.importance, Importance.low);
    expect(android.priority, Priority.low);
    expect(android.onlyAlertOnce, isTrue);
    expect(android.fullScreenIntent, isFalse);
    // Swipe to dismiss; on the lock screen too (G4).
    expect(android.ongoing, isFalse);
    expect(android.visibility, NotificationVisibility.public);
    expect(android.icon, 'ic_stat_continue');
  });
}
