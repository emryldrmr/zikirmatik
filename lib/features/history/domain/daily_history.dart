/// A local calendar day without a time (spec 0014, Req. 4: the day changes at
/// 00:00 on the phone's clock). Day arithmetic runs on UTC dates, so daylight
/// saving never skips or repeats a day.
final class Day implements Comparable<Day> {
  Day(int year, int month, int day) : _utc = DateTime.utc(year, month, day);

  /// The day [moment] falls on, in [moment]'s own time zone.
  Day.of(DateTime moment) : this(moment.year, moment.month, moment.day);

  Day._(this._utc);

  /// Parses `YYYY-MM-DD`; null for anything else, including impossible dates.
  static Day? tryParse(String text) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (m == null) return null;
    final day = Day(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    return day.iso == text ? day : null;
  }

  final DateTime _utc;

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  Day get previous => Day._(_utc.subtract(const Duration(days: 1)));
  Day get next => Day._(_utc.add(const Duration(days: 1)));

  bool isAfter(Day other) => _utc.isAfter(other._utc);

  /// `YYYY-MM-DD`, the stored form.
  String get iso =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// Midnight of this day in local time, for formatting.
  DateTime get localDate => DateTime(year, month, day);

  @override
  int compareTo(Day other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) => other is Day && other._utc == _utc;

  @override
  int get hashCode => _utc.hashCode;

  @override
  String toString() => 'Day($iso)';
}

/// One row of the history list: a day and its count.
typedef DayCount = ({Day day, int count});

/// How many counting taps each day had (spec 0014). Immutable; days without a
/// count are not kept. Days after "today" (the clock was set back) are kept
/// but never shown and never part of a streak (G1).
final class DailyHistory {
  DailyHistory(Map<Day, int> counts)
    : _counts = Map.unmodifiable({
        for (final e in counts.entries)
          if (e.value > 0) e.key: e.value,
      });

  static final DailyHistory empty = DailyHistory(const {});

  final Map<Day, int> _counts;

  int countOn(Day day) => _counts[day] ?? 0;

  /// True when no day up to [today] has a count (AC-8, empty state).
  bool isEmptyUpTo(Day today) => !_counts.keys.any((d) => !d.isAfter(today));

  /// Req. 1: one more counting tap on [day].
  DailyHistory added(Day day) =>
      DailyHistory({..._counts, day: countOn(day) + 1});

  /// Req. 2: one tap taken back on [day]; at 0 nothing changes.
  DailyHistory removed(Day day) {
    final n = countOn(day);
    if (n == 0) return this;
    return DailyHistory({..._counts, day: n - 1});
  }

  /// Req. 5: consecutive counted days ending today, or yesterday when today
  /// has no count yet.
  int streak(Day today) {
    var day = countOn(today) > 0 ? today : today.previous;
    var n = 0;
    while (countOn(day) > 0) {
      n++;
      day = day.previous;
    }
    return n;
  }

  /// Req. 5: the longest run of consecutive counted days up to [today].
  int longestStreak(Day today) {
    final days = _counts.keys.where((d) => !d.isAfter(today)).toList()..sort();
    var longest = 0;
    var run = 0;
    Day? last;
    for (final d in days) {
      run = (last != null && last.next == d) ? run + 1 : 1;
      if (run > longest) longest = run;
      last = d;
    }
    return longest;
  }

  /// Req. 6: [length] days from [today] backwards, days without a count as 0.
  List<DayCount> lastDays(Day today, {int length = 30}) {
    final rows = <DayCount>[];
    var day = today;
    for (var i = 0; i < length; i++) {
      rows.add((day: day, count: countOn(day)));
      day = day.previous;
    }
    return rows;
  }

  @override
  bool operator ==(Object other) =>
      other is DailyHistory &&
      other._counts.length == _counts.length &&
      _counts.entries.every((e) => other._counts[e.key] == e.value);

  @override
  int get hashCode => Object.hashAllUnordered(
    _counts.entries.map((e) => Object.hash(e.key, e.value)),
  );

  @override
  String toString() => 'DailyHistory($_counts)';
}
