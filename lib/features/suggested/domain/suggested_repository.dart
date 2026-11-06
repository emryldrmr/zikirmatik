import '../../../core/result.dart';
import 'suggested_dhikr.dart';

/// The embedded suggested dhikrs (spec 0008).
abstract interface class SuggestedRepository {
  /// All 7 dhikrs in order, or a failure — never a partial list.
  Future<Result<List<SuggestedDhikr>>> load();
}
