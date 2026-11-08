import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/history/domain/daily_history.dart';

// Spec 0014 — Günlük geçmiş ve seri, rules (AC-5, AC-7).

DailyHistory _days(Day from, List<int> counts) {
  final map = <Day, int>{};
  var day = from;
  for (final n in counts) {
    map[day] = n;
    day = day.next;
  }
  return DailyHistory(map);
}

void main() {
  group('Day', () {
    test('steps across month, year and leap day', () {
      expect(Day(2026, 1, 1).previous, Day(2025, 12, 31));
      expect(Day(2026, 2, 28).next, Day(2026, 3, 1));
      expect(Day(2028, 2, 28).next, Day(2028, 2, 29));
      expect(Day(2026, 10, 31).next, Day(2026, 11, 1));
    });

    test('the day of a moment is its local calendar day', () {
      expect(Day.of(DateTime(2026, 11, 8, 23, 59, 59)), Day(2026, 11, 8));
      expect(Day.of(DateTime(2026, 11, 9)), Day(2026, 11, 9));
    });

    test('stored form round-trips and rejects anything else', () {
      expect(Day(2026, 3, 5).iso, '2026-03-05');
      expect(Day.tryParse('2026-03-05'), Day(2026, 3, 5));
      for (final bad in ['2026-02-30', '2026-3-5', '', 'x', '2026-13-01']) {
        expect(Day.tryParse(bad), isNull, reason: bad);
      }
    });
  });

  final today = Day(2026, 11, 8);

  group('streak', () {
    test('no counts: streak and longest are zero', () {
      expect(DailyHistory.empty.streak(today), 0);
      expect(DailyHistory.empty.longestStreak(today), 0);
      expect(DailyHistory.empty.isEmptyUpTo(today), isTrue);
    });

    test('a single day today is a streak of one', () {
      final h = DailyHistory({today: 1});
      expect(h.streak(today), 1);
      expect(h.longestStreak(today), 1);
    });

    test('streak counts from yesterday when today is empty', () {
      final h = _days(Day(2026, 11, 5), [3, 1, 7]); // 5, 6, 7 Nov
      expect(h.countOn(today), 0);
      expect(h.streak(today), 3);
    });

    test('today and yesterday empty: streak is zero', () {
      final h = _days(Day(2026, 11, 4), [3, 1, 7]); // 4, 5, 6 Nov
      expect(h.streak(today), 0);
      expect(h.longestStreak(today), 3);
    });

    test('a zero day breaks the streak', () {
      final h = _days(Day(2026, 11, 3), [5, 5, 5, 0, 2, 2]); // ... 8 Nov
      expect(h.streak(today), 2);
      expect(h.longestStreak(today), 3);
    });

    test('longest streak across month and year', () {
      final h = _days(Day(2025, 12, 30), [1, 1, 1, 1]); // 30 Dec .. 2 Jan
      final day = Day(2026, 1, 2);
      expect(h.streak(day), 4);
      expect(h.longestStreak(day), 4);
      final month = _days(Day(2026, 10, 30), [1, 1, 1]); // 30 Oct .. 1 Nov
      expect(month.streak(Day(2026, 11, 1)), 3);
    });

    test('streak longer than thirty days', () {
      final h = _days(Day(2026, 8, 1), List.filled(100, 1)); // .. 8 Nov
      expect(h.streak(today), 100);
      expect(h.longestStreak(today), 100);
      expect(h.streak(today) <= h.longestStreak(today), isTrue);
    });

    test('future days are outside the streak', () {
      final h = DailyHistory({
        today: 1,
        today.next: 4,
        today.next.next: 4,
        today.next.next.next: 4,
      });
      expect(h.streak(today), 1);
      expect(h.longestStreak(today), 1);
      expect(DailyHistory({today.next: 4}).isEmptyUpTo(today), isTrue);
    });
  });

  group('counts', () {
    test('added and removed change one day, never below zero', () {
      final h = DailyHistory.empty.added(today).added(today);
      expect(h.countOn(today), 2);
      final back = h.removed(today).removed(today).removed(today);
      expect(back.countOn(today), 0);
      expect(back, DailyHistory.empty);
      final yesterday = DailyHistory({today.previous: 5}).removed(today);
      expect(yesterday.countOn(today.previous), 5);
    });

    test('last days run from today backwards with zeros', () {
      final h = DailyHistory({today: 2, Day(2026, 11, 6): 9});
      final rows = h.lastDays(today);
      expect(rows, hasLength(30));
      expect(rows.first, (day: today, count: 2));
      expect(rows[1], (day: Day(2026, 11, 7), count: 0));
      expect(rows[2], (day: Day(2026, 11, 6), count: 9));
      expect(rows.last.day, Day(2026, 10, 10));
    });
  });
}
