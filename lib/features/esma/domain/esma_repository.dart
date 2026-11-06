import '../../../core/result.dart';
import 'asma_name.dart';

/// The embedded Esmaü'l-Hüsna content (spec 0007).
abstract interface class EsmaRepository {
  /// All 99 names in order, or a failure — never a partial list.
  Future<Result<List<AsmaName>>> load();
}
