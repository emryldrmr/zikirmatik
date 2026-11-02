# Spec 0003 — Zikirlerim

- Status: Approved
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
- [ ] AC-1 — Yeni kurulumda tek bir "Zikir" adlı zikir vardır ve seçilidir (sayım 0, toplam 0, hedef yok); spec 0002 verisi olan kurulumda o sayaç tüm değerleriyle (sayım, tur, toplam, hedef) "Zikir" adlı ilk zikir olur.
- [ ] AC-2 — Cihazın üstünde seçili zikrin adı görünür; dokununca tüm zikirler eklenme sırasıyla listelenir ve seçili olan işaretlidir.
- [ ] AC-3 — Yeni zikir: ad kırpıldıktan sonra 1 ve 50 karakter kabul edilir; boş, yalnızca boşluk ve 51 karakter reddedilir ("Ad 1–50 karakter olmalı.", Kaydet devre dışı); hedef boş bırakılabilir ya da 1–100000 olmalıdır. Kaydedilen zikir listenin sonuna eklenir, seçili olur ve sayım 0, toplam 0, tur 0 ile başlar.
- [ ] AC-4 — Listeden başka bir zikir seçilince cihaz o zikrin kendi sayım, tur, toplam ve hedefini gösterir; sayma, geri alma, sıfırlama ve hedef değişikliği yalnızca seçili zikri değiştirir.
- [ ] AC-5 — Ad değiştirme AC-3'teki ad kurallarıyla çalışır; kaydedilince yeni ad listede ve cihazın üstünde görünür, sayaç değerleri değişmez; "Vazgeç" hiçbir şeyi değiştirmez.
- [ ] AC-6 — Silme onay ister; "Sil" zikri ve değerlerini kaldırır, seçili zikir silindiyse listede ilk kalan zikir seçili olur; "Vazgeç" hiçbir şeyi değiştirmez.
- [ ] AC-7 — Son zikir silinince "Henüz zikir yok." ve "Zikir ekle" görünür, cihaz görünmez; buradan eklenen zikir seçili olur ve cihaz geri gelir.
- [ ] AC-8 — Zikirler, adları, her birinin sayım/tur/toplam/hedefi ve seçili zikir uygulama yeniden başlatılınca (aynı kalıcı depoyla) aynen görünür.
- [ ] AC-9 — Aynı adla iki zikir eklenebilir ve ayrı ayrı sayılır; 50 karakterlik bir ad cihazın üstünde tek satırda "…" ile kısaltılır, listede tamamı okunabilir.
- [ ] AC-10 — Erişilebilirlik: zikir adının etiketi "Zikir: <ad>. Değiştirmek için dokunun.", düzenle simgesinin etiketi "<ad> zikrini düzenle"; seçili satır ekran okuyucuya seçili olarak bildirilir; tüm dokunma hedefleri en az 48×48 dp.

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
