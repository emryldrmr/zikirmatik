import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics.dart';
import '../../../core/result.dart';
import '../domain/counter_repository.dart';
import '../domain/counter_state.dart';
import '../domain/target.dart';
import 'counter_providers.dart';

/// Holds one dhikr's counter state (by dhikr id): loading, error, or the
/// current [CounterState].
///
/// Kept alive for the app's lifetime, so switching sections or dhikrs does not
/// reset it.
final counterControllerProvider =
    AsyncNotifierProvider.family<CounterController, CounterState, int>(
      CounterController.new,
    );

class CounterController extends FamilyAsyncNotifier<CounterState, int> {
  late CounterRepository _repo;

  @override
  Future<CounterState> build(int dhikrId) async {
    _repo = ref.read(counterRepositoryForProvider)(dhikrId);
    final result = await _repo.load();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// The loaded state, or null while loading or after a load error — then
  /// every action is ignored (spec 0001 AC-4/AC-5, spec 0002 AC-9).
  CounterState? get _current => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };

  /// BR-3, BR-4: one tap; vibrates once when it completes a round, or briefly
  /// when vibration per count is on (spec 0009, [vibrateAfterTap]).
  ///
  /// The state is updated and its save is issued synchronously, in tap order,
  /// so rapid taps are all counted and stored in order (BR-8). The vibration
  /// is never awaited before the save (docs/conventions.md, Known traps); a
  /// failed vibration never affects counting.
  Future<void> tap() async {
    final current = _current;
    if (current == null) return;
    final outcome = current.tap();
    state = AsyncData(outcome.state);
    final saved = _save(outcome.state);
    unawaited(vibrateAfterTap(ref, roundCompleted: outcome.roundCompleted));
    await saved;
  }

  /// BR-5.
  Future<void> undo() => _apply((s) => s.undo());

  /// BR-7 (the confirmation of BR-6 is asked by the screen).
  Future<void> reset() => _apply((s) => s.reset());

  /// Spec 0002 G4 (the confirmation is asked by the screen).
  Future<void> changeTarget(Target? target) =>
      _apply((s) => s.changeTarget(target));

  Future<void> _apply(CounterState Function(CounterState) rule) async {
    final current = _current;
    if (current == null) return;
    final next = rule(current);
    if (next == current) return;
    state = AsyncData(next);
    await _save(next);
  }

  // Behaviour on a failed save is out of scope (specs 0001, 0002).
  Future<void> _save(CounterState next) => _repo.save(next);
}
