import '../../../core/result.dart';
import 'dhikr_list.dart';
import 'dhikr_name.dart';
import 'target.dart';

/// Persists the user's dhikrs and the selection (spec 0003, BR-8).
/// Each dhikr's counter state is stored by `CounterRepository` under the same id.
abstract interface class DhikrListRepository {
  Future<Result<DhikrList>> load();

  /// Creates a dhikr with a fresh counter (count, rounds and total 0) and the
  /// optional [target], and returns it. It is selected unless [select] is
  /// false (spec 0007: adding a name of the Esma keeps the selection).
  Future<Result<DhikrEntry>> add(
    DhikrName name,
    Target? target, {
    bool select = true,
  });

  Future<Result<void>> rename(int id, DhikrName name);

  /// Removes the dhikr together with its counter state.
  Future<Result<void>> delete(int id);

  /// Stores which dhikr is selected (null: none, the list is empty).
  Future<Result<void>> select(int? id);
}
