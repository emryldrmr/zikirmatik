import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/app_settings.dart';
import 'settings_controller.dart';

/// Ayarlar (spec 0004): vibration and theme.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The app shows its content only once the settings are loaded (app.dart),
    // so a value is always there; the defaults are a safe fallback.
    final settings =
        ref.watch(settingsControllerProvider).valueOrNull ??
        AppSettings.defaults;
    final controller = ref.read(settingsControllerProvider.notifier);

    return ListView(
      key: const Key('settings-screen'),
      children: [
        SwitchListTile(
          key: const Key('settings-vibration'),
          title: Text(l10n.settingsVibration),
          subtitle: Text(l10n.settingsVibrationSubtitle),
          value: settings.vibration,
          onChanged: controller.setVibration,
        ),
        // Spec 0009.
        SwitchListTile(
          key: const Key('settings-tap-vibration'),
          title: Text(l10n.settingsTapVibration),
          subtitle: Text(l10n.settingsTapVibrationSubtitle),
          value: settings.tapVibration,
          onChanged: controller.setTapVibration,
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Semantics(
            header: true,
            child: Text(
              l10n.settingsTheme,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        RadioGroup<ThemeChoice>(
          groupValue: settings.theme,
          onChanged: (choice) {
            if (choice != null) controller.setTheme(choice);
          },
          child: Column(
            children: [
              for (final choice in ThemeChoice.values)
                RadioListTile<ThemeChoice>(
                  key: Key('theme-${choice.name}'),
                  value: choice,
                  title: Text(_label(l10n, choice)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _label(AppLocalizations l10n, ThemeChoice choice) =>
      switch (choice) {
        ThemeChoice.light => l10n.themeLight,
        ThemeChoice.dark => l10n.themeDark,
        ThemeChoice.system => l10n.themeSystem,
      };
}
