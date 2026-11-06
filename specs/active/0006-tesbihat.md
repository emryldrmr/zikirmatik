# Spec 0006 — Namaz sonrası tesbihat

- Status: Approved
- Mode: lite
- Plan: `specs/plans/0006-plan.md`
- Self-critique: done

## Intent
Kullanıcı namazdan sonra tesbihatı zikir değiştirmeden, tek ekranda ve sırayla çekebilmek istiyor. Uygulama
namaz sonrası tesbihatı hazır sunar: her adımın hedefine ulaşılınca titreşir ve kendiliğinden sıradaki adıma
geçer (BR-13); son adım bitince tesbihatın tamamlandığı açıkça görünür. Başarı, kullanıcının ekrana bakmadan
sayıp bitirebilmesi ve tesbihat metninin kaynağıyla birebir aynı olmasıdır. Bilinçli olarak yapılmayan:
kullanıcının kendi tesbihat dizisini kurması, adımları/hedefleri değiştirmesi, kelime-i tevhid adımı, ses
tuşuyla ve tam ekranla sayma (sonraki spec). Clarify S1–S7 kararları (emryldrmr, 2026-11-06) buraya katlandı.

## Requirements
1. Uygulamada tek bir hazır tesbihat vardır: "Namaz sonrası tesbihat". Adımları sırasıyla, metin ve hedefleri
   kaynağıyla birebir (BR-12):

   | Adım | Metin (ekranda) | Hedef |
   |---|---|---|
   | 1 | Sübhânallah | 33 |
   | 2 | Elhamdülillâh | 33 |
   | 3 | Allâhu ekber | 33 |

   Kaynak: Müslim, Mesâcid 146 (namaz sonrası 33 tesbih, 33 tahmid, 33 tekbir); yazım: Diyanet İşleri
   Başkanlığı. Kaynak, Kaynaklar sayfası geldiğinde orada anılır (BR-12).
2. Tesbihat, Zikirlerim'deki zikir seçicide kullanıcının zikirlerinden ayrı, en üstte bir satır olarak seçilir;
   seçilince aynı cihazla sayılır. Adımlar ve hedefler değiştirilemez, tesbihat silinemez ve adı değiştirilemez.
3. Her dokunuş o adımın sayımını 1 artırır. Sayım adımın hedefine ulaşınca titreşim tetiklenir (Ayarlar'daki
   titreşim ayarına uyar, BR-4 gibi) ve sıradaki adıma sayım 0 ile geçilir.
4. Son adımın hedefi tamamlanınca tesbihat tamamlanır: titreşim tetiklenir, "Tamamlanan" sayısı 1 artar ve
   tamamlandı durumu gösterilir. Bu durumda dokunuş sayım yapmaz; "Baştan başla" tesbihatı 1. adıma, sayım 0'a
   döndürür.
5. Geri al o adımın sayımını 1 azaltır; sayım 0 ise hiçbir şey değişmez — önceki adıma dönülmez, tamamlanma
   geri alınmaz (BR-5 gibi).
6. Sıfırla onay ister (BR-6); onaylanınca tesbihat 1. adıma, sayım 0'a döner. "Tamamlanan" sayısı korunur
   (BR-7 gibi).
7. Tesbihatın durumu (hangi adımda olduğu, o adımın sayımı, tamamlanmış olup olmadığı, "Tamamlanan" sayısı)
   ve seçicide tesbihatın seçili olması kalıcıdır (BR-8).
8. Tesbihat kullanıcının zikirlerinden bağımsızdır: hiçbir zikrin sayımı, turu, toplamı ya da hedefi değişmez;
   zikirle tesbihat arasında geçiş her ikisinin değerlerini korur.

## User experience
- **Flow:** Zikirlerim → cihazın üstünde zikir adı ▾ → seçicinin en üstünde "Namaz sonrası tesbihat" →
  dokun → cihazın üstünde "Namaz sonrası tesbihat ▾", altında "Sübhânallah" ve "Adım 1/3" → 33 dokunuş →
  titreşim, "Elhamdülillâh", "Adım 2/3", sayım 0 → 33 → "Allâhu ekber", "Adım 3/3" → 33 → titreşim,
  "Tesbihat tamamlandı", "Tamamlanan 1", "Baştan başla" → dokun → "Sübhânallah", "Adım 1/3", sayım 0.
- **States:**
  - *Seçicide tesbihat satırı:* en üstte "Namaz sonrası tesbihat", altında bir ayraç ve kullanıcının zikirleri;
    seçiliyse işaretli; düzenle simgesi ve ilerleme bilgisi yoktur.
  - *Tesbihat sayılıyor:* cihaz üstünde tesbihatın adı ▾; cihazda adımın metni, "Adım n/3", sayım, "Hedef 33",
    "Tamamlanan n"; geri al ve sıfırla butonları; "Tur" ve "Toplam" görünmez, hedef butonu yoktur.
  - *Tesbihat tamamlandı:* cihaz yerinde kalır; ekranında "Tesbihat tamamlandı", "Tamamlanan n" ve "Baştan başla" butonu; sayma butonu sayım
    yapmaz; geri al yoktur.
  - *Sıfırlama onayı:* "Tesbihat baştan başlasın mı?" — "Vazgeç" / "Sıfırla".
  - *Zikir yokken (boş durum):* "Henüz zikir yok." ve "Zikir ekle"in yanında "Tesbihat çek" butonu; tesbihata
    buradan da girilir.
  - *Yükleniyor / hata:* spec 0001/0002'deki gibi.
