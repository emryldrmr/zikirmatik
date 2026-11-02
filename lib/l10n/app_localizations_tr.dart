// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Zikirmatik';

  @override
  String get sectionMyDhikrs => 'Zikirlerim';

  @override
  String get sectionSuggested => 'Önerilen Zikirler';

  @override
  String get sectionAsma => 'Esmaü\'l-Hüsna';

  @override
  String get sectionQuran => 'Kur\'an + Meal';

  @override
  String get sectionSettings => 'Ayarlar';

  @override
  String get comingSoon => 'Bu bölüm yakında.';

  @override
  String get openMenu => 'Menüyü aç';

  @override
  String get counterLoadFailed => 'Sayaç yüklenemedi.';

  @override
  String get counterLoading => 'Sayaç yükleniyor';

  @override
  String counterSemantics(int count) {
    return 'Sayım $count. Saymak için dokunun.';
  }
}
