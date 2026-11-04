import 'package:flutter_test/flutter_test.dart';
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
}
