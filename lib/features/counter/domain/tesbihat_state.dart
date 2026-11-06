import 'dhikr_count.dart';
import 'tesbihat.dart';

/// Progress through a tesbihat (spec 0006): the current step, that step's
/// count, whether it is finished, how many times it was finished, and whether
/// the tesbihat is the selection on Zikirlerim.
///
/// Immutable; every rule returns a new state. Invariants: nothing is negative,
/// the count stays below the step's target (the tap that reaches it moves on in
/// the same operation, like BR-4), and a finished tesbihat has count 0 on its
/// last step.
final class TesbihatState {
  const TesbihatState({
    this.step = 0,
    this.count = DhikrCount.zero,
    this.finished = false,
    this.completions = 0,
    this.selected = false,
  }) : assert(step >= 0, 'The step is never negative.'),
       assert(completions >= 0, 'Completions are never negative.');

  static const TesbihatState initial = TesbihatState();

  /// Index of the current step (0 is the first).
  final int step;
  final DhikrCount count;
  final bool finished;

  /// "Tamamlanan": how many times the tesbihat was finished.
  final int completions;

  /// True when Zikirlerim shows the tesbihat instead of a dhikr.
  final bool selected;

  /// True when [step] and [count] fit [sequence]; storage uses it to reject a
  /// row that does not (spec 0006 R4: a count is never stored at its target).
  bool fits(Tesbihat sequence) {
    if (step >= sequence.steps.length) return false;
    if (finished) return count.value == 0 && step == sequence.steps.length - 1;
    return count.value < sequence.steps[step].target.value;
  }

  /// AC-3, AC-4: one tap. Reaching the step's target moves to the next step
  /// at count 0, or finishes the tesbihat on the last step; both vibrate.
  /// A finished tesbihat ignores taps.
  TesbihatTap tap(Tesbihat sequence) {
    if (finished) return TesbihatTap(this, vibrate: false);
    final next = count.increment();
    if (next.value < sequence.steps[step].target.value) {
      return TesbihatTap(_copy(count: next), vibrate: false);
    }
    final last = step == sequence.steps.length - 1;
    return TesbihatTap(
      last
          ? _copy(
              count: DhikrCount.zero,
              finished: true,
              completions: completions + 1,
            )
          : _copy(step: step + 1, count: DhikrCount.zero),
      vibrate: true,
    );
  }

  /// AC-5: takes back one tap within the step; at 0, or when finished,
  /// nothing changes (a step or a completion is never taken back, like BR-5).
  TesbihatState undo() {
    if (finished || count.value == 0) return this;
    return _copy(count: DhikrCount(count.value - 1));
  }

  /// AC-4 "Baştan başla" and AC-6 "Sıfırla": the first step at count 0; the
  /// completions stay (like BR-7).
  TesbihatState restart() =>
      TesbihatState(completions: completions, selected: selected);

  /// Selects or deselects the tesbihat on Zikirlerim; progress stays.
  TesbihatState selecting(bool value) => _copy(selected: value);

  TesbihatState _copy({
    int? step,
    DhikrCount? count,
    bool? finished,
    int? completions,
    bool? selected,
  }) => TesbihatState(
    step: step ?? this.step,
    count: count ?? this.count,
    finished: finished ?? this.finished,
    completions: completions ?? this.completions,
    selected: selected ?? this.selected,
  );

  @override
  bool operator ==(Object other) =>
      other is TesbihatState &&
      other.step == step &&
      other.count == count &&
      other.finished == finished &&
      other.completions == completions &&
      other.selected == selected;

  @override
  int get hashCode => Object.hash(step, count, finished, completions, selected);

  @override
  String toString() =>
      'TesbihatState(step: $step, count: ${count.value}, finished: $finished, '
      'completions: $completions, selected: $selected)';
}

/// The result of [TesbihatState.tap].
final class TesbihatTap {
  const TesbihatTap(this.state, {required this.vibrate});

  final TesbihatState state;

  /// True when this tap finished a step or the tesbihat (AC-3, AC-4).
  final bool vibrate;
}
