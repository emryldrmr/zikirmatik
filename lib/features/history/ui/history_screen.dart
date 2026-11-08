import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/clock.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/daily_history.dart';
import 'history_controller.dart';

/// "Geçmiş" body (spec 0014): the streak, the longest streak and the last 30
/// days from today backwards.
///
/// "Today" is read from the clock on every build; the screen builds again
/// when the app returns to the foreground, so a midnight passed in between
/// shows the new day (AC-4, plan 0014 R3).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => setState(() {}));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = Day.of(ref.read(clockProvider)());
    return switch (ref.watch(historyControllerProvider)) {
      AsyncData(:final value) => _History(history: value, today: today),
      AsyncError() => Center(
        child: Text(
          l10n.historyLoadFailed,
          key: const Key('history-error'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      _ => Center(
        child: CircularProgressIndicator(
          key: const Key('history-loading'),
          semanticsLabel: l10n.historyLoading,
        ),
      ),
    };
  }
}

class _History extends StatelessWidget {
  const _History({required this.history, required this.today});

  final DailyHistory history;
  final Day today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numbers = NumberFormat.decimalPattern('tr');
    final theme = Theme.of(context);
    // Each streak line is its own screen reader item (AC-10).
    final streaks = [
      Semantics(
        container: true,
        child: Text(
          l10n.historyStreak(numbers.format(history.streak(today))),
          key: const Key('history-streak'),
          style: theme.textTheme.titleLarge,
        ),
      ),
      const SizedBox(height: 4),
      Semantics(
        container: true,
        child: Text(
          l10n.historyLongestStreak(
            numbers.format(history.longestStreak(today)),
          ),
          key: const Key('history-longest'),
          style: theme.textTheme.titleMedium,
        ),
      ),
    ];
    if (history.isEmptyUpTo(today)) {
      return ListView(
        key: const Key('history-list'),
        padding: const EdgeInsets.all(16),
        children: [
          ...streaks,
          const SizedBox(height: 24),
          Text(
            l10n.historyEmpty,
            key: const Key('history-empty'),
            style: theme.textTheme.bodyLarge,
          ),
        ],
      );
    }
    final rows = history.lastDays(today);
    return ListView.builder(
      key: const Key('history-list'),
      itemCount: rows.length + 1,
      itemBuilder: (context, i) => i == 0
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: streaks,
              ),
            )
          : _DayRow(row: rows[i - 1], isToday: i == 1, numbers: numbers),
    );
  }
}

/// One day: "Bugün" or "8 Kasım 2026, Pazar", and its count. Read as one
/// item by a screen reader (AC-10).
class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.row,
    required this.isToday,
    required this.numbers,
  });

  final DayCount row;
  final bool isToday;
  final NumberFormat numbers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = isToday
        ? l10n.historyToday
        : DateFormat('d MMMM y, EEEE', 'tr').format(row.day.localDate);
    final count = numbers.format(row.count);
    return MergeSemantics(
      child: Semantics(
        label: l10n.historyRowSemantics(date, count),
        excludeSemantics: true,
        child: ConstrainedBox(
          key: Key('history-day-${row.day.iso}'),
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(date)),
                const SizedBox(width: 16),
                Text(count, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
