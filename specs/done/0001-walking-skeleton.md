# Spec 0001 — Walking skeleton

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0001-plan.md`
- Self-critique: done

## Intent
Geliştirici (ürün sahibi), zikirmatik'in ilk özelliklerini yazmadan önce uçtan uca çalışan en küçük
uygulamayı istiyor: Android'de açılan, yan menüsünden beş bölüme gidilebilen ve tek bir sayacın
dokunuşla artıp uygulama kapansa da korunduğu bir iskelet. Başarı, bu dilimin aynı zamanda araç
zincirini kurması demek: `./scripts/check` gerçek adımlarla (biçim, analiz, kod üretimi, testler,
Android derlemesi) yerelde ve CI'da yeşil, residue testi temiz. Bilinçli olarak yapılmayan: hedef,
tur, geri alma, sıfırlama, birden çok zikir, titreşim ve hiçbir dini metin içeriği — bunlar kendi
spec'leriyle gelir; iskelet bu yüzden hassas alanın dışında kalır.

## Requirements
1. Uygulama Android'de açılır; uygulamanın görünen adı "Zikirmatik"tir.
2. Açılışta "Zikirlerim" ekranı gösterilir; ekranda tek bir sayaç ve sayımı vardır.
3. Sayaç alanına her dokunuş sayımı 1 artırır (BR-3'ün sayım kısmı; toplam bu spec'te yok).
4. Sayım kalıcıdır: uygulama kapatılıp yeniden açıldığında son sayım gösterilir (BR-8).
5. Kayıtlı sayım okunurken ve okunamadığında kullanıcı bunu görür; bu iki durumda dokunuş sayılmaz.
6. Yan menü beş bölümü sırasıyla listeler: Zikirlerim, Önerilen Zikirler, Esmaü'l-Hüsna,
   Kur'an + Meal, Ayarlar. Zikirlerim dışındaki bölümler henüz boş bir "yakında" ekranıdır.
7. Tüm arayüz metinleri Türkçedir.
8. Proje yapısı `docs/architecture.md`'deki yasak bağımlılıklara (FD-1…FD-4) uyar ve bu, check
   tarafından otomatik denetlenir.
9. Doğrulama sözleşmesi gerçek adımlarla çalışır (yerelde ve CI'da), yorum satırındaki planlanan
   adımlar etkinleşir.

## User experience
- **Flow:** Uygulamayı aç → Zikirlerim ekranı, sayaç 0 → sayaç alanına dokun → sayım artar →
  uygulamayı kapat/aç → aynı sayım. Sol üstteki menü simgesi → yan menü → bir bölüm seç → o bölümün
  ekranı → yan menüden Zikirlerim'e dön → sayım değişmemiş.
- **States:**
  - Zikirlerim — *yükleniyor:* kayıtlı sayım okunurken sayaç yerine bir yükleme göstergesi.
  - Zikirlerim — *başarılı:* büyük rakamla sayım ve ekranın büyük bölümünü kaplayan dokunma alanı.
  - Zikirlerim — *hata:* "Sayaç yüklenemedi." mesajı; teknik ayrıntı gösterilmez.
  - Zikirlerim — *boş:* ilk açılışta sayım 0 (ayrı bir boş ekran yok).
  - Yakında ekranları (4 adet) — başlıkta bölüm adı, gövdede "Bu bölüm yakında." metni.
  - Yetkisiz durum yoktur (hesap yok).
- **Design reference:** none — the flow above is the design.
- **Accessibility:** sayaç alanı ekran okuyucuya güncel sayımı ve eylemi bildirir (ör. "Sayım 5.
  Saymak için dokunun."); yan menü simgesi "Menüyü aç" etiketi taşır; dokunma alanı en az 48×48 dp;
  metin kontrastı WCAG AA.

## Constraints & out of scope
- Platform: Android, minSdk 24 (ADR 0001, ADR 0003). Revizyon 1 (2026-11-02, emryldrmr): 23 → 24, plan 0001 risk R3. Yığın ve paketler: `docs/conventions.md`.
- Testlerde gerçek ağ yok; bu spec'te ağ erişimi de yok.
- Sayımın üst sınırı yoktur (Dart 64-bit `int`). Her dokunuş hemen kalıcı kaydedilir. Hata durumunda "Tekrar dene" yoktur (sayaç spec'ine). Ekran yönü serbest, açık tema. Self-critique G1–G6: emryldrmr, 2026-11-02.
- **Out of scope:** zikir adı ve birden çok zikir, hedef/tur (BR-2, BR-4), geri alma (BR-5),
  sıfırlama (BR-6, BR-7), toplam, titreşim, sayım kaydedilemediğinde gösterilecek davranış
  (sayaç spec'inde), tesbihat, Ayarlar içeriği, tema seçimi, Önerilen Zikirler / Esma / Kur'an
  içeriği, iOS derlemesi, uygulama ikonu tasarımı (Flutter varsayılanı kalır).
- Dini metin içermez → hassas alan dışında. (Bölüm adları menü etiketidir, içerik değildir.)
- Split: tek kullanıcı yeteneği (sayaç) + araç zinciri; walking skeleton tanımı gereği tek parça.

## Acceptance criteria
- [x] AC-1 — İlk açılışta (kayıtlı veri yokken) Zikirlerim ekranı açılır ve sayım 0 gösterilir.
- [x] AC-2 — Sayaç alanına her dokunuş sayımı 1 artırır, hızlı ardışık dokunuşlar dahil (gecikme filtresi yok): 3 dokunuştan sonra sayım 3'tür.
- [x] AC-3 — Sayım kalıcıdır: sayım 3 iken uygulama yeniden başlatılınca (aynı kalıcı depoyla) sayım 3 gösterilir.
- [x] AC-4 — Yükleniyor durumu: kayıtlı sayım okunurken yükleme göstergesi görünür, sayım rakamı görünmez ve dokunuş sayımı değiştirmez.
- [x] AC-5 — Hata durumu: kayıtlı sayım okunamazsa "Sayaç yüklenemedi." görünür, hata ayrıntısı görünmez ve dokunuş sayımı değiştirmez.
- [x] AC-6 — Yan menü tam olarak şu beş girişi bu sırayla gösterir: Zikirlerim, Önerilen Zikirler, Esmaü'l-Hüsna, Kur'an + Meal, Ayarlar.
- [x] AC-7 — Zikirlerim dışındaki her girişe dokununca başlığı o bölümün adı olan ve "Bu bölüm yakında." metnini gösteren ekran açılır; yan menüden Zikirlerim'e dönülünce sayım değişmemiştir.
- [x] AC-8 — Erişilebilirlik: sayaç alanının ekran okuyucu etiketi güncel sayımı içerir ("Sayım 3. Saymak için dokunun."), menü simgesinin etiketi "Menüyü aç"tır.
- [x] AC-9 — Mimari: FD-1…FD-4'ü denetleyen test check içinde çalışır; kuralı ihlal eden bir import eklendiğinde kırmızı olur.
- [x] AC-10 — `./scripts/check` (full) biçim, analiz, kod üretimi güncelliği, testler ve Android debug APK derlemesini çalıştırıp yeşil biter; `--fast` APK derlemesi olmadan yeşil biter; aynı full profil CI'da (GitHub Actions) yeşildir.

## Definition of Done
- [x] Every acceptance criterion mapped to proof (test or reproducible observation)
- [x] `scripts/check` green
- [x] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [x] Docs / ADRs updated if behavior or architecture changed
- [x] Spec moved to `specs/done/` (it becomes immutable there)

## Scorecard (fill at ship — honest numbers make the process improvable)
| Metric | Value |
|---|---|
| Spec revisions | 1 (minSdk 23 → 24, A-1 / ADR 0003) |
| Fix rounds | 1 |
| Review findings: real / noise / deferred | 2 / 0 / 0 (both Low) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent VERIFY (QA subagent), 2026-11-02. Full green: CHECK GREEN (full, 6 steps, 273 s) @602a562 —
https://github.com/emryldrmr/zikirmatik/actions/runs/41487224855 (26 tests). Deliberate breaks M1–M11 each
turned the mapped test red (outside the repo, never committed).

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `counter_screen_test.dart` — `shows 0 on first launch`; `drift_counter_repository_test.dart` — `load returns zero when nothing is stored`; S-2 | PASS |
| AC-2 | `counter_screen_test.dart` — `each tap increments, rapid taps included`; `dhikr_count_test.dart` — `increment adds one`; breaks M1, M2; S-3 | PASS |
| AC-3 | `drift_counter_repository_test.dart` — `count survives reopening the database`; `counter_screen_test.dart` — `restart shows persisted count`; breaks M6, M7 | PASS |
| AC-4 | `counter_screen_test.dart` — `loading hides count and ignores taps`; break M3; S-1 | PASS |
| AC-5 | `counter_screen_test.dart` — `error shows message without details and ignores taps`; breaks M4, M5; S-4 | PASS |
| AC-6 | `shell_test.dart` — `drawer lists five sections in order`; break M9; S-5 | PASS |
| AC-7 | `shell_test.dart` — `each section shows coming soon and counter keeps its value`; break M10; S-6…S-10 | PASS |
| AC-8 | `counter_screen_test.dart` — `semantics labels`; `shell_test.dart` — `menu button label` (accessible name via tooltip, accepted at SHIP); break M11 | PASS |
| AC-9 | `import_rules_test.dart` — `lib obeys FD-1..FD-4`, `detects a violating import`; break M8 | PASS |
| AC-10 | Observation: CI run 41487224855 `CHECK GREEN (full, 6 steps, 273 s)` incl. apk; local `./scripts/check --fast` @602a562 `CHECK GREEN (fast, 5 steps, 27 s)` | PASS |

UI: S-1…S-10 agent-captured, judged by emryldrmr at SHIP, 2026-11-02 (images outside the repo, deleted after ship).
