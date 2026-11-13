/// The fixed streak badges (spec 0016, Req. 1), in threshold order.
///
/// Named `StreakBadge`, not `Badge`, so it never clashes with Flutter's
/// `Badge` widget in the UI.
enum StreakBadge {
  firstDay(1),
  week(7),
  month(30),
  hundred(100),
  year(365);

  const StreakBadge(this.threshold);

  /// The longest streak, in days, that earns this badge.
  final int threshold;
}

/// Which badges are earned and how far the next one is (spec 0016).
///
/// Built from the longest streak and the current streak of the daily history
/// (spec 0014, Req. 5), so days after "today" never earn a badge (G1) and an
/// earned badge stays earned when the streak breaks (Req. 2).
final class BadgeProgress {
  BadgeProgress({required this.longest, required this.current})
    : assert(current >= 0 && current <= longest);

  /// The longest streak in days.
  final int longest;

  /// The current streak in days.
  final int current;

  /// Req. 2: earned when the longest streak reaches the threshold.
  bool isEarned(StreakBadge badge) => longest >= badge.threshold;

  /// The earned badge with the largest threshold, or null when none is
  /// earned (Req. 5).
  StreakBadge? get latestEarned {
    StreakBadge? latest;
    for (final b in StreakBadge.values) {
      if (isEarned(b)) latest = b;
    }
    return latest;
  }

  /// Req. 3: the unearned badge with the smallest threshold, or null when all
  /// five are earned.
  StreakBadge? get next {
    for (final b in StreakBadge.values) {
      if (!isEarned(b)) return b;
    }
    return null;
  }

  /// Req. 3: the next badge's threshold minus the current streak; null when
  /// all are earned. Never below 1, because the current streak is at most
  /// the longest one, which is below that threshold (G2).
  int? get daysToNext {
    final n = next;
    return n == null ? null : n.threshold - current;
  }
}
