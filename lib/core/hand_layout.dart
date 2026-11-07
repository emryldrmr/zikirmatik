/// Which hand the counter is laid out for (spec 0011, Req. 4–5). Pure Dart, so
/// the settings domain and the counter's screens share it (plan 0011, R1).
enum HandLayout {
  /// Today's layout: the device in the middle, "Geri al" top left.
  center,

  /// The device near the right edge; "Geri al" bottom right in full screen.
  right,

  /// The device near the left edge; "Geri al" bottom left in full screen.
  left;

  /// The stored name of a layout; unknown names give null.
  static HandLayout? byName(String name) {
    for (final h in values) {
      if (h.name == name) return h;
    }
    return null;
  }
}
