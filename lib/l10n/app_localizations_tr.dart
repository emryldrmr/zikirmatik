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

  @override
  String get targetNone => 'Hedef yok';

  @override
  String targetAndRound(String target, String rounds) {
    return 'Hedef $target · Tur $rounds';
  }

  @override
  String get targetSemanticsNone => 'Hedef: yok';

  @override
  String targetSemantics(String target) {
    return 'Hedef: $target';
  }

  @override
  String totalLabel(String total) {
    return 'Toplam $total';
  }

  @override
  String get undo => 'Geri al';

  @override
  String get reset => 'Sıfırla';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get resetConfirmMessage => 'Sayaç sıfırlansın mı?';

  @override
  String get targetPickerTitle => 'Hedef';

  @override
  String get targetCustom => 'Özel…';

  @override
  String get customTargetTitle => 'Özel hedef';

  @override
  String get customTargetInvalid => '1 ile 100.000 arasında bir sayı girin.';

  @override
  String get save => 'Kaydet';

  @override
  String get targetChangeConfirmMessage =>
      'Hedef değişirse sayım ve tur sıfırlanır.';

  @override
  String get targetChangeConfirm => 'Değiştir';

  @override
  String dhikrPickerSemantics(String name) {
    return 'Zikir: $name. Değiştirmek için dokunun.';
  }

  @override
  String dhikrEditSemantics(String name) {
    return '$name zikrini düzenle';
  }

  @override
  String get dhikrPickerTitle => 'Zikir seç';

  @override
  String get newDhikr => 'Yeni zikir';

  @override
  String get editDhikr => 'Zikri düzenle';

  @override
  String get dhikrNameLabel => 'Ad';

  @override
  String get dhikrTargetLabel => 'Hedef (isteğe bağlı)';

  @override
  String get dhikrNameInvalid => 'Ad 1–50 karakter olmalı.';

  @override
  String get delete => 'Sil';

  @override
  String deleteDhikrConfirmMessage(String name) {
    return '“$name” silinsin mi? Sayımı ve toplamı da silinir.';
  }

  @override
  String get noDhikrs => 'Henüz zikir yok.';

  @override
  String get addDhikr => 'Zikir ekle';

  @override
  String get settingsVibration => 'Titreşim';

  @override
  String get settingsVibrationSubtitle => 'Tur tamamlanınca titreşir';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get appLoading => 'Yükleniyor';

  @override
  String get pressBackAgainToExit => 'Çıkmak için tekrar basın.';

  @override
  String get tesbihatName => 'Namaz sonrası tesbihat';

  @override
  String tesbihatStep(int step, int steps) {
    return 'Adım $step/$steps';
  }

  @override
  String tesbihatTarget(String target) {
    return 'Hedef $target';
  }

  @override
  String tesbihatCompletions(String completions) {
    return 'Tamamlanan $completions';
  }

  @override
  String get tesbihatFinished => 'Tesbihat tamamlandı';

  @override
  String get tesbihatRestart => 'Baştan başla';

  @override
  String get tesbihatOpen => 'Tesbihat çek';

  @override
  String get tesbihatResetConfirmMessage => 'Tesbihat baştan başlasın mı?';

  @override
  String tesbihatStepSemantics(
    String text,
    int step,
    int steps,
    int count,
    int target,
  ) {
    return '$text, adım $step/$steps, $count / $target';
  }

  @override
  String tesbihatStepAnnouncement(String text, int step, int steps) {
    return '$text, adım $step/$steps';
  }
}
