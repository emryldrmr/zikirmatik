import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/history/domain/badges.dart';
import 'package:zikirmatik/features/history/domain/daily_history.dart';

// Spec 0016 — Rozetler, rules (AC-2, AC-3, AC-4).

final _today = Day(2026, 11, 13);

/// [length] consecutive counted days ending on [last].
Map<Day, int> _run(Day last, int length) {
  final map = <Day, int>{};
  var day = last;
  for (var i = 0; i < length; i++) {
    map[day] = 1;
    day = day.previous;
  }
  return map;
}

BadgeProgress _of(DailyHistory h) =>
    BadgeProgress(longest: h.longestStreak(_today), current: h.streak(_today));

void main() {
  test('five badges in threshold order', () {
    expect(StreakBadge.values.map((b) => b.threshold), [1, 7, 30, 100, 365]);
  });

  test('earned at and above each threshold', () {
    const expected = <int, List<StreakBadge>>{
      0: [],
      1: [StreakBadge.firstDay],
      6: [StreakBadge.firstDay],
      7: [StreakBadge.firstDay, StreakBadge.week],
      29: [StreakBadge.firstDay, StreakBadge.week],
      30: [StreakBadge.firstDay, StreakBadge.week, StreakBadge.month],
      99: [StreakBadge.firstDay, StreakBadge.week, StreakBadge.month],
      100: [
        StreakBadge.firstDay,
        StreakBadge.week,
        StreakBadge.month,
        StreakBadge.hundred,
      ],
      364: [
        StreakBadge.firstDay,
        StreakBadge.week,
        StreakBadge.month,
        StreakBadge.hundred,
      ],
      365: StreakBadge.values,
      400: StreakBadge.values,
    };
    for (final MapEntry(key: longest, value: earned) in expected.entries) {
      final p = BadgeProgress(longest: longest, current: 0);
      expect(
        StreakBadge.values.where(p.isEarned).toList(),
        earned,
        reason: 'longest $longest',
      );
      expect(p.latestEarned, earned.isEmpty ? null : earned.last);
    }
  });

  test('the history earns by its longest streak', () {
    final p = _of(DailyHistory(_run(_today, 30)));
    expect(p.isEarned(StreakBadge.month), isTrue);
    expect(p.isEarned(StreakBadge.hundred), isFalse);
  });

  test('future days earn nothing', () {
    // Seven consecutive counted days, all after today (clock set back, G1).
    final p = _of(DailyHistory(_run(Day(2026, 11, 20), 7)));
    expect(p.isEarned(StreakBadge.firstDay), isFalse);
    expect(p.isEarned(StreakBadge.week), isFalse);
    expect(p.latestEarned, isNull);
    expect(p.daysToNext, 1);
  });

  test('a broken streak keeps earned badges', () {
    // 40 days long ago, then a gap, then today alone: streak 1, longest 40.
    final h = DailyHistory({..._run(Day(2026, 9, 30), 40), _today: 2});
    final p = _of(h);
    expect(p.current, 1);
    expect(p.isEarned(StreakBadge.month), isTrue);
    expect(p.latestEarned, StreakBadge.month);

    // And with no streak at all today.
    final none = _of(DailyHistory(_run(Day(2026, 9, 30), 40)));
    expect(none.current, 0);
    expect(none.isEarned(StreakBadge.month), isTrue);
  });

  test('days to next badge examples', () {
    expect(BadgeProgress(longest: 40, current: 5).daysToNext, 95);
    expect(BadgeProgress(longest: 40, current: 5).next, StreakBadge.hundred);
    expect(BadgeProgress(longest: 0, current: 0).daysToNext, 1);
    // Today not counted yet, six days up to yesterday: streak 6 → one day.
    final p = _of(DailyHistory(_run(_today.previous, 6)));
    expect((p.current, p.longest), (6, 6));
    expect(p.daysToNext, 1);
    expect(BadgeProgress(longest: 365, current: 3).next, isNull);
    expect(BadgeProgress(longest: 365, current: 3).daysToNext, isNull);
  });

  test('days to next is never below one', () {
    for (var longest = 0; longest <= 400; longest++) {
      for (var current = 0; current <= longest; current++) {
        final n = BadgeProgress(longest: longest, current: current).daysToNext;
        if (n != null) {
          expect(n, greaterThanOrEqualTo(1), reason: '$current / $longest');
        } else {
          expect(longest, greaterThanOrEqualTo(365));
        }
      }
    }
  });
}
