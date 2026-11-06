import '../../../core/result.dart';
import 'tesbihat_state.dart';

/// Persists the tesbihat's progress and whether it is selected (spec 0006,
/// AC-7; BR-8). Nothing stored yet loads as [TesbihatState.initial].
abstract interface class TesbihatRepository {
  Future<Result<TesbihatState>> load();

  Future<Result<void>> save(TesbihatState state);
}
