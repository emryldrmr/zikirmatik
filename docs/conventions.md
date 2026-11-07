# Conventions

> Bootstrap 2026-11-02 ile dolduruldu. Burada yalnızca gerçek kurallar var: her kural ya araçla
> zorlanır (tercih edilen) ya da incelemede kontrol edilir.

## Language
- Chat language (interviews, sessions): Türkçe (`tr`)
- Document language (docs/, specs, plans, ADRs, review and verify reports): Türkçe (`tr`)
- Always English (protocol, not prose): ANEW core files, template headings and field labels,
  `Status:` values (Draft / Approved / In progress / Shipped), `Approved by / on:`, `Source:`.
- Code identifiers, branch names, commit messages: **İngilizce**. Alan terimlerinin koddaki
  karşılıkları `docs/domain.md` tablosunda (ör. Zikir → `Dhikr`, Tur → `round`).
- Kullanıcı arayüzü metinleri: Türkçe, Flutter `gen-l10n` ile `lib/l10n/app_tr.arb` içinde; kodda
  sabit kullanıcı metni yazılmaz.
- Agent messages (handoff summaries, refusals, `Next:` lines): chat language; command names, file
  paths and protocol fields verbatim.

## Language & framework versions
- Flutter **3.41.2** (stable), Dart **3.11** — `pubspec.yaml` `environment:` (sdk ^3.11.0,
  flutter >=3.41.0), `check.conf` `requires pub get` (Dart ≥ 3.11) ve CI (`flutter-version: 3.41.2`).
- Android: minSdk 24 (ADR 0003, Flutter varsayılanı); targetSdk = Flutter'ın varsayılanı. JDK 17.
- Temel paketler (spec 0001'de çözülen sürümler): `flutter_riverpod` 2.6.1, `drift` 2.34.4 +
  `drift_dev` 2.34.0 (Flutter 3.41.2'nin sabitlediği `meta 1.17.0` yeni drift_dev'i engelliyor),
  `drift_flutter` 0.3.1, `sqlite3` 3.5.2 (sqlite'ı derleme kancasıyla paketler — host testleri ek
  kurulum istemez), `intl` 0.20.2, `build_runner` 2.15.1, `flutter_lints` 6. Sürümler `pubspec.lock`
  ile sabitlenir (commit edilir); `pub get --enforce-lockfile`. `http` Kur'an spec'inde eklenir.
  Spec 0009: `package_info_plus` 10.2.2 (kurulu sürümü okur; izin ve ağ yok — web için `http`'yi
  dolaylı getirir, Android'de kullanılmaz).
- Font: Amiri Quran (SIL OFL), `assets/fonts/` altında gömülü.

## Naming
- Dart standardı: dosyalar `snake_case.dart`, tipler `UpperCamelCase`, üyeler `lowerCamelCase`.
- Testler `test/` altında `lib/` yapısını aynalar; dosyalar `<name>_test.dart`.
- Bir özelliğin genel arayüz dosyası `lib/features/<feature>/<feature>.dart`.
- Branch adları `docs/git.md`'deki kalıplara uyar.

## Error handling
- `domain` ve `data` katmanları katmanlar arasında exception fırlatmaz; `sealed class` tabanlı
  `Result<T, Failure>` döner (`lib/core/`). Üçüncü taraf exception'ları (`http`, drift) `data`
  sınırında yakalanıp `Failure`'a çevrilir.
- UI her `Failure` için `app_tr.arb`'deki Türkçe, anlaşılır bir mesaj gösterir. Ham API/SQL hatası,
  yığın izi ya da URL kullanıcıya asla gösterilmez.
- Ağ yoksa: önbellekteki veri; o da yoksa "çevrimdışı" durumu ve "Tekrar dene" eylemi.

## Data rules
- Sayım, tur sayısı, toplam: `int`, asla negatif değil (`docs/domain.md` invariants).
- Zaman damgaları UTC saklanır, yerel saatle gösterilir; saat `Clock` soyutlamasıyla okunur
  (`DateTime.now()` doğrudan çağrılmaz).
- Kimlikler: drift'in otomatik artan `int` birincil anahtarı.
- Ayet kimliği her zaman `(surah 1–114, ayah no)` çiftidir; global ayet indeksi yalnızca API
  adaptörünün içinde kalır.
- Dini metin (Kur'an, meal, Esma, önerilen zikir) **asla değiştirilmez, kırpılmaz, normalleştirilmez**;
  kaynağından geldiği gibi saklanır ve gösterilir (BR-12).
- Gömülü içerik (`assets/data/`) kaynağıyla birlikte saklanır; dosyanın başında ya da yanında kaynak
  notu bulunur. Birkaç adımlık sabit dini metin (ör. tesbihat adımları) domain'de `const` olarak,
  dosyanın başında kaynak notuyla durabilir; `test/integrity/` altında bayt düzeyinde bütünlük testi
  zorunludur (plan 0006, R1).

## Known traps
- drift kod üretimi bayatlar: şema değişince `*.g.dart` güncel değilse derleme/davranış sessizce
  sapar — her şema değişikliğinden sonra `dart run build_runner build --delete-conflicting-outputs`
  çalıştır; check'te "üretilen kod güncel" adımı bulunur — from bootstrap 2026-11-02.
- Arapça metin yanlış yönde/fontla çizilir — ayet her zaman açıkça `TextDirection.rtl` ve Amiri Quran
  fontuyla gösterilir; widget testleri varsayılan Ahem fontunu kullanır, ekran görüntüsü için gerçek
  fontu yükle — from bootstrap 2026-11-02.
- Platform kanalları testte sessizce çalışmaz/patlar (`HapticFeedback`) — titreşimi enjekte edilen
  `Haptics` arayüzü üzerinden çağır, testte sahtesiyle doğrula — from bootstrap 2026-11-02.
- Dokunuş yolunda kayıttan önce platform çağrısı (titreşim vb.) beklenir; beklerken gelen dokunuşun
  kaydı eskisiyle ezilir — kaydı dokunuş sırasıyla hemen başlat, platform çağrısını beklemeden
  (`unawaited`) ve hatasını yutarak yap — from spec 0002 review round 1, F-1 (A-2).
- Dart `int.tryParse` `0x21` (onaltılık), `+33` ve bazı başka biçimleri sayı kabul eder — kullanıcı
  girişinde önce `^[0-9]+$` deseni kontrol edilir; alan filtresi (digitsOnly) kullanılmaz, çünkü
  yapıştırılan `0x21`'i sessizce `021`'e (21) çevirir — from spec 0002 review round 1, F-2 (A-3).

## Enforced by tooling
- `flutter analyze --fatal-infos --fatal-warnings` + `flutter_lints` ve ek kurallar
  (`analysis_options.yaml`: strict-casts/inference/raw-types, tek tırnak, sondaki virgül,
  `unawaited_futures`): isimlendirme, kullanılmayan import, null-safety.
- Biçim: `tool/format_check.sh` (`dart format --set-exit-if-changed`; üretilen dosyalar hariç).
- Yasak bağımlılıklar FD-1…FD-4: `test/architecture/import_rules_test.dart`.
- Üretilen kodun güncelliği (drift + gen-l10n): `tool/codegen_check.sh`.
(Hepsi `scripts/check.conf` adımları; spec 0001 ile etkin.)
