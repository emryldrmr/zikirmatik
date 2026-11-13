import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/badges.dart';

/// The badges of the "Geçmiş" section (spec 0016): one horizontally
/// scrollable row in threshold order, then "Sıradaki rozete N gün" or
/// "Tüm rozetler kazanıldı.".
///
/// On entry the row starts with the latest earned badge at its left edge,
/// as far as the row's end allows (Req. 5, plan 0016 R2); later rebuilds (the
/// app back in the foreground) keep where the user scrolled. A mark shows on
/// each edge that has badges out of view; marks are visual only (AC-10).
class BadgeRow extends StatefulWidget {
  const BadgeRow({super.key, required this.progress});

  final BadgeProgress progress;

  @override
  State<BadgeRow> createState() => _BadgeRowState();
}

class _BadgeRowState extends State<BadgeRow> {
  final _controller = ScrollController();
  final _keys = {for (final b in StreakBadge.values) b: GlobalKey()};
  bool _hiddenBefore = false;
  bool _hiddenAfter = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAtLatest());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Puts the latest earned badge at the left edge. Only this row's own
  /// viewport moves; the section's vertical list stays where it is.
  void _startAtLatest() {
    if (!mounted || !_controller.hasClients) return;
    final latest = widget.progress.latestEarned;
    final box = latest == null
        ? null
        : _keys[latest]!.currentContext?.findRenderObject();
    if (box != null) {
      final reveal = RenderAbstractViewport.of(
        box,
      ).getOffsetToReveal(box, 0).offset;
      final p = _controller.position;
      _controller.jumpTo(reveal.clamp(p.minScrollExtent, p.maxScrollExtent));
    }
    _updateMarks();
  }

  void _updateMarks() {
    if (!mounted || !_controller.hasClients) return;
    final p = _controller.position;
    final before = p.extentBefore > 0.5;
    final after = p.extentAfter > 0.5;
    if (before != _hiddenBefore || after != _hiddenAfter) {
      setState(() {
        _hiddenBefore = before;
        _hiddenAfter = after;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numbers = NumberFormat.decimalPattern('tr');
    final progress = widget.progress;
    final days = progress.daysToNext;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            NotificationListener<Notification>(
              onNotification: (n) {
                if (n is ScrollNotification || n is ScrollMetricsNotification) {
                  _updateMarks();
                }
                return false;
              },
              // Not a lazy list: all five stay in the semantics tree, so a
              // screen reader reaches the ones out of view (plan 0016 R3).
              child: SingleChildScrollView(
                key: const Key('badge-row'),
                controller: _controller,
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final b in StreakBadge.values)
                      Padding(
                        key: _keys[b],
                        padding: EdgeInsets.only(
                          right: b == StreakBadge.values.last ? 0 : 8,
                        ),
                        child: _BadgeTile(
                          badge: b,
                          earned: progress.isEarned(b),
                          numbers: numbers,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_hiddenBefore)
              const _EdgeMark(key: Key('badge-mark-left'), left: true),
            if (_hiddenAfter)
              const _EdgeMark(key: Key('badge-mark-right'), left: false),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          days == null
              ? l10n.badgeAllEarned
              : l10n.badgeNext(numbers.format(days)),
          key: const Key('badge-next'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

String badgeName(AppLocalizations l10n, StreakBadge badge) => switch (badge) {
  StreakBadge.firstDay => l10n.badgeFirstDay,
  StreakBadge.week => l10n.badgeWeek,
  StreakBadge.month => l10n.badgeMonth,
  StreakBadge.hundred => l10n.badgeHundred,
  StreakBadge.year => l10n.badgeYear,
};

/// One badge: icon, name and, while unearned, its condition. Earned and
/// unearned differ by icon shape, colour and the condition text, never by
/// colour alone; no fixed size, so text never clips (AC-10, plan 0016 R4).
class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badge,
    required this.earned,
    required this.numbers,
  });

  final StreakBadge badge;
  final bool earned;
  final NumberFormat numbers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = badgeName(l10n, badge);
    final threshold = numbers.format(badge.threshold);
    return Semantics(
      container: true,
      label: earned
          ? l10n.badgeEarnedSemantics(name)
          : l10n.badgeLockedSemantics(name, threshold),
      excludeSemantics: true,
      child: Container(
        key: Key('badge-${badge.name}'),
        constraints: const BoxConstraints(minWidth: 88, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: earned ? colors.secondaryContainer : null,
          border: Border.all(
            color: earned ? colors.secondaryContainer : colors.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              earned
                  ? Icons.workspace_premium
                  : Icons.workspace_premium_outlined,
              key: Key('badge-${badge.name}-${earned ? 'earned' : 'locked'}'),
              size: 32,
              color: earned ? colors.primary : colors.outline,
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: earned ? FontWeight.bold : FontWeight.normal,
                color: earned
                    ? colors.onSecondaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
            if (!earned)
              Text(
                l10n.badgeCondition(threshold),
                key: Key('badge-${badge.name}-condition'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "More badges this way": visual only, lets touches through (AC-10).
class _EdgeMark extends StatelessWidget {
  const _EdgeMark({super.key, required this.left});

  final bool left;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: left ? Alignment.centerLeft : Alignment.centerRight,
                end: left ? Alignment.centerRight : Alignment.centerLeft,
                colors: [surface, surface.withValues(alpha: 0)],
              ),
            ),
            child: SizedBox(
              width: 32,
              child: Icon(
                left ? Icons.chevron_left : Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
