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

/// The user's preferences (spec 0004).
final class AppSettings {
  const AppSettings({required this.vibration, required this.theme});

  /// A new install, and the fallback when settings cannot be read (AC-1, AC-6):
  /// vibration on, theme follows the phone.
  static const AppSettings defaults = AppSettings(
    vibration: true,
    theme: ThemeChoice.system,
  );

  /// BR-4: whether a completed round vibrates.
  final bool vibration;

  final ThemeChoice theme;

  AppSettings copyWith({bool? vibration, ThemeChoice? theme}) => AppSettings(
    vibration: vibration ?? this.vibration,
    theme: theme ?? this.theme,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.vibration == vibration &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(vibration, theme);

  @override
  String toString() => 'AppSettings(vibration: $vibration, theme: $theme)';
}
