import '../../../core/result.dart';
import 'dhikr_count.dart';

/// Persists the single counter of the walking skeleton (BR-8).
abstract interface class CounterRepository {
  /// The stored count; [DhikrCount.zero] when nothing has been stored yet.
  Future<Result<DhikrCount>> load();

  /// Stores [count], replacing the previous value.
  Future<Result<void>> save(DhikrCount count);
}
