import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hand_layout.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/app_settings.dart';
import 'settings_controller.dart';

/// Ayarlar (spec 0004): vibration, keep screen on, display options (spec
/// 0011), theme and notifications (spec 0017).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Spec 0017, Req. 8 (plan R4): a permission taken back while away shows
    // as off when the screen opens and when the app comes back to it.
    _checkPermission();
    _lifecycle = AppLifecycleListener(onShow: _checkPermission);
  }

  void _checkPermission() => ref
      .read(settingsControllerProvider.notifier)
      .checkNotificationPermission();

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Spec 0017, Req. 8: a refused permission keeps it off and says why.
  Future<void> _setContinueNotification(bool on) async {
    final messenger = ScaffoldMessenger.of(context);
    final denied = AppLocalizations.of(context).notificationPermissionDenied;
    final ok = await ref
        .read(settingsControllerProvider.notifier)
        .setContinueNotification(on);
    if (ok || !mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('notification-permission-denied'),
          content: Text(denied),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
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
        // Spec 0010.
        SwitchListTile(
          key: const Key('settings-keep-screen-on'),
          title: Text(l10n.settingsKeepScreenOn),
          subtitle: Text(l10n.settingsKeepScreenOnSubtitle),
          value: settings.keepScreenOn,
          onChanged: controller.setKeepScreenOn,
        ),
        // Spec 0011, Req. 1.
        SwitchListTile(
          key: const Key('settings-large-count'),
          title: Text(l10n.settingsLargeCount),
          subtitle: Text(l10n.settingsLargeCountSubtitle),
          value: settings.largeCount,
          onChanged: controller.setLargeCount,
        ),
        _Header(l10n.settingsHandLayout),
        RadioGroup<HandLayout>(
          groupValue: settings.handLayout,
          onChanged: (hand) {
            if (hand != null) controller.setHandLayout(hand);
          },
          child: Column(
            children: [
              for (final hand in HandLayout.values)
                RadioListTile<HandLayout>(
                  key: Key('hand-${hand.name}'),
                  value: hand,
                  title: Text(_handLabel(l10n, hand)),
                ),
            ],
          ),
        ),
        const Divider(),
        _Header(l10n.settingsTheme),
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
        // Spec 0017, Req. 7: after the theme, so the order above stays.
        const Divider(),
        _Header(l10n.settingsNotifications),
        SwitchListTile(
          key: const Key('settings-continue-notification'),
          title: Text(l10n.settingsContinueNotification),
          subtitle: Text(l10n.settingsContinueNotificationSubtitle),
          value: settings.continueNotification,
          onChanged: _setContinueNotification,
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

  static String _handLabel(AppLocalizations l10n, HandLayout hand) =>
      switch (hand) {
        HandLayout.center => l10n.handCenter,
        HandLayout.right => l10n.handRight,
        HandLayout.left => l10n.handLeft,
      };
}

/// A group's heading above its choices (theme, hand layout).
class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}
