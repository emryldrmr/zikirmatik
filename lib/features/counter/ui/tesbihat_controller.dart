import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics.dart';
import '../../../core/result.dart';
import '../domain/tesbihat.dart';
import '../domain/tesbihat_repository.dart';
import '../domain/tesbihat_state.dart';
import 'counter_providers.dart';

/// The tesbihat's progress and selection (spec 0006): loading, error, or the
/// current [TesbihatState]. Kept alive for the app's lifetime.
final tesbihatControllerProvider =
    AsyncNotifierProvider<TesbihatController, TesbihatState>(
      TesbihatController.new,
    );

class TesbihatController extends AsyncNotifier<TesbihatState> {
  late TesbihatRepository _repo;

  @override
  Future<TesbihatState> build() async {
    _repo = ref.read(tesbihatRepositoryProvider);
    return switch (await _repo.load()) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  TesbihatState? get _current => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };

  /// AC-3, AC-4: one tap. Like a dhikr's tap, the state and its save are
  /// issued synchronously in tap order and the vibration is never awaited
  /// before the save (docs/conventions.md, Known traps). A tap on a finished
  /// tesbihat changes nothing and never vibrates (spec 0009, AC-3).
  Future<void> tap() async {
    final current = _current;
    if (current == null) return;
    final out = current.tap(namazSonrasiTesbihat);
    if (out.state == current) return;
    state = AsyncData(out.state);
    final saved = _repo.save(out.state);
    unawaited(vibrateAfterTap(ref, roundCompleted: out.vibrate));
    await saved;
  }

  /// AC-5.
  Future<void> undo() => _apply((s) => s.undo());

  /// AC-4 "Baştan başla" and AC-6 "Sıfırla" (its confirmation is asked by the
  /// screen).
  Future<void> restart() => _apply((s) => s.restart());

  /// Shows the tesbihat (true) or the selected dhikr (false) on Zikirlerim.
  Future<void> select(bool value) => _apply((s) => s.selecting(value));

  // Behaviour on a failed save is out of scope (specs 0001–0006, B-2).
  Future<void> _apply(TesbihatState Function(TesbihatState) rule) async {
    final current = _current;
    if (current == null) return;
    final next = rule(current);
    if (next == current) return;
    state = AsyncData(next);
    await _repo.save(next);
  }
}
