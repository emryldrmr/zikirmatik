import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/hand_layout.dart';
import 'package:zikirmatik/features/settings/domain/app_settings.dart';

void main() {
  test('defaults are vibration on and the system theme', () {
    expect(AppSettings.defaults.vibration, isTrue);
    expect(AppSettings.defaults.theme, ThemeChoice.system);
  });

  test('copyWith changes only the given field', () {
    const s = AppSettings.defaults;
    expect(
      s.copyWith(vibration: false),
      const AppSettings(vibration: false, theme: ThemeChoice.system),
    );
    expect(
      s.copyWith(theme: ThemeChoice.dark),
      const AppSettings(vibration: true, theme: ThemeChoice.dark),
    );
  });

  test('theme names round-trip and unknown names give null', () {
    for (final c in ThemeChoice.values) {
      expect(ThemeChoice.byName(c.name), c);
    }
    expect(ThemeChoice.byName('sepia'), isNull);
  });

  // Spec 0009, AC-1 / AC-6.
  test('vibration per count is off by default and changes alone', () {
    expect(AppSettings.defaults.tapVibration, isFalse);
    final on = AppSettings.defaults.copyWith(tapVibration: true);
    expect(on.tapVibration, isTrue);
    expect(on.vibration, AppSettings.defaults.vibration);
    expect(on.theme, AppSettings.defaults.theme);
    expect(on, isNot(AppSettings.defaults));
  });

  // Spec 0010, AC-8.
  test('keep screen on is off by default and changes alone', () {
    expect(AppSettings.defaults.keepScreenOn, isFalse);
    final on = AppSettings.defaults.copyWith(keepScreenOn: true);
    expect(on.keepScreenOn, isTrue);
    expect(on.vibration, AppSettings.defaults.vibration);
    expect(on.theme, AppSettings.defaults.theme);
    expect(on.tapVibration, AppSettings.defaults.tapVibration);
    expect(on, isNot(AppSettings.defaults));
  });

  // Spec 0011, AC-1.
  test('defaults have normal digits and centre', () {
    expect(AppSettings.defaults.largeCount, isFalse);
    expect(AppSettings.defaults.handLayout, HandLayout.center);
    final changed = AppSettings.defaults.copyWith(
      largeCount: true,
      handLayout: HandLayout.right,
    );
    expect(changed.largeCount, isTrue);
    expect(changed.handLayout, HandLayout.right);
    expect(changed.keepScreenOn, AppSettings.defaults.keepScreenOn);
    expect(changed.theme, AppSettings.defaults.theme);
    expect(changed, isNot(AppSettings.defaults));
    for (final h in HandLayout.values) {
      expect(HandLayout.byName(h.name), h);
    }
    expect(HandLayout.byName('both'), isNull);
  });
}
