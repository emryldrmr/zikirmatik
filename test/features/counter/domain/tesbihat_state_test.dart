import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat_state.dart';

// Spec 0006 — Namaz sonrası tesbihat: the rules, without a screen.

final _t = namazSonrasiTesbihat;

TesbihatState _s({
  int step = 0,
  int count = 0,
  bool finished = false,
  int completions = 0,
  bool selected = false,
}) => TesbihatState(
  step: step,
  count: DhikrCount(count),
  finished: finished,
  completions: completions,
  selected: selected,
);

/// Taps [n] times; returns the last outcome.
TesbihatTap _taps(TesbihatState from, int n) {
  var out = TesbihatTap(from, vibrate: false);
  for (var i = 0; i < n; i++) {
    out = out.state.tap(_t);
  }
  return out;
}

void main() {
  test('initial is the first step at zero, not finished, not selected', () {
    expect(TesbihatState.initial, _s());
  });

  test('32 taps stay on the step, the 33rd moves on and signals vibration', () {
    final after32 = _taps(TesbihatState.initial, 32);
    expect(after32.state, _s(count: 32));
    expect(after32.vibrate, isFalse);

    final after33 = after32.state.tap(_t);
    expect(after33.state, _s(step: 1));
    expect(after33.vibrate, isTrue);

    final second = _taps(after33.state, 33);
    expect(second.state, _s(step: 2));
    expect(second.vibrate, isTrue);
  });

  test('the last step completes and counts the completion', () {
    final out = _s(step: 2, count: 32, completions: 4).tap(_t);
    expect(out.state, _s(step: 2, finished: true, completions: 5));
    expect(out.vibrate, isTrue);
  });

  test('a whole tesbihat is 99 taps and vibrates three times', () {
    var state = TesbihatState.initial;
    var vibrations = 0;
    for (var i = 0; i < 99; i++) {
      final out = state.tap(_t);
      if (out.vibrate) vibrations++;
      state = out.state;
    }
    expect(state, _s(step: 2, finished: true, completions: 1));
    expect(vibrations, 3);
  });

  test('taps after completion change nothing', () {
    final done = _s(step: 2, finished: true, completions: 1);
    final out = done.tap(_t);
    expect(out.state, done);
    expect(out.vibrate, isFalse);
  });

  test('undo stays within the step', () {
    expect(_s(step: 1, count: 5).undo(), _s(step: 1, count: 4));
    expect(_s(step: 1).undo(), _s(step: 1)); // no return to step 1
    expect(_s().undo(), _s());
    final done = _s(step: 2, finished: true, completions: 3);
    expect(done.undo(), done); // completion is not taken back
  });

  test(
    'restart goes to the first step and keeps completions and selection',
    () {
      expect(
        _s(step: 2, count: 10, completions: 2, selected: true).restart(),
        _s(completions: 2, selected: true),
      );
      expect(
        _s(step: 2, finished: true, completions: 2).restart(),
        _s(completions: 2),
      );
    },
  );

  test('selecting keeps the progress', () {
    final s = _s(step: 1, count: 7, completions: 1);
    expect(
      s.selecting(true),
      _s(step: 1, count: 7, completions: 1, selected: true),
    );
    expect(s.selecting(true).selecting(false), s);
  });

  test('fits rejects a step or count outside the sequence', () {
    expect(_s(step: 2, count: 32).fits(_t), isTrue);
    expect(_s(step: 2, finished: true).fits(_t), isTrue);
    expect(_s(step: 3).fits(_t), isFalse);
    expect(_s(count: 33).fits(_t), isFalse);
    expect(_s(step: 1, finished: true).fits(_t), isFalse);
    expect(_s(step: 2, count: 1, finished: true).fits(_t), isFalse);
  });
}
