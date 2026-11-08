import '../l10n/app_localizations.dart';

/// The sections of the side menu, in menu order (spec 0001, AC-6).
enum AppSection {
  myDhikrs,
  history, // spec 0014, AC-6
  suggested,
  asma,
  quran,
  settings;

  String label(AppLocalizations l10n) => switch (this) {
    AppSection.myDhikrs => l10n.sectionMyDhikrs,
    AppSection.history => l10n.sectionHistory,
    AppSection.suggested => l10n.sectionSuggested,
    AppSection.asma => l10n.sectionAsma,
    AppSection.quran => l10n.sectionQuran,
    AppSection.settings => l10n.sectionSettings,
  };
}
