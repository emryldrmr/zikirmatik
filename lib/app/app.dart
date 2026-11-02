import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'shell.dart';

/// Root widget. Turkish only (docs/conventions.md, Language).
class ZikirmatikApp extends StatelessWidget {
  const ZikirmatikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const Shell(),
    );
  }
}
