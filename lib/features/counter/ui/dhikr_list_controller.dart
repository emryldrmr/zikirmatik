import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../../core/storage_notice.dart';
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

  // Spec 0015, Req 3: a failed write puts the screen back as it was before
  // that change — only that change, applied to the list as it is now, so
  // changes made in between are kept (G2) — and says it was not saved.

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
    _notSaved();
    return false;
  }

  /// Spec 0007, AC-4: adds a dhikr at the end, keeping the selection; with
  /// [target] when given (spec 0008, AC-4), otherwise without one. Returns its
  /// id, or null when it was not stored.
  Future<int?> append(DhikrName name, {Target? target}) async {
    final current = _current;
    if (current == null) return null;
    final result = await ref
        .read(dhikrListRepositoryProvider)
        .add(name, target, select: false);
    if (result case Ok(:final value)) {
      state = AsyncData((_current ?? current).appended(value));
      return value.id;
    }
    _notSaved();
    return null;
  }

  /// Spec 0007, AC-5: opens a dhikr from another section — selects it and
  /// leaves the tesbihat (its progress is kept, spec 0006 Req 8). When the
  /// selection is not stored the tesbihat stays (plan 0015, R2).
  Future<void> show(int id) async {
    if (!await select(id)) return;
    await ref.read(tesbihatControllerProvider.notifier).select(false);
  }

  /// AC-4. False when the selection was not stored; it is then undone.
  Future<bool> select(int id) async {
    final current = _current;
    if (current == null) return true;
    final next = current.selecting(id);
    if (next == current) return true;
    state = AsyncData(next);
    final result = await ref
        .read(dhikrListRepositoryProvider)
        .select(next.selectedId);
    if (result is Ok) return true;
    _notSaved();
    // Undone only while this selection is still the one shown.
    final latest = _current;
    final previous = current.selectedId;
    if (latest != null && latest.selectedId == id && previous != null) {
      state = AsyncData(latest.selecting(previous));
    }
    return false;
  }

  /// AC-5.
  Future<void> rename(int id, DhikrName name) async {
    final current = _current;
    if (current == null) return;
    final old = current.entries.where((e) => e.id == id).firstOrNull;
    state = AsyncData(current.renamed(id, name));
    final result = await ref.read(dhikrListRepositoryProvider).rename(id, name);
    if (result is Ok || old == null) return;
    _notSaved();
    // Undone only while the dhikr still has this name.
    final latest = _current;
    if (latest == null) return;
    final now = latest.entries.where((e) => e.id == id).firstOrNull;
    if (now?.name == name) state = AsyncData(latest.renamed(id, old.name));
  }

  /// AC-6, AC-7 (the confirmation of BR-6 is asked by the screen). A delete
  /// that is not stored brings the dhikr back to its place, and the selection
  /// too when it was selected and nothing else was chosen since (G3). When the
  /// delete is stored but the new selection is not, nothing is said: the
  /// stored selection points nowhere, which opens on the first dhikr — what
  /// the screen shows (plan 0015, R3).
  Future<void> delete(int id) async {
    final current = _current;
    if (current == null) return;
    final index = current.entries.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final entry = current.entries[index];
    final next = current.deleted(id);
    state = AsyncData(next);
    final repo = ref.read(dhikrListRepositoryProvider);
    if (await repo.delete(id) case Err()) {
      _notSaved();
      final latest = _current;
      if (latest == null) return;
      final reselect =
          current.selectedId == id && latest.selectedId == next.selectedId;
      state = AsyncData(latest.restored(entry, index, select: reselect));
      return;
    }
    await repo.select(next.selectedId);
  }

  void _notSaved() =>
      ref.read(storageNoticeProvider.notifier).report(StorageNotice.notSaved);
}
