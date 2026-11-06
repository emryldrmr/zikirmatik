import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../domain/dhikr_list.dart';
import '../domain/dhikr_name.dart';
import '../domain/target.dart';
import 'counter_controller.dart';
import 'counter_providers.dart';
import 'tesbihat_controller.dart';

/// The user's dhikrs and the selection (spec 0003): loading, error, or the
/// current [DhikrList].
final dhikrListControllerProvider =
    AsyncNotifierProvider<DhikrListController, DhikrList>(
      DhikrListController.new,
    );

class DhikrListController extends AsyncNotifier<DhikrList> {
  @override
  Future<DhikrList> build() async {
    final result = await ref.read(dhikrListRepositoryProvider).load();
    final list = switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
    // The selected dhikr's counter loads with the list, so the screen goes from
    // "loading" straight to the device (or the counter's own error) without a
    // second loading flash.
    final selected = list.selectedId;
    if (selected != null) {
      try {
        await ref.read(counterControllerProvider(selected).future);
      } on Object catch (_) {
        // The counter shows its own error state (spec 0001 AC-5).
      }
    }
    return list;
  }

  DhikrList? get _current => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };

  // Behaviour on a failed storage write is out of scope (specs 0001–0003):
  // a failed add leaves the list as it was; select, rename and delete update
  // the screen first. Deferred as backlog B-2.

  /// AC-3, AC-7: true when the dhikr was stored; it is then selected.
  Future<bool> add(DhikrName name, Target? target) async {
    final current = _current;
    if (current == null) return false;
    final result = await ref
        .read(dhikrListRepositoryProvider)
        .add(name, target);
    if (result case Ok(:final value)) {
      state = AsyncData((_current ?? current).added(value));
      return true;
    }
    return false;
  }

  /// Spec 0007, AC-4: adds a dhikr without a target at the end, keeping the
  /// selection. Returns its id, or null when it was not stored.
  Future<int?> append(DhikrName name) async {
    final current = _current;
    if (current == null) return null;
    final result = await ref
        .read(dhikrListRepositoryProvider)
        .add(name, null, select: false);
    if (result case Ok(:final value)) {
      state = AsyncData((_current ?? current).appended(value));
      return value.id;
    }
    return null;
  }

  /// Spec 0007, AC-5: opens a dhikr from another section — selects it and
  /// leaves the tesbihat (its progress is kept, spec 0006 Req 8).
  Future<void> show(int id) async {
    await select(id);
    await ref.read(tesbihatControllerProvider.notifier).select(false);
  }

  /// AC-4.
  Future<void> select(int id) async {
    final current = _current;
    if (current == null) return;
    final next = current.selecting(id);
    if (next == current) return;
    state = AsyncData(next);
    await ref.read(dhikrListRepositoryProvider).select(next.selectedId);
  }

  /// AC-5.
  Future<void> rename(int id, DhikrName name) async {
    final current = _current;
    if (current == null) return;
    state = AsyncData(current.renamed(id, name));
    await ref.read(dhikrListRepositoryProvider).rename(id, name);
  }

  /// AC-6, AC-7 (the confirmation of BR-6 is asked by the screen).
  Future<void> delete(int id) async {
    final current = _current;
    if (current == null) return;
    final next = current.deleted(id);
    state = AsyncData(next);
    final repo = ref.read(dhikrListRepositoryProvider);
    await repo.delete(id);
    await repo.select(next.selectedId);
  }
}
