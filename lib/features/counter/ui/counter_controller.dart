import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../domain/dhikr_count.dart';
import 'counter_providers.dart';

/// Holds the counter's state: loading, error, or the current [DhikrCount].
///
/// Kept alive for the app's lifetime, so switching sections does not reset it.
final counterControllerProvider =
    AsyncNotifierProvider<CounterController, DhikrCount>(CounterController.new);

class CounterController extends AsyncNotifier<DhikrCount> {
  @override
  Future<DhikrCount> build() async {
    final result = await ref.read(counterRepositoryProvider).load();
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// BR-3: adds one and stores it right away (BR-8).
  ///
  /// Ignored while loading or after a load error (spec 0001, AC-4/AC-5).
  /// The state is updated synchronously, so rapid taps are all counted.
  Future<void> increment() async {
    final current = state;
    if (current is! AsyncData<DhikrCount>) return;
    final next = current.value.increment();
    state = AsyncData(next);
    // Behaviour on a failed save is out of scope for spec 0001.
    await ref.read(counterRepositoryProvider).save(next);
  }
}
