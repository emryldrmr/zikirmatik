import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/settings.dart';
import '../l10n/app_localizations.dart';
import 'shell.dart';

/// Root widget. Turkish only (docs/conventions.md, Language). Light and dark
/// themes share the teal seed; the user's choice picks one (spec 0004, AC-3).
class ZikirmatikApp extends ConsumerWidget {
  const ZikirmatikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: _mode(settings?.theme ?? ThemeChoice.system),
      home: _Gate(ready: settings != null),
    );
  }

  static ThemeMode _mode(ThemeChoice choice) => switch (choice) {
    ThemeChoice.light => ThemeMode.light,
    ThemeChoice.dark => ThemeMode.dark,
    ThemeChoice.system => ThemeMode.system,
  };
}

/// The content is shown only once the settings are loaded, so it opens in the
/// saved theme (spec 0004, G1). It is built from the start, hidden, so its own
/// loading runs alongside the settings' and nothing waits an extra frame.
class _Gate extends StatelessWidget {
  const _Gate({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Offstage(offstage: !ready, child: const Shell()),
      if (!ready) const _Loading(),
    ],
  );
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: CircularProgressIndicator(
        key: const Key('app-loading'),
        semanticsLabel: AppLocalizations.of(context).appLoading,
      ),
    ),
  );
}
