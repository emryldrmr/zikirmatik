# Spec 0001 — Walking skeleton

- Status: Approved
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
- Platform: Android, minSdk 23 (ADR 0001). Yığın ve paketler: `docs/conventions.md`.
- Testlerde gerçek ağ yok; bu spec'te ağ erişimi de yok.
- Sayımın üst sınırı yoktur (Dart 64-bit `int`). Her dokunuş hemen kalıcı kaydedilir. Hata durumunda "Tekrar dene" yoktur (sayaç spec'ine). Ekran yönü serbest, açık tema. Self-critique G1–G6: emryldrmr, 2026-11-02.
- **Out of scope:** zikir adı ve birden çok zikir, hedef/tur (BR-2, BR-4), geri alma (BR-5),
  sıfırlama (BR-6, BR-7), toplam, titreşim, sayım kaydedilemediğinde gösterilecek davranış
  (sayaç spec'inde), tesbihat, Ayarlar içeriği, tema seçimi, Önerilen Zikirler / Esma / Kur'an
  içeriği, iOS derlemesi, uygulama ikonu tasarımı (Flutter varsayılanı kalır).
- Dini metin içermez → hassas alan dışında. (Bölüm adları menü etiketidir, içerik değildir.)
- Split: tek kullanıcı yeteneği (sayaç) + araç zinciri; walking skeleton tanımı gereği tek parça.

## Acceptance criteria
- [ ] AC-1 — İlk açılışta (kayıtlı veri yokken) Zikirlerim ekranı açılır ve sayım 0 gösterilir.
- [ ] AC-2 — Sayaç alanına her dokunuş sayımı 1 artırır, hızlı ardışık dokunuşlar dahil (gecikme filtresi yok): 3 dokunuştan sonra sayım 3'tür.
- [ ] AC-3 — Sayım kalıcıdır: sayım 3 iken uygulama yeniden başlatılınca (aynı kalıcı depoyla) sayım 3 gösterilir.
- [ ] AC-4 — Yükleniyor durumu: kayıtlı sayım okunurken yükleme göstergesi görünür, sayım rakamı görünmez ve dokunuş sayımı değiştirmez.
- [ ] AC-5 — Hata durumu: kayıtlı sayım okunamazsa "Sayaç yüklenemedi." görünür, hata ayrıntısı görünmez ve dokunuş sayımı değiştirmez.
- [ ] AC-6 — Yan menü tam olarak şu beş girişi bu sırayla gösterir: Zikirlerim, Önerilen Zikirler, Esmaü'l-Hüsna, Kur'an + Meal, Ayarlar.
- [ ] AC-7 — Zikirlerim dışındaki her girişe dokununca başlığı o bölümün adı olan ve "Bu bölüm yakında." metnini gösteren ekran açılır; yan menüden Zikirlerim'e dönülünce sayım değişmemiştir.
- [ ] AC-8 — Erişilebilirlik: sayaç alanının ekran okuyucu etiketi güncel sayımı içerir ("Sayım 3. Saymak için dokunun."), menü simgesinin etiketi "Menüyü aç"tır.
- [ ] AC-9 — Mimari: FD-1…FD-4'ü denetleyen test check içinde çalışır; kuralı ihlal eden bir import eklendiğinde kırmızı olur.
- [ ] AC-10 — `./scripts/check` (full) biçim, analiz, kod üretimi güncelliği, testler ve Android debug APK derlemesini çalıştırıp yeşil biter; `--fast` APK derlemesi olmadan yeşil biter; aynı full profil CI'da (GitHub Actions) yeşildir.

## Definition of Done
- [ ] Every acceptance criterion mapped to proof (test or reproducible observation)
- [ ] `scripts/check` green
- [ ] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [ ] Docs / ADRs updated if behavior or architecture changed
- [ ] Spec moved to `specs/done/` (it becomes immutable there)

## Scorecard (fill at ship — honest numbers make the process improvable)
| Metric | Value |
|---|---|
| Spec revisions | |
| Fix rounds | |
| Review findings: real / noise / deferred | |
| Regressions introduced | |
| Bugs escaped to production | |
