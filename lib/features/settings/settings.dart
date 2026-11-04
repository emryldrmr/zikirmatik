/// Public interface of the settings feature (docs/architecture.md, FD-2).
/// Other features and the composition root import only this file.
library;

export 'data/drift_settings_repository.dart' show DriftSettingsRepository;
export 'domain/app_settings.dart' show AppSettings, ThemeChoice;
export 'domain/settings_repository.dart' show SettingsRepository;
export 'ui/settings_controller.dart'
    show
        SettingsController,
        settingsControllerProvider,
        settingsRepositoryProvider;
export 'ui/settings_screen.dart' show SettingsScreen;
