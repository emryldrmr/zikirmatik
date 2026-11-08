import '../../../core/result.dart';
import 'daily_history.dart';

/// Persists the daily counts (spec 0014, Req. 7; BR-8).
abstract interface class HistoryRepository {
  /// Every stored day; [DailyHistory.empty] when nothing is stored yet.
  Future<Result<DailyHistory>> load();

  /// One more counting tap on [day] (Req. 1).
  Future<Result<void>> add(Day day);

  /// One tap taken back on [day]; a day at 0 stays at 0 (Req. 2).
  Future<Result<void>> remove(Day day);
}
