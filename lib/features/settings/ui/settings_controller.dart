import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
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

  /// AC-3.
  Future<void> setTheme(ThemeChoice theme) =>
      _update((s) => s.copyWith(theme: theme));

  /// Applies at once, then stores. A failed write is not reported: write
  /// failures are out of scope (spec 0004, G3; backlog B-2).
  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = change(current);
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}
