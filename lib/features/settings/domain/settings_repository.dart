import '../../../core/result.dart';
import 'app_settings.dart';

/// Persists the user's preferences (spec 0004, AC-5).
abstract interface class SettingsRepository {
  /// The stored settings; [AppSettings.defaults] when nothing has been stored yet.
  Future<Result<AppSettings>> load();

  /// Stores [settings], replacing the previous ones.
  Future<Result<void>> save(AppSettings settings);
}
