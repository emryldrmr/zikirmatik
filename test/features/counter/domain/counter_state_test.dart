import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/domain/counter_state.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';
import 'package:zikirmatik/features/counter/domain/target.dart';

CounterState _state({
  int count = 0,
  int rounds = 0,
  int total = 0,
  int? target,
}) => CounterState(
  count: DhikrCount(count),
  rounds: rounds,
  total: total,
  target: target == null ? null : Target.of(target),
);

void main() {
  test('initial is all zero without a target', () {
    expect(CounterState.initial, _state());
  });

  test('tap adds one to count and total', () {
    final out = _state(count: 2, total: 10).tap();
    expect(out.state, _state(count: 3, total: 11));
    expect(out.roundCompleted, isFalse);
  });

  test('tap at target completes a round', () {
    final out = _state(count: 32, rounds: 1, total: 65, target: 33).tap();
    expect(out.state, _state(count: 0, rounds: 2, total: 66, target: 33));
    expect(out.roundCompleted, isTrue);
  });

  test('tap below target does not complete a round', () {
    final out = _state(count: 31, target: 33).tap();
    expect(out.state.count.value, 32);
    expect(out.roundCompleted, isFalse);
  });

  test('without a target the count passes 33 with no round', () {
    final out = _state(count: 32, total: 32).tap();
    expect(out.state, _state(count: 33, total: 33));
    expect(out.roundCompleted, isFalse);
  });

  test('target 1 completes a round on every tap', () {
    final out = _state(target: 1).tap();
    expect(out.state, _state(rounds: 1, total: 1, target: 1));
    expect(out.roundCompleted, isTrue);
  });

  test('undo takes one from count and total', () {
    expect(_state(count: 3, total: 40).undo(), _state(count: 2, total: 39));
  });

  test('undo at zero changes nothing, also right after a round', () {
    final afterRound = _state(rounds: 2, total: 66, target: 33);
    expect(afterRound.undo(), afterRound);
    expect(_state().undo(), _state());
  });

  test('reset clears count and rounds, keeps total and target', () {
    expect(
      _state(count: 5, rounds: 3, total: 104, target: 33).reset(),
      _state(total: 104, target: 33),
    );
  });

  test('changeTarget clears count and rounds, keeps total', () {
    expect(
      _state(
        count: 5,
        rounds: 3,
        total: 104,
        target: 33,
      ).changeTarget(Target.of(99)),
      _state(total: 104, target: 99),
    );
    expect(
      _state(count: 5, total: 5, target: 33).changeTarget(null),
      _state(total: 5),
    );
  });

  test('hasProgress is true when count or rounds are above zero', () {
    expect(_state().hasProgress, isFalse);
    expect(_state(total: 9).hasProgress, isFalse);
    expect(_state(count: 1).hasProgress, isTrue);
    expect(_state(rounds: 1).hasProgress, isTrue);
  });
}
