import '../l10n/app_localizations.dart';

/// The sections of the side menu, in menu order (spec 0001, AC-6).
enum AppSection {
  myDhikrs,
  suggested,
  asma,
  quran,
  settings;

  String label(AppLocalizations l10n) => switch (this) {
    AppSection.myDhikrs => l10n.sectionMyDhikrs,
    AppSection.suggested => l10n.sectionSuggested,
    AppSection.asma => l10n.sectionAsma,
    AppSection.quran => l10n.sectionQuran,
    AppSection.settings => l10n.sectionSettings,
  };
}
