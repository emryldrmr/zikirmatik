# Spec 0019 — Kaynaklar sayfası

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0019-plan.md`
- Self-critique: done

## Intent
Kullanıcı, uygulamada gördüğü dini metinlerin (Esmaü'l-Hüsna, Önerilen Zikirler, tesbihat) ve Arapça yazı tipinin
nereden geldiğini tek bir yerde görmek istiyor. Kaynakları açıkça anmak BR-12'nin de şartı. Başarı: Ayarlar'ın
sonundaki "Kaynaklar" girişi, her kaynağı adı, kullanım alanı ve kullanım koşuluyla ağ olmadan listeleyen bir
sayfa açar. Bu sayfa, Kur'an metni ekrana gelmeden önce Tanzil'in atıf şartını karşılayacak yeri de hazırlar.
Bilinçli olarak yapılmayanlar: Kur'an, meal ve AlQuran Cloud satırları (spec 0020 ekler), tıklanabilir adresler,
ekranlardaki mevcut kaynak satırlarının değişmesi. "Kur'an + meal + Kaynaklar" işinin bölünmüş ilk parçasıdır.
Kararlar S1–S7, ekran 1–8 tasarımı ve self-critique G1–G4 (emryldrmr, 2026-11-21) buraya katlandı.

## Requirements
1. **Giriş:** Ayarlar ekranının en sonunda, "Yedekleme" bölümünün altında "Hakkında" başlıklı yeni bir bölüm
   vardır. Bölümde tek satır bulunur: başlık "Kaynaklar", alt metin "Uygulamadaki dini metinlerin ve yazı tipinin
   kaynakları". Satıra dokununca Kaynaklar sayfası açılır. "Hakkında" kalıcı bir bölümdür; ileride uygulama
   hakkındaki başka satırlar da buraya gelebilir. Sürüm bilgisi yan menüde kalır (G4).
2. **Sayfa:** Üst çubukta "Kaynaklar" başlığı ve geri oku bulunur. Geri ok ya da sistem geri hareketi Ayarlar'a
   döner (spec 0005 ile tutarlı).
3. **Bölümler ve sıra:** Sayfa aşağıdaki bölümleri bu sırayla, her birini kendi başlığıyla gösterir. Metinler
   **birebir** buradaki gibidir (BR-12: değiştirilmez, kırpılmaz, normalleştirilmez):
   | Bölüm başlığı | Metin |
   |---|---|
   | Esmaü'l-Hüsna | Liste: Tirmizî, Daavât 82 — Diyanet sırası (Hadislerle İslâm, c. 1, s. 219) · Okunuş ve anlam: yasin.suresi.gen.tr · Arapça yazı: Amiri fontu |
   | Önerilen Zikirler | Okunuş, anlam ve sayılar: Diyanet, Hadislerle İslâm (c. 2) · Diyanet Aylık Dergi (Kasım 2024) · TDV İslâm Ansiklopedisi |
   | Tesbihat | Müslim, Mesâcid 146 (namaz sonrası 33 tesbih, 33 tahmid, 33 tekbir); yazım: Diyanet İşleri Başkanlığı. |
   | Yazı tipi | Amiri Quran — The Amiri Project Authors · SIL Open Font License 1.1 · github.com/aliftype/amiri |

   Esma ve Önerilen Zikirler metni, o ekranların altında bugün görünen kaynak satırıyla aynı metindir. İkisi
   ayrışamaz: biri değişirse diğeri de değişir. Tesbihat metni spec 0006'daki kaynak satırıdır. Yazı tipi satırı
   `assets/fonts/OFL.txt`'deki telif ve lisans bilgisidir. Esma metnindeki "Arapça yazı: Amiri fontu" ifadesi
   Yazı tipi bölümüyle tekrar etse de kırpılmaz (G1): metin, Esma ekranındakiyle aynı kalmalıdır.
4. **Adresler** düz metindir: dokunulunca bir şey olmaz, tarayıcı açılmaz.
5. **Ağ yok:** Sayfa tamamen uygulamanın içindeki metinden oluşur, internet olmadan aynen görünür.
6. **Mevcut satırlar korunur:** Esmaü'l-Hüsna ve Önerilen Zikirler ekranlarının altındaki kaynak satırları ve
   önerilen zikirlerin satır başı referansları olduğu gibi kalır.
7. **Genişleyebilirlik (davranış değil, kapsam notu):** Spec 0020, Kur'an bölümünü bu sayfanın en üstüne ekler.

## User experience
- **Flow:** Yan menü → Ayarlar → en alta kaydır → "Hakkında" altında "Kaynaklar" → Kaynaklar sayfası → geri →
  Ayarlar.
- **States:** Sayfanın tek durumu vardır: dolu. Metinler uygulamaya gömülü olduğu için boş, yükleniyor, hata ya
  da izin durumu yoktur. Açık ve koyu temada okunur (Ayarlar > Tema).
- **Design reference:** https://claude.ai/artifact/VQm29WVJFkwoMY7J7oPYnc, sürüm 3 (1795210359-cf13), ekran 7
  (Ayarlar girişi) ve ekran 8 (Kaynaklar sayfası). 0019'da Kur'an bölümü yoktur. Ekran 7'deki alt metin
  Gereksinim 1'deki metinle değişir: Kur'an henüz gelmediği için kaynak türlerini saymaz.
- **Accessibility:** Bölüm başlıkları ekran okuyucuya başlık olarak bildirilir. Metin, sistemin yazı boyutu
  ayarıyla büyür ve kesilmez: uzun satırlar alta kayar, sayfa kaydırılabilir. Renk karşıtlığı uygulamanın
  temasından gelir; ayrı renk yoktur.

## Constraints & out of scope
- `Sensitive area: Dini metin bütünlüğü` (kaynak gösterimi, `docs/domain.md`).
- Yeni paket ve yeni izin yok. Ağ yok.
- Split: "Kur'an + meal + Kaynaklar" üçe bölündü (S1, emryldrmr, 2026-11-21): 0019 Kaynaklar sayfası →
  0020 Kur'an + Diyanet meali (Kaynaklar'a Kur'an bölümünü ekler) → 0021 meal seçimi. 0021 isteğe bağlı değildir:
  **reklamdan önce şarttır.** Gerekçe: Diyanet'ten ticari izin alınamazsa varsayılan meal, telif süresi dolmuş ya
  da serbest lisanslı bir meale bir ayarla çevrilebilmeli (B-1).
- Kapsam dışı: Kur'an, meal ve AlQuran Cloud satırları (0020); tıklanabilir ya da kopyalanabilir adresler;
  lisans metinlerinin tamamını gösterme (Flutter'ın lisans sayfası dahil); Esma ve Önerilen Zikirler ekranlarındaki
  kaynak satırlarını değiştirmek ya da kaldırmak; Kaynaklar sayfasına yan menüden giriş.
- Font lisansı (G2): OFL, telif notunun ve lisansın fontla birlikte dağıtılmasını ister; `assets/fonts/OFL.txt`
  bugün APK'ya girmez. Plan, `AmiriQuran-Regular.ttf`'in bilgi alanlarında (copyright / license) bu notun olup
  olmadığını doğrular. Yoksa ayrı bir backlog kaydı açılır; 0019'un kapsamı büyümez.
- Docs: `docs/architecture.md`'deki "Kalan sıra" satırı 0019–0021 bölünmesiyle güncellenir (0018 shipped notu
  dahil). `docs/domain.md`'de BR-12'nin "Ayarlar > Kaynaklar" ifadesi zaten doğrudur, değişmez.

## Acceptance criteria
- [x] AC-1 — Ayarlar'ın en sonunda, "Yedekleme" bölümünden sonra "Hakkında" başlığı ve altında "Kaynaklar" satırı
  alt metniyle görünür (Gereksinim 1).
- [x] AC-2 — "Kaynaklar" satırına dokununca Kaynaklar sayfası açılır. Geri ok da sistem geri hareketi de
  Ayarlar'a döner.
- [x] AC-3 — Sayfada dört bölüm başlığı Gereksinim 3'teki sırayla görünür: Esmaü'l-Hüsna, Önerilen Zikirler,
  Tesbihat, Yazı tipi.
- [x] AC-4 — Her bölümün metni Gereksinim 3'teki tabloyla bayt bayt aynıdır. Tek bir harf değişikliği, bir
  şapka kaybı (â → a), Unicode normalleştirme (NFC → NFD), büyük harfe çevirme ya da baştaki veya sondaki
  boşluk testi düşürür.
- [x] AC-5 — Esma ve Önerilen Zikirler bölümlerindeki metin, o ekranların altındaki kaynak satırıyla aynı
  metindir. Biri değişip diğeri değişmezse test düşer.
- [x] AC-6 — Esmaü'l-Hüsna ve Önerilen Zikirler ekranlarının kaynak satırları ve önerilen zikirlerin satır başı
  referansları değişmemiştir (mevcut testler yeşil kalır).
- [x] AC-7 — Sayfa ağ erişimi olmadan aynen görünür. Adreslere dokunmak hiçbir şey açmaz ve hata vermez.
- [x] AC-8 — Bölüm başlıkları ekran okuyucuda başlık olarak bildirilir. Yazı ölçeği 2,0 kattayken (Android 14+ sistem
  üst sınırı; G3) hiçbir metin kesilmez ve sayfa sonuna kadar kaydırılabilir. Sayfa açık ve koyu temada görünür.

## Definition of Done
- [x] Every acceptance criterion mapped to proof (test or reproducible observation)
- [x] `scripts/check` green
- [x] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [x] Docs / ADRs updated if behavior or architecture changed
- [x] Spec moved to `specs/done/` (it becomes immutable there)

## Scorecard (fill at ship — honest numbers make the process improvable)
| Metric | Value |
|---|---|
| Spec revisions | 1 (self-critique G1–G4 folded before approval) |
| Fix rounds | 0 (build step 2 reverted once in `f0780a6` and redone with amendment A-1 — before review, not a fix round) |
| Review findings: real / noise / deferred | 0 / 0 / 0 (review round 1: clean; VERIFY round 1: clean) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent VERIFY round 1 (separate session, read-only), 2026-11-21 @63f4209, after review round 1 (clean); triage in `specs/plans/0019-plan.md` `## Triage`.
Full green: CHECK GREEN (full, 6 steps, 234 s) @7f8e648 — local (later commits change only specs/). CI @63f4209 (run 44836969122): `check` success. QA's own run of the 0019 test files: `+14: All tests passed!`. Residue: not required — `scripts/check.conf` unchanged.
Deliberate breaks (temp copy outside the repo, restored and diffed after each): B1 Hakkında moved before the backup footer → `about section is last after backup…` red · B2 entry `onTap` emptied → `tapping sources opens the page` and 10 more red · B3 `PopScope(canPop: false)` on the page → `app bar back…`, `system back returns to settings` red · B4 Tesbihat and Yazı tipi swapped → `four section headers in order`, `headers/texts match the spec byte for byte` red · B5 "Mesâcid" → "Mesacid" → `texts match the spec byte for byte` red · B6 "Mesâcid" as NFD (a + U+0302) → same test red · B7 trailing space on the font text → same test red · B8 "." appended to the Esma screen's source line → `esma text mirrors the esma screen source line` red · B9 Önerilen text upper-cased on Kaynaklar → `suggested text mirrors…` red · B10 shared `esmaSource` "Tirmizî" → "Tirmizi" → `esma_test.dart` `the source line is shown at the end of the list` red · B11 address text wrapped in a route-pushing `GestureDetector` → `tapping addresses does nothing` red · B12 `header: false` → `section headers are semantic headers` red · B13 `maxLines: 1` + ellipsis → `text scale two at 320 dp…` red.

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `sources_test.dart` — `about section is last after backup with sources row and subtitle`; B1; S-1, S-2 | PASS |
| AC-2 | `tapping sources opens the page`, `app bar back returns to settings`, `system back returns to settings`; B2, B3 | PASS |
| AC-3 | `four section headers in order`; `sources_text_test.dart` — `headers match the spec byte for byte`; B4; S-3 | PASS |
| AC-4 | `sources_text_test.dart` — `texts match the spec byte for byte` (code point sequences); B5, B6, B7 | PASS |
| AC-5 | `esma text mirrors the esma screen source line`, `suggested text mirrors the suggested screen source line`; B8, B9 | PASS |
| AC-6 | `esma_test.dart` / `suggested_test.dart` — `the source line is shown at the end of the list`; `test/integrity/esma_text_test.dart`, `suggested_dhikrs_text_test.dart` (unchanged on the branch, green in CI); B10 | PASS |
| AC-7 | `page renders from bundled text only`, `tapping addresses does nothing`; `import_rules_test.dart` (FD-3); B11 | PASS |
| AC-8 | `section headers are semantic headers`, `text scale two at 320 dp is not clipped and scrolls to the end`, `light and dark` (contrast ≥ 4.5); B12, B13; S-3…S-6 | PASS |

UI: S-1 Ayarlar end light · S-2 Ayarlar end dark · S-3 Kaynaklar light · S-4 Kaynaklar dark · S-5 Kaynaklar text ×2 top · S-6 Kaynaklar text ×2 end — agent-captured (headless widget render, Roboto + Material icons + Amiri Quran, 1080×2340), outside the repo; judged by emryldrmr at SHIP, 2026-11-21. Optional device observation O1 (plan R7) not run.
