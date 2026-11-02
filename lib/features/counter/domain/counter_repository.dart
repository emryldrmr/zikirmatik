import '../../../core/result.dart';
import 'counter_state.dart';

/// Persists the counter (BR-8).
abstract interface class CounterRepository {
  /// The stored state; [CounterState.initial] when nothing has been stored yet.
  Future<Result<CounterState>> load();

  /// Stores [state], replacing the previous one.
  Future<Result<void>> save(CounterState state);
}
