import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Zikirmatik'**
  String get appTitle;

  /// No description provided for @sectionMyDhikrs.
  ///
  /// In tr, this message translates to:
  /// **'Zikirlerim'**
  String get sectionMyDhikrs;

  /// No description provided for @sectionSuggested.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen Zikirler'**
  String get sectionSuggested;

  /// No description provided for @sectionAsma.
  ///
  /// In tr, this message translates to:
  /// **'Esmaü\'l-Hüsna'**
  String get sectionAsma;

  /// No description provided for @sectionQuran.
  ///
  /// In tr, this message translates to:
  /// **'Kur\'an + Meal'**
  String get sectionQuran;

  /// No description provided for @sectionSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get sectionSettings;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm yakında.'**
  String get comingSoon;

  /// No description provided for @openMenu.
  ///
  /// In tr, this message translates to:
  /// **'Menüyü aç'**
  String get openMenu;

  /// No description provided for @counterLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sayaç yüklenemedi.'**
  String get counterLoadFailed;

  /// No description provided for @counterLoading.
  ///
  /// In tr, this message translates to:
  /// **'Sayaç yükleniyor'**
  String get counterLoading;

  /// No description provided for @counterSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Sayım {count}. Saymak için dokunun.'**
  String counterSemantics(int count);

  /// No description provided for @targetNone.
  ///
  /// In tr, this message translates to:
  /// **'Hedef yok'**
  String get targetNone;

  /// No description provided for @targetAndRound.
  ///
  /// In tr, this message translates to:
  /// **'Hedef {target} · Tur {rounds}'**
  String targetAndRound(String target, String rounds);

  /// No description provided for @targetSemanticsNone.
  ///
  /// In tr, this message translates to:
  /// **'Hedef: yok'**
  String get targetSemanticsNone;

  /// No description provided for @targetSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Hedef: {target}'**
  String targetSemantics(String target);

  /// No description provided for @totalLabel.
  ///
  /// In tr, this message translates to:
  /// **'Toplam {total}'**
  String totalLabel(String total);

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  /// No description provided for @reset.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get reset;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Sayaç sıfırlansın mı?'**
  String get resetConfirmMessage;

  /// No description provided for @targetPickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get targetPickerTitle;

  /// No description provided for @targetCustom.
  ///
  /// In tr, this message translates to:
  /// **'Özel…'**
  String get targetCustom;

  /// No description provided for @customTargetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özel hedef'**
  String get customTargetTitle;

  /// No description provided for @customTargetInvalid.
  ///
  /// In tr, this message translates to:
  /// **'1 ile 100.000 arasında bir sayı girin.'**
  String get customTargetInvalid;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @targetChangeConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hedef değişirse sayım ve tur sıfırlanır.'**
  String get targetChangeConfirmMessage;

  /// No description provided for @targetChangeConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Değiştir'**
  String get targetChangeConfirm;

  /// No description provided for @dhikrPickerSemantics.
  ///
  /// In tr, this message translates to:
  /// **'Zikir: {name}. Değiştirmek için dokunun.'**
  String dhikrPickerSemantics(String name);

  /// No description provided for @dhikrEditSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{name} zikrini düzenle'**
  String dhikrEditSemantics(String name);

  /// No description provided for @dhikrPickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Zikir seç'**
  String get dhikrPickerTitle;

  /// No description provided for @newDhikr.
  ///
  /// In tr, this message translates to:
  /// **'Yeni zikir'**
  String get newDhikr;

  /// No description provided for @editDhikr.
  ///
  /// In tr, this message translates to:
  /// **'Zikri düzenle'**
  String get editDhikr;

  /// No description provided for @dhikrNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get dhikrNameLabel;

  /// No description provided for @dhikrTargetLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef (isteğe bağlı)'**
  String get dhikrTargetLabel;

  /// No description provided for @dhikrNameInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Ad 1–50 karakter olmalı.'**
  String get dhikrNameInvalid;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @deleteDhikrConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'“{name}” silinsin mi? Sayımı ve toplamı da silinir.'**
  String deleteDhikrConfirmMessage(String name);

  /// No description provided for @noDhikrs.
  ///
  /// In tr, this message translates to:
  /// **'Henüz zikir yok.'**
  String get noDhikrs;

  /// No description provided for @addDhikr.
  ///
  /// In tr, this message translates to:
  /// **'Zikir ekle'**
  String get addDhikr;

  /// No description provided for @settingsVibration.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim'**
  String get settingsVibration;

  /// No description provided for @settingsVibrationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tur tamamlanınca titreşir'**
  String get settingsVibrationSubtitle;

  /// No description provided for @settingsTapVibration.
  ///
  /// In tr, this message translates to:
  /// **'Her sayımda titreşim'**
  String get settingsTapVibration;

  /// No description provided for @settingsTapVibrationSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Her dokunuşta kısa titreşir'**
  String get settingsTapVibrationSubtitle;

  /// No description provided for @settingsKeepScreenOn.
  ///
  /// In tr, this message translates to:
  /// **'Ekranı açık tut'**
  String get settingsKeepScreenOn;

  /// No description provided for @settingsKeepScreenOnSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Zikirlerim açıkken ekran kararmaz'**
  String get settingsKeepScreenOnSubtitle;

  /// No description provided for @settingsLargeCount.
  ///
  /// In tr, this message translates to:
  /// **'Büyük rakam'**
  String get settingsLargeCount;

  /// No description provided for @settingsLargeCountSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sayım daha büyük görünür'**
  String get settingsLargeCountSubtitle;

  /// No description provided for @settingsHandLayout.
  ///
  /// In tr, this message translates to:
  /// **'El yerleşimi'**
  String get settingsHandLayout;

  /// No description provided for @handCenter.
  ///
  /// In tr, this message translates to:
  /// **'Ortada'**
  String get handCenter;

  /// No description provided for @handRight.
  ///
  /// In tr, this message translates to:
  /// **'Sağ el'**
  String get handRight;

  /// No description provided for @handLeft.
  ///
  /// In tr, this message translates to:
  /// **'Sol el'**
  String get handLeft;

  /// No description provided for @fullScreen.
  ///
  /// In tr, this message translates to:
  /// **'Tam ekran'**
  String get fullScreen;

  /// No description provided for @fullScreenClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get fullScreenClose;

  /// No description provided for @appVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String appVersion(String version);

  /// No description provided for @settingsTheme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @appLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor'**
  String get appLoading;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In tr, this message translates to:
  /// **'Çıkmak için tekrar basın.'**
  String get pressBackAgainToExit;

  /// No description provided for @tesbihatName.
  ///
  /// In tr, this message translates to:
  /// **'Namaz sonrası tesbihat'**
  String get tesbihatName;

  /// No description provided for @tesbihatStep.
  ///
  /// In tr, this message translates to:
  /// **'Adım {step}/{steps}'**
  String tesbihatStep(int step, int steps);

  /// No description provided for @tesbihatTarget.
  ///
  /// In tr, this message translates to:
  /// **'Hedef {target}'**
  String tesbihatTarget(String target);

  /// No description provided for @tesbihatCompletions.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan {completions}'**
  String tesbihatCompletions(String completions);

  /// No description provided for @tesbihatFinished.
  ///
  /// In tr, this message translates to:
  /// **'Tesbihat tamamlandı'**
  String get tesbihatFinished;

  /// No description provided for @tesbihatRestart.
  ///
  /// In tr, this message translates to:
  /// **'Baştan başla'**
  String get tesbihatRestart;

  /// No description provided for @tesbihatOpen.
  ///
  /// In tr, this message translates to:
  /// **'Tesbihat çek'**
  String get tesbihatOpen;

  /// No description provided for @tesbihatResetConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Tesbihat baştan başlasın mı?'**
  String get tesbihatResetConfirmMessage;

  /// No description provided for @tesbihatStepSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{text}, adım {step}/{steps}, {count} / {target}'**
  String tesbihatStepSemantics(
    String text,
    int step,
    int steps,
    int count,
    int target,
  );

  /// No description provided for @tesbihatStepAnnouncement.
  ///
  /// In tr, this message translates to:
  /// **'{text}, adım {step}/{steps}'**
  String tesbihatStepAnnouncement(String text, int step, int steps);

  /// No description provided for @esmaLoading.
  ///
  /// In tr, this message translates to:
  /// **'Esmaü\'l-Hüsna yükleniyor'**
  String get esmaLoading;

  /// No description provided for @esmaLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Esmaü\'l-Hüsna yüklenemedi.'**
  String get esmaLoadFailed;

  /// No description provided for @esmaAdd.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get esmaAdd;

  /// No description provided for @esmaAddSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{reading} Zikirlerim\'e ekle'**
  String esmaAddSemantics(String reading);

  /// No description provided for @esmaRowSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{number}. {reading}, {meaning}'**
  String esmaRowSemantics(int number, String reading, String meaning);

  /// No description provided for @esmaAdded.
  ///
  /// In tr, this message translates to:
  /// **'Zikirlerim\'e eklendi'**
  String get esmaAdded;

  /// No description provided for @esmaCount.
  ///
  /// In tr, this message translates to:
  /// **'Say'**
  String get esmaCount;

  /// No description provided for @esmaSource.
  ///
  /// In tr, this message translates to:
  /// **'Liste: Tirmizî, Daavât 82 — Diyanet sırası (Hadislerle İslâm, c. 1, s. 219) · Okunuş ve anlam: yasin.suresi.gen.tr · Arapça yazı: Amiri fontu'**
  String get esmaSource;

  /// No description provided for @suggestedLoading.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen Zikirler yükleniyor'**
  String get suggestedLoading;

  /// No description provided for @suggestedLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen Zikirler yüklenemedi.'**
  String get suggestedLoadFailed;

  /// No description provided for @suggestedTarget.
  ///
  /// In tr, this message translates to:
  /// **'Hedef: {target}'**
  String suggestedTarget(String target);

  /// No description provided for @suggestedNoTarget.
  ///
  /// In tr, this message translates to:
  /// **'Hedefsiz'**
  String get suggestedNoTarget;

  /// No description provided for @suggestedRowSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{reading}, {meaning}, {target}'**
  String suggestedRowSemantics(String reading, String meaning, String target);

  /// No description provided for @suggestedAdd.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get suggestedAdd;

  /// No description provided for @suggestedAddSemantics.
  ///
  /// In tr, this message translates to:
  /// **'{reading} Zikirlerim\'e ekle'**
  String suggestedAddSemantics(String reading);

  /// No description provided for @suggestedAdded.
  ///
  /// In tr, this message translates to:
  /// **'Zikirlerim\'e eklendi'**
  String get suggestedAdded;

  /// No description provided for @suggestedCount.
  ///
  /// In tr, this message translates to:
  /// **'Say'**
  String get suggestedCount;

  /// No description provided for @suggestedSource.
  ///
  /// In tr, this message translates to:
  /// **'Okunuş, anlam ve sayılar: Diyanet, Hadislerle İslâm (c. 2) · Diyanet Aylık Dergi (Kasım 2024) · TDV İslâm Ansiklopedisi'**
  String get suggestedSource;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