- **Design reference:** none — the flow above is the design.
- **Accessibility:** adım etiketi "Sübhânallah, adım 1/3, 0 / 33"; adım geçişinde yeni adım ("Elhamdülillâh, adım 2/3") ve "Tesbihat tamamlandı"
  ekran okuyucuya duyurulur; seçicide tesbihat satırı seçili olarak bildirilir; tüm dokunma hedefleri en az
  48×48 dp.

## Constraints & out of scope
- **Sensitive area: Dini metin bütünlüğü** — adımların metni, sırası ve hedefleri Requirements 1'deki tabloyla
  birebir; ekranda değiştirilmez, kırpılmaz, normalleştirilmez (BR-12). Tablo dışı bir değişiklik spec
  değişikliğidir (R-08).
- Spec 0001–0005'in kriterleri kullanıcının zikirleri için geçerli kalır; geri tuşu (0005) tesbihat seçiliyken
  de aynı çalışır.
- Clarify S1–S7 (emryldrmr, 2026-11-06): metin/kaynak yukarıdaki tablo; yalnızca hazır tesbihat; giriş seçicide;
  ayrı ve kalıcı durum; tamamlanınca durur, "Baştan başla"; geri al/sıfırla BR-5/6/7 gibi; titreşim bugünkü tur
  titreşimiyle aynı ve ayara uyar.
- Self-critique G1–G7 (emryldrmr, 2026-11-06): boş durumda "Tesbihat çek" butonu; cihazda "Hedef 33" ve "Tamamlanan n", "Tur"/"Toplam"/hedef butonu yok; sıfırlama onayı "Tesbihat baştan başlasın mı?" — "Vazgeç"/"Sıfırla"; açılışta seçili zikir değişmez; seçici satırında ilerleme yok; tamamlandıda cihaz yerinde, sayma pasif, geri al gizli; adım geçişinde yeni adım ve "adım n/3" duyurulur.
- **Out of scope:** kendi tesbihat dizisini kurma, adım/hedef değiştirme, birden çok tesbihat; kelime-i tevhid
  ("Lâ ilâhe illallâhu vahdehû…") adımı; Arapça yazı ve okunuş/anlam gösterimi; tesbihat geçmişi/istatistik;
  ses tuşuyla ve tam ekranla sayma, ekranı açık tutma (sonraki spec); Kaynaklar sayfası (Kur'an spec'i).

## Acceptance criteria
- [ ] AC-1 — Seçicinin en üstünde "Namaz sonrası tesbihat" satırı vardır (düzenle simgesi yok), altında kullanıcının zikirleri eklenme sırasıyla; seçilince cihazın üstünde "Namaz sonrası tesbihat", cihazda "Sübhânallah", "Adım 1/3", sayım 0, "Hedef 33", "Tamamlanan 0" görünür; "Tur" ve "Toplam" ile hedef butonu görünmez. Yeni kurulumda ve mevcut kurulumda açılışta seçili olan zikir değişmez (tesbihat ancak seçilince açılır).
- [ ] AC-2 — Adımların metni, sırası ve hedefleri Requirements 1'deki tabloyla birebir aynıdır (ekrandaki metin tablodaki metinle bayt düzeyinde eşit, BR-12).
- [ ] AC-3 — Her dokunuş adımın sayımını 1 artırır; 32. dokunuşta adım değişmez; 33. dokunuşta titreşim olur ve "Elhamdülillâh", "Adım 2/3", sayım 0 görünür; 2. adımdan 3. adıma geçiş aynıdır. Titreşim kapalıysa geçiş aynen olur, titreşim olmaz.
- [ ] AC-4 — 3. adımın 33. dokunuşunda titreşim olur, "Tesbihat tamamlandı" ve "Tamamlanan 1" görünür; bu durumda dokunuş hiçbir değeri değiştirmez; "Baştan başla" 1. adımı sayım 0 ile açar, "Tamamlanan" 1 kalır; ikinci tamamlanma "Tamamlanan 2" yapar.
- [ ] AC-5 — Geri al adım içinde sayımı 1 azaltır; adımın sayımı 0 iken (2. adımın başı dahil) hiçbir şey değişmez ve önceki adıma dönülmez; tamamlandı durumunda geri al yoktur.
- [ ] AC-6 — Sıfırla onay sorar; "Sıfırla" 1. adımı sayım 0 ile açar ve "Tamamlanan" değişmez; "Vazgeç" hiçbir şeyi değiştirmez.
- [ ] AC-7 — Uygulama yeniden başlatılınca (aynı kalıcı depoyla) tesbihat seçili açılır ve adımı, sayımı, tamamlandı durumu ve "Tamamlanan" sayısı aynen görünür.
- [ ] AC-8 — Tesbihat sayılırken, sıfırlanırken ve tamamlanırken hiçbir zikrin sayımı, turu, toplamı ya da hedefi değişmez; zikirden tesbihata ve geri geçişte her ikisi kendi değerlerini korur.
- [ ] AC-9 — Boş durumda "Tesbihat çek" butonu tesbihatı açar; tesbihattan seçiciye dönülerek "Yeni zikir" eklenebilir.
- [ ] AC-10 — Erişilebilirlik: adım etiketi "<metin>, adım n/3, <sayım> / 33"; adım geçişinde "<yeni metin>, adım n/3" ve "Tesbihat tamamlandı" ekran okuyucuya duyurulur; seçicideki tesbihat satırı seçiliyse seçili bildirilir; dokunma hedefleri en az 48×48 dp.

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
