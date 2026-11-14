import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/resume_point.dart';
import '../domain/tesbihat.dart';
import 'counter_controller.dart';
import 'dhikr_list_controller.dart';
import 'tesbihat_controller.dart';

/// The counter that got the latest counting tap since the app started (spec
/// 0017, Req. 1): in memory only, never stored, so a new start has none.
/// Null when nothing was counted, or when that counter was reset, restarted
/// or deleted after its last tap (G1).
final lastCountedProvider = NotifierProvider<LastCounted, CountedItem?>(
  LastCounted.new,
);

class LastCounted extends Notifier<CountedItem?> {
  @override
  CountedItem? build() => null;

  /// A counting tap on [item] (BR-3); undo is not one (Req. 1).
  void counted(CountedItem item) => state = item;

  /// [item] was reset, restarted or deleted: forgotten if it is the latest
  /// counted one, until its next counting tap (G1).
  void cleared(CountedItem item) {
    if (state == item) state = null;
  }
}

/// Where the user left off (spec 0017, Req. 2): the latest counted counter
/// with its values as they are now; null when there is none, when its dhikr
/// is gone (G1) or when the tesbihat is finished (G2).
final resumePointProvider = Provider<ResumePoint?>((ref) {
  switch (ref.watch(lastCountedProvider)) {
    case null:
      return null;
    case CountedDhikr(:final id):
      final list = ref.watch(dhikrListControllerProvider).valueOrNull;
      final entry = list?.entries.where((e) => e.id == id).firstOrNull;
      // Checked first: a deleted dhikr's counter is never loaded again.
      if (entry == null) return null;
      final counter = ref.watch(counterControllerProvider(id)).valueOrNull;
      if (counter == null) return null;
      return DhikrResume(
        id: id,
        name: entry.name.value,
        count: counter.count.value,
        target: counter.target?.value,
      );
    case CountedTesbihat():
      final state = ref.watch(tesbihatControllerProvider).valueOrNull;
      if (state == null || state.finished) return null;
      return TesbihatResume(
        stepNumber: state.step + 1,
        count: state.count.value,
        target: namazSonrasiTesbihat.steps[state.step].target.value,
      );
  }
});

/// Opens [item] on Zikirlerim (spec 0017, Req. 5): the dhikr selected, or the
/// tesbihat. Waits for the list and the tesbihat to load first, so it also
/// works right after a cold start.
Future<void> openCounted(WidgetRef ref, CountedItem item) async {
  try {
    await ref.read(dhikrListControllerProvider.future);
    await ref.read(tesbihatControllerProvider.future);
  } on Object catch (_) {
    // A part that cannot be read shows its own error state.
  }
  switch (item) {
    case CountedDhikr(:final id):
      await ref.read(dhikrListControllerProvider.notifier).show(id);
    case CountedTesbihat():
      await ref.read(tesbihatControllerProvider.notifier).select(true);
  }
}
