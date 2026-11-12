import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hand_layout.dart';
import '../../../core/result.dart';
import '../../../core/storage_notice.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Has no default: the composition root overrides it with the drift
/// repository, tests with a fake.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError(
    'settingsRepositoryProvider must be overridden in the composition root.',
  ),
);

/// The user's settings (spec 0004). Never ends in an error: unreadable
/// settings fall back to [AppSettings.defaults] without telling the user
/// (AC-6, G2).
final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async =>
      switch (await ref.read(settingsRepositoryProvider).load()) {
        Ok(:final value) => value,
        Err() => AppSettings.defaults,
      };

  /// AC-2.
  Future<void> setVibration(bool on) =>
      _update((s) => s.copyWith(vibration: on));

  /// Spec 0009, AC-2.
  Future<void> setTapVibration(bool on) =>
      _update((s) => s.copyWith(tapVibration: on));

  /// Spec 0010, AC-8/AC-9.
  Future<void> setKeepScreenOn(bool on) =>
      _update((s) => s.copyWith(keepScreenOn: on));

  /// Spec 0011, AC-1/AC-9.
  Future<void> setLargeCount(bool on) =>
      _update((s) => s.copyWith(largeCount: on));

  /// Spec 0011, AC-1/AC-9.
  Future<void> setHandLayout(HandLayout hand) =>
      _update((s) => s.copyWith(handLayout: hand));

  /// AC-3.
  Future<void> setTheme(ThemeChoice theme) =>
      _update((s) => s.copyWith(theme: theme));

  /// Applies at once, then stores. A failed write keeps the setting applied
  /// and says it may be lost (spec 0015, Req 2).
  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = change(current);
    state = AsyncData(next);
    if (await ref.read(settingsRepositoryProvider).save(next) case Err()) {
      ref.read(storageNoticeProvider.notifier).report(StorageNotice.mayBeLost);
    }
  }
}
