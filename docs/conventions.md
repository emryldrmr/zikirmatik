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
- Flutter **3.41.x** (stable kanal), Dart **3.11.x** — bootstrap makinesinde 3.41.2 / 3.11.0.
  Kesin alt sınır walking skeleton'da `pubspec.yaml` `environment:` ve `check.conf` `requires`
  satırlarıyla sabitlenir.
- Android: minSdk 24 (ADR 0003, Flutter varsayılanı); targetSdk = Flutter'ın varsayılanı.
- Temel paketler: `flutter_riverpod`, `drift` (+ `drift_dev`, `build_runner`), `http`,
  `flutter_lints`. Sürümler `pubspec.lock` ile sabitlenir (commit edilir).
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
  notu bulunur.

## Known traps
- drift kod üretimi bayatlar: şema değişince `*.g.dart` güncel değilse derleme/davranış sessizce
  sapar — her şema değişikliğinden sonra `dart run build_runner build --delete-conflicting-outputs`
  çalıştır; check'te "üretilen kod güncel" adımı bulunur — from bootstrap 2026-11-02.
- Arapça metin yanlış yönde/fontla çizilir — ayet her zaman açıkça `TextDirection.rtl` ve Amiri Quran
  fontuyla gösterilir; widget testleri varsayılan Ahem fontunu kullanır, ekran görüntüsü için gerçek
  fontu yükle — from bootstrap 2026-11-02.
- Platform kanalları testte sessizce çalışmaz/patlar (`HapticFeedback`) — titreşimi enjekte edilen
  `Haptics` arayüzü üzerinden çağır, testte sahtesiyle doğrula — from bootstrap 2026-11-02.

## Enforced by tooling
- `flutter analyze --fatal-infos --fatal-warnings` + `flutter_lints` (`analysis_options.yaml`):
  isimlendirme, kullanılmayan import, null-safety.
- `dart format --set-exit-if-changed`: biçim.
- Yasak bağımlılıklar FD-1…FD-4: `test/architecture/` import-tarama testi.
- Üretilen kodun güncelliği: check'teki codegen adımı.
(Walking skeleton bu adımları `scripts/check.conf`'ta etkinleştirir.)
