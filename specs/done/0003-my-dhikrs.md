# Spec 0003 — Zikirlerim

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0003-plan.md`
- Self-critique: done

## Intent
Ürün sahibi, kullanıcının birden çok adlı zikir tutabilmesini istiyor: her zikrin kendi sayımı, turu,
toplamı ve hedefi olsun; kullanıcı zikir ekleyebilsin, adını değiştirebilsin, onaylayarak silebilsin ve
sayaç ekranından hangi zikri çektiğini seçebilsin. Başarı, spec 0002'deki cihazın seçili zikir için aynen
çalışması ve mevcut kullanıcının sayacının hiçbir değeri kaybolmadan ilk zikri olması demek. Bilinçli
olarak yapılmayan: önerilen zikirler ve Esma'dan ekleme (BR-9, kendi spec'leri), tesbihat, sıralamayı
değiştirme, renk teması ve Ayarlar (spec 0004). Uygulama hazır dini metin eklemez; adları kullanıcı yazar,
iş hassas alanın dışındadır.

## Requirements
1. Kullanıcının bir veya daha çok zikri vardır; her zikrin adı (BR-1) ve kendi sayaç durumu (sayım, tur,
   toplam, hedef — spec 0002) vardır.
2. Cihazın üstünde seçili zikrin adı görünür; buna dokununca zikir listesi açılır ve başka bir zikir
   seçilebilir. Sayaç işlemleri yalnızca seçili zikri etkiler.
3. Kullanıcı yeni zikir ekleyebilir: ad (BR-1) ve isteğe bağlı hedef (BR-2). Eklenen zikir seçili olur ve
   sıfırdan başlar.
4. Kullanıcı bir zikrin adını değiştirebilir; sayaç değerleri değişmez.
5. Kullanıcı bir zikri onaylayarak silebilir (BR-6); silinen zikrin değerleri de silinir.
6. Son zikir silinirse boş durum gösterilir; buradan yeni zikir eklenebilir.
7. Zikirler, her birinin değerleri ve hangi zikrin seçili olduğu kalıcıdır (BR-8).
8. Spec 0002'den kalan sayaç, değerleri aynen korunarak ilk zikir olur; yeni kurulumda da hazır bir ilk
   zikir vardır, böylece cihaz ilk açılışta hemen kullanılabilir.

## User experience
- **Flow:** Zikirlerim → cihazın üstünde "Zikir ▾" → dokun → liste (seçili olan işaretli) → "Yeni zikir"
  → ad "Sabah" + hedef 33 → "Kaydet" → "Sabah" seçili, sayım 0 → say → listeden "Zikir"e dön → onun
  değerleri aynen → listede "Sabah"ın düzenle simgesi → ad "Sabah zikri" → "Kaydet" → aynı ekranda
  "Sil" → onay → "Sabah zikri" listeden kalkar.
- **States:**
  - *Yükleniyor / hata:* spec 0001/0002'deki gibi.
  - *Seçili zikir:* cihazın üstünde zikrin adı ve ▾ (uzun ad tek satırda "…" ile kısalır); altında 0002 cihazı.
  - *Zikir listesi:* tüm zikirler eklenme sırasıyla, seçili olan işaretli; her satırda "Düzenle"; en altta "Yeni zikir".
  - *Yeni zikir formu:* ad alanı, isteğe bağlı hedef alanı, "Vazgeç" / "Kaydet".
  - *Düzenleme formu:* ad alanı, "Sil", "Vazgeç" / "Kaydet".
  - *Geçersiz ad:* "Ad 1–50 karakter olmalı." uyarısı; "Kaydet" devre dışı.
  - *Geçersiz hedef:* spec 0002'deki uyarı ("1 ile 100.000 arasında bir sayı girin."); "Kaydet" devre dışı.
  - *Silme onayı:* "“Sabah” silinsin mi? Sayımı ve toplamı da silinir." — "Vazgeç" / "Sil".
  - *Boş durum:* "Henüz zikir yok." ve "Zikir ekle" butonu; cihaz gösterilmez.
- **Design reference:** none — the flow above is the design.
- **Accessibility:** zikir adının etiketi "Zikir: Sabah. Değiştirmek için dokunun."; düzenle simgesi
  "Sabah zikrini düzenle"; tüm dokunma hedefleri en az 48×48 dp; ekran okuyucu seçili satırı "seçili" okur.

## Constraints & out of scope
- Spec 0001 ve 0002'nin kriterleri seçili zikir için geçerli kalır; üst çubuk başlığı "Zikirlerim" olarak kalır.
- Self-critique G1–G9 (emryldrmr, 2026-11-02): ilk zikrin adı "Zikir"; yeni kurulum hazır bir "Zikir" ile başlar; seçici cihazın üstünde, üst çubuk başlığı "Zikirlerim" kalır (0001 başlık kriteri korunur); düzenleme formu yalnızca adı değiştirir, hedef eklerken veya cihazdaki hedef butonuyla; aynı ad serbest; seçili zikir silinince ilk kalan seçilir; son zikir silinebilir (boş durum); eklenme sırası, sınır yok; uzun ad cihaz üstünde "…", listede tam.
- **Out of scope:** önerilen zikir / Esma'dan ekleme (BR-9), tesbihat (BR-13), zikirleri yeniden sıralama,
  arama, bulut senkronu, renk teması ve Ayarlar (0004), bir zikrin hedefini düzenleme formundan değiştirme
  (hedef, cihazdaki hedef butonuyla değişir — 0002 AC-7 kuralıyla).

## Acceptance criteria
- [x] AC-1 — Yeni kurulumda tek bir "Zikir" adlı zikir vardır ve seçilidir (sayım 0, toplam 0, hedef yok); spec 0002 verisi olan kurulumda o sayaç tüm değerleriyle (sayım, tur, toplam, hedef) "Zikir" adlı ilk zikir olur.
- [x] AC-2 — Cihazın üstünde seçili zikrin adı görünür; dokununca tüm zikirler eklenme sırasıyla listelenir ve seçili olan işaretlidir.
- [x] AC-3 — Yeni zikir: ad kırpıldıktan sonra 1 ve 50 karakter kabul edilir; boş, yalnızca boşluk ve 51 karakter reddedilir ("Ad 1–50 karakter olmalı.", Kaydet devre dışı); hedef boş bırakılabilir ya da 1–100000 olmalıdır. Kaydedilen zikir listenin sonuna eklenir, seçili olur ve sayım 0, toplam 0, tur 0 ile başlar.
- [x] AC-4 — Listeden başka bir zikir seçilince cihaz o zikrin kendi sayım, tur, toplam ve hedefini gösterir; sayma, geri alma, sıfırlama ve hedef değişikliği yalnızca seçili zikri değiştirir.
- [x] AC-5 — Ad değiştirme AC-3'teki ad kurallarıyla çalışır; kaydedilince yeni ad listede ve cihazın üstünde görünür, sayaç değerleri değişmez; "Vazgeç" hiçbir şeyi değiştirmez.
- [x] AC-6 — Silme onay ister; "Sil" zikri ve değerlerini kaldırır, seçili zikir silindiyse listede ilk kalan zikir seçili olur; "Vazgeç" hiçbir şeyi değiştirmez.
- [x] AC-7 — Son zikir silinince "Henüz zikir yok." ve "Zikir ekle" görünür, cihaz görünmez; buradan eklenen zikir seçili olur ve cihaz geri gelir.
- [x] AC-8 — Zikirler, adları, her birinin sayım/tur/toplam/hedefi ve seçili zikir uygulama yeniden başlatılınca (aynı kalıcı depoyla) aynen görünür.
- [x] AC-9 — Aynı adla iki zikir eklenebilir ve ayrı ayrı sayılır; 50 karakterlik bir ad cihazın üstünde tek satırda "…" ile kısaltılır, listede tamamı okunabilir.
- [x] AC-10 — Erişilebilirlik: zikir adının etiketi "Zikir: <ad>. Değiştirmek için dokunun.", düzenle simgesinin etiketi "<ad> zikrini düzenle"; seçili satır ekran okuyucuya seçili olarak bildirilir; tüm dokunma hedefleri en az 48×48 dp.

## Definition of Done
- [x] Every acceptance criterion mapped to proof (test or reproducible observation)
- [x] `scripts/check` green
- [x] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [x] Docs / ADRs updated if behavior or architecture changed
- [x] Spec moved to `specs/done/` (it becomes immutable there)

## Scorecard (fill at ship — honest numbers make the process improvable)
| Metric | Value |
|---|---|
| Spec revisions | 0 |
| Fix rounds | 2 (fix-1: F-1, F-2, I-5; fix-2: N-1, N-2, N-3) |
| Review findings: real / noise / deferred | 6 / 6 / 1 (1 Medium, 3 Low, 9 Info incl. VERIFY I-1, I-2; F-3 → B-2) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent VERIFY (separate session, QA role), 2026-11-04, @f6abb65. Fix-2 diff (6e0e2dd..f50f5e5) read: only N-1/N-2/N-3.
Full green: CHECK GREEN (full, 6 steps, 295 s) @f6abb65 — https://github.com/emryldrmr/zikirmatik/actions/runs/41512972289
(107 tests). Deliberate breaks B1–B6 outside the repo; each turned its mapped test red.

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `drift_dhikr_list_repository_test.dart` — `a new database starts with one dhikr named Zikir`, `migrates a v2 counter into the first dhikr`; `my_dhikrs_test.dart` — `first launch shows Zikir selected with zero`; break B4 (migration overwrites the counter); S-1 | PASS |
| AC-2 | `my_dhikrs_test.dart` — `picker lists dhikrs in creation order with the selected one marked`; break B6 (selected flag lost); S-2, S-3 | PASS |
| AC-3 | `dhikr_name_test.dart` — `accepts 1 and 50 characters after trimming`, `rejects empty, blank and 51 characters`; `my_dhikrs_test.dart` — `adding a dhikr validates name and target and selects it at zero`; breaks B1 (limit 50→51), B2 (no trim); S-4, S-5, S-6 | PASS |
| AC-4 | `my_dhikrs_test.dart` — `switching shows each dhikr's own values`, `counter actions change only the selected dhikr`, `target change affects only the selected dhikr` | PASS |
| AC-5 | `my_dhikrs_test.dart` — `renaming keeps the values`, `rename cancel changes nothing`, `rename validates the name`; breaks B1, B2; S-7 | PASS |
| AC-6 | `dhikr_list_test.dart` — `deleting the selected one selects the first remaining`; `drift_dhikr_list_repository_test.dart` — `delete removes the dhikr and its counter`; `my_dhikrs_test.dart` — `delete asks and removes`, `delete cancel changes nothing`; breaks B3 (last remaining selected), B5 (counter row kept); S-8 | PASS |
| AC-7 | `my_dhikrs_test.dart` — `deleting the last dhikr shows the empty state and adding brings the device back`; S-9 | PASS |
| AC-8 | `drift_dhikr_list_repository_test.dart` — `list, values and selection survive reopening` (file database); `my_dhikrs_test.dart` — `restart shows the same dhikrs and selection` | PASS |
| AC-9 | `my_dhikrs_test.dart` — `same names are separate dhikrs`, `a 50-character name is ellipsized above the device and complete in the list`; S-10, S-11 | PASS |
| AC-10 | `my_dhikrs_test.dart` — `semantics labels, selected state and touch targets`; break B6; picker button measured 54×48 dp with a 1-character name | PASS |

UI: S-1…S-13 agent-captured (headless widget render, Roboto + Material icons, 412×915 dp), judged by emryldrmr at SHIP, 2026-11-04 (images outside the repo, deleted after ship). Manual run on the Android emulator also passed (emryldrmr, 2026-11-04).
