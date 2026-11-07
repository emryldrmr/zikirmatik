import '../../../core/hand_layout.dart';

/// Which theme the app uses (spec 0004, Requirement 3).
enum ThemeChoice {
  light,
  dark,

  /// Follows the phone's light/dark setting.
  system;

  /// The stored name of a choice; unknown names give null.
  static ThemeChoice? byName(String name) {
    for (final c in values) {
      if (c.name == name) return c;
    }
    return null;
  }
}

/// The user's preferences (spec 0004, spec 0009, spec 0010, spec 0011).
final class AppSettings {
  const AppSettings({
    required this.vibration,
    required this.theme,
    this.tapVibration = false,
    this.keepScreenOn = false,
    this.largeCount = false,
    this.handLayout = HandLayout.center,
  });

  /// A new install, and the fallback when settings cannot be read (AC-1, AC-6):
  /// vibration on, theme follows the phone, no vibration per count (spec 0009,
  /// AC-1, AC-6).
  static const AppSettings defaults = AppSettings(
    vibration: true,
    theme: ThemeChoice.system,
  );

  /// BR-4: whether a completed round vibrates.
  final bool vibration;

  final ThemeChoice theme;

  /// Spec 0009: whether every counted tap gives a short vibration.
  final bool tapVibration;

  /// Spec 0010: whether the screen stays on while Zikirlerim is in front.
  /// Off by default and when settings cannot be read (AC-8).
  final bool keepScreenOn;

  /// Spec 0011: whether the count digits are shown larger. Off by default and
  /// when settings cannot be read (AC-1).
  final bool largeCount;

  /// Spec 0011: which hand the counter is laid out for. Centre by default and
  /// when settings cannot be read (AC-1).
  final HandLayout handLayout;

  AppSettings copyWith({
    bool? vibration,
    ThemeChoice? theme,
    bool? tapVibration,
    bool? keepScreenOn,
    bool? largeCount,
    HandLayout? handLayout,
  }) => AppSettings(
    vibration: vibration ?? this.vibration,
    theme: theme ?? this.theme,
    tapVibration: tapVibration ?? this.tapVibration,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    largeCount: largeCount ?? this.largeCount,
    handLayout: handLayout ?? this.handLayout,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.vibration == vibration &&
      other.theme == theme &&
      other.tapVibration == tapVibration &&
      other.keepScreenOn == keepScreenOn &&
      other.largeCount == largeCount &&
      other.handLayout == handLayout;

  @override
  int get hashCode => Object.hash(
    vibration,
    theme,
    tapVibration,
    keepScreenOn,
    largeCount,
    handLayout,
  );

  @override
  String toString() =>
      'AppSettings(vibration: $vibration, theme: $theme, '
      'tapVibration: $tapVibration, keepScreenOn: $keepScreenOn, '
      'largeCount: $largeCount, handLayout: $handLayout)';
}
