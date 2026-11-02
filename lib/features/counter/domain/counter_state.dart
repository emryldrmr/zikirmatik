import 'dhikr_count.dart';
import 'target.dart';

/// The whole state of one counter: count of the current round, completed
/// rounds, all-time total and the optional target (docs/domain.md).
///
/// Immutable; every rule returns a new state. Invariants: nothing is negative,
/// and with a target the count stays below it (BR-4).
final class CounterState {
  const CounterState({
    required this.count,
    this.rounds = 0,
    this.total = 0,
    this.target,
  }) : assert(rounds >= 0, 'Rounds are never negative.'),
       assert(total >= 0, 'The total is never negative.');

  static const CounterState initial = CounterState(count: DhikrCount.zero);

  final DhikrCount count;
  final int rounds;
  final int total;
  final Target? target;

  /// True when there is something a reset or a target change would clear.
  bool get hasProgress => count.value > 0 || rounds > 0;

  /// BR-3 and BR-4: one tap.
  TapOutcome tap() {
    final next = count.increment();
    final target = this.target;
    if (target != null && next.value >= target.value) {
      return TapOutcome(
        CounterState(
          count: DhikrCount.zero,
          rounds: rounds + 1,
          total: total + 1,
          target: target,
        ),
        roundCompleted: true,
      );
    }
    return TapOutcome(
      CounterState(
        count: next,
        rounds: rounds,
        total: total + 1,
        target: target,
      ),
      roundCompleted: false,
    );
  }

  /// BR-5: takes back one tap of the current round; at 0 nothing changes and a
  /// completed round is never taken back.
  CounterState undo() {
    if (count.value == 0) return this;
    return CounterState(
      count: DhikrCount(count.value - 1),
      rounds: rounds,
      total: total > 0 ? total - 1 : 0,
      target: target,
    );
  }

  /// BR-7: count and rounds go to 0; total and target stay.
  CounterState reset() =>
      CounterState(count: DhikrCount.zero, total: total, target: target);

  /// Spec 0002 (G4): a new target clears count and rounds; the total stays.
  CounterState changeTarget(Target? newTarget) =>
      CounterState(count: DhikrCount.zero, total: total, target: newTarget);

  @override
  bool operator ==(Object other) =>
      other is CounterState &&
      other.count == count &&
      other.rounds == rounds &&
      other.total == total &&
      other.target == target;

  @override
  int get hashCode => Object.hash(count, rounds, total, target);

  @override
  String toString() =>
      'CounterState(count: ${count.value}, rounds: $rounds, total: $total, '
      'target: ${target?.value})';
}

/// The result of [CounterState.tap].
final class TapOutcome {
  const TapOutcome(this.state, {required this.roundCompleted});

  final CounterState state;

  /// True when this tap completed a round (BR-4: vibrate once).
  final bool roundCompleted;
}
