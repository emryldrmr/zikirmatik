# Spec 0008 — Önerilen Zikirler

- Status: In progress
- Mode: lite
- Plan: `specs/plans/0008-plan.md`
- Self-critique: done

## Intent
Kullanıcı, uygulamaya gömülü ve yaygın bilinen zikirleri internete bağlanmadan tek bir listede görmek istiyor: her
zikrin okunuşu, anlamı, kaynağa dayanan önerilen hedefi (varsa) ve hadis referansı. Bir zikri tek dokunuşla
Zikirlerim'e ekleyip hemen saymak istiyor (BR-9). Başarı, her satırın metninin ve hedefinin belirtilen Diyanet/TDV
kaynağıyla birebir aynı olması (BR-12) ve eklenen zikrin önerilen hedefiyle hemen sayılabilmesidir. Bilinçli olarak
yapılmayan: Arapça yazılış, fazilet metinleri, ayrı detay ekranı, arama/filtre, sesli dinleme, kullanıcının listeye
zikir eklemesi, Kaynaklar sayfası (Kur'an spec'iyle gelir). Clarify S1–S7, kaynak kararı 1–4 ve self-critique
G1–G7 (emryldrmr, 2026-11-07) buraya katlandı.

## Requirements
1. Önerilen Zikirler bölümü aşağıdaki tablodaki 7 zikri tablodaki sırayla, tek kaydırılabilir listede gösterir.
   Her satırda okunuş, anlam, hedef ("Hedef: <sayı>" ya da "Hedefsiz"), hadis referansı ve bir "Ekle" butonu
   vardır. Metinler tabloyla birebir aynıdır; değiştirilmez, kırpılmaz, normalleştirilmez (BR-12).
2. Kaynaklar yalnızca şunlardır (satır başına tabloda belirtilir):
   - **[Hİ]** Diyanet İşleri Başkanlığı, *Hadislerle İslâm*, c. 2, s. 86 —
     https://hadislerleislam.diyanet.gov.tr/sayfa.php?CILT=2&SAYFA=86
   - **[DD]** Dr. Betül Saylan, "Dillerden Düşmeyen Zikirler", *Diyanet Aylık Dergi*, Kasım 2024 —
     https://dijital.diyanet.gov.tr/Dergilik/makale/dillerden-dusmeyen-zikirler?id=37933&productId=6369
   - **[TDV-…]** TDV İslâm Ansiklopedisi maddeleri: TESBİH (c. 40, s. 527–529, 2011) —
     https://islamansiklopedisi.org.tr/tesbih--allah · HAMD (B. Topaloğlu, c. 15, s. 442–445, 1997) —
     https://islamansiklopedisi.org.tr/hamd · HAVKALE (A. O. Koçkuzu, c. 16, s. 536, 1997) —
     https://islamansiklopedisi.org.tr/havkale
   - **[0006]** Spec 0006 tesbihat yazımı (Diyanet İşleri Başkanlığı).
   Erişim 2026-11-07. Her kaynağın erişim günündeki hâli repo dışında PDF olarak saklanır (sabit sürüm).
3. İçerik uygulamaya gömülüdür; bölüm ağ olmadan, ilk açılışta tam olarak görünür.
4. Hedef yalnızca kaynağın sayı verdiği zikirlerde vardır; sayı vermeyen zikir hedefsizdir. Tüm hedefler BR-2
   aralığındadır, tüm okunuşlar BR-1'e (en çok 50 karakter) sığar.
5. "Ekle", o zikri Zikirlerim'e yeni bir zikir olarak ekler (BR-9): adı okunuşudur (tablodaki metin, başına ya da
   sonuna hiçbir şey eklenmeden), hedefi tablodaki hedeftir (hedefsizse hedef yoktur), sayımı, turu ve toplamı
   0'dır. Zikir, Zikirlerim'in sonuna eklenir (spec 0003) ve kalıcıdır (BR-8).
6. Ekleme listeden ayrılmaz; "Zikirlerim'e eklendi" bildirimi ve bildirimde "Say" eylemi görünür. "Say",
   Zikirlerim'i eklenen zikir seçili olarak açar. Ekleme tek başına seçili zikri değiştirmez (spec 0007 ile aynı).
7. Aynı zikir birden çok kez eklenebilir; her ekleme ayrı bir zikirdir.
8. Ekleme mevcut hiçbir zikrin sayımını, turunu, toplamını, hedefini ve tesbihatın durumunu değiştirmez.
9. Listenin en altında kaynak satırı görünür:
   "Okunuş, anlam ve sayılar: Diyanet, Hadislerle İslâm (c. 2) · Diyanet Aylık Dergi (Kasım 2024) · TDV İslâm Ansiklopedisi" (BR-12).

### Önerilen zikir tablosu — Doğrulandı: canlı sayfalarla satır satır, erişim 2026-11-07 (PDF repo dışında) — emryldrmr, 2026-11-07

| No | Okunuş | Anlam | Hedef | Hadis referansı (ekranda) | Kaynak |
|---|---|---|---|---|---|
| 1 | Sübhânallah | Allah’ı bütün noksanlıklardan tenzih ederim | 33 | Müslim, “Mesâcid”, 142, 144-146 | okunuş [0006] · anlam [Hİ] (İbn Mâce, Edeb, 56 meali) · sayı ve ref [TDV-TESBİH] |
| 2 | Elhamdülillâh | Allah’a hamdolsun | 33 | Müslim, “Mesâcid”, 142, 144-146 | okunuş [0006] · anlam [TDV-HAMD] · sayı ve ref [TDV-TESBİH] |
| 3 | Allâhu ekber | Allah en büyük olandır | 33 | Müslim, “Mesâcid”, 142, 144-146 | okunuş [0006] · anlam [Hİ] (İbn Mâce, Edeb, 56 meali) · sayı ve ref [TDV-TESBİH] |
| 4 | sübhânallāhi ve bi-hamdihî | Allah’ı hamd ile tesbih ederim | 100 | Müslim, “Ẕikir”, 28 | okunuş, anlam, sayı, ref [TDV-TESBİH] |
| 5 | estağfirullah | Allah Teâlâ’dan af ve mağfiret dilemek | 100 | Müslim, Zikir, 41 | okunuş, anlam, sayı, ref [DD] |
| 6 | Lâ havle ve lâ kuvvete illâ billâh | Her türlü gücün kaynağı sadece Allah’tır. | — | Buhari, Ezan, 7; Tirmizi, Deavat, 58 | okunuş [TDV-HAVKALE] · anlam ve ref [DD] |
| 7 | Lâ ilâhe illâllâhü vahdehû lâ şerîke leh | Allah’tan başka ilâh yoktur, O, yalnızdır (tektir), O’nun hiçbir şekilde ortağı yoktur. | — | Muvatta’, Hac, 81 | okunuş, anlam, ref [Hİ] |

## User experience
- **Flow:** yan menü → "Önerilen Zikirler" → 7 zikirlik liste → bir satırda "Ekle" → "Zikirlerim'e eklendi"
  bildirimi [Say] → (isteğe bağlı) "Say" → Zikirlerim, eklenen zikir seçili, sayım 0, hedef tablodaki gibi.
- **States:**
  - *Liste:* başlık "Önerilen Zikirler"; her satırda okunuş, anlam, hedef, hadis referansı, "Ekle"; en altta kaynak satırı.
  - *Eklendi:* "Zikirlerim'e eklendi" bildirimi, "Say" eylemiyle; liste yerinde ve kaydırma konumu aynı kalır.
  - *Boş / yükleniyor / hata:* içerik gömülü olduğu için boş ve ağ hatası durumu yoktur. Depolama yazma hatasında
    ekleme geri bildirimi B-2 kapsamındadır (bu spec'te değil).
- **Design reference:** none — the flow above is the design.
- **Accessibility:** satır etiketi "<okunuş>, <anlam>, <hedef>"; "Ekle" butonunun etiketi "<okunuş> Zikirlerim'e ekle";
  bildirim ekran okuyucuya duyurulur; tüm dokunma hedefleri en az 48×48 dp.

## Constraints & out of scope
- **Sensitive area: Dini metin bütünlüğü** — 7 zikrin okunuşu, anlamı, hedefi, hadis referansı ve sırası
  Requirements'taki tabloyla birebir; ekranda ve eklenen zikrin adında değiştirilmez, kırpılmaz, normalleştirilmez
  (BR-12). Tablo dışı bir değişiklik spec değişikliğidir (R-08).
- Spec 0001/0004'teki "Bu bölüm yakında." Önerilen Zikirler için kalkar; Kur'an için aynen sürer. Spec 0001–0007'nin
  diğer kriterleri geçerli kalır; geri tuşu (0005) bu bölümde aynı çalışır.
- Clarify S1–S7 (emryldrmr, 2026-11-07): kaynak tarafımdan önerilir; satırda okunuş, anlam, hedef, hadis ref, "Ekle";
  hedef yalnızca kaynaklı sayı; eklenen adı = okunuş, BR-1'e sığmayan zikir listeye girmez; ekleme akışı Esma ile
  aynı; sıra tablodaki (tesbihat üçlüsü başta); kaynak satırı liste altında.
- Kaynak kararı 1–4 (emryldrmr, 2026-11-07): tek kaynak bulunamadı → satır başına kaynak, yalnız Diyanet/TDV;
  Arapça bu spec'te yok (S2 değişti); salavat ve Hasbünallah kaynak bulunamadığı için listede yok (backlog);
  tablo onaydan önce kullanıcı tarafından canlı sayfalarla doğrulanır.
- Self-critique G1–G7 (emryldrmr, 2026-11-07): G1 küçük harfle başlayan okunuşlar (4, 5) ve `ā` kaynaktaki gibi
  kalır, büyük harfe çevrilmez · G2 kesme işareti her kaynağın kendi karakteridir (`’` U+2019); 7. satırınki canlı
  sayfadan teyit edilir · G3 anlamlar kaynak metinden alıntıdır (1, 3: İbn Mâce, Edeb, 56 mealinden; 5: cümle
  parçası), yeri Kaynak sütununda · G4 33 hedefi namaz sonrası tesbihat sayısına dayanır (0006 ile tutarlı) ·
  G5 hadis referansları her kaynağın yazımıyla birebir, birleştirilmez · G6 salavat ve Hasbünallah backlog'a
  (B-kaydı, onayda) · G7 kaynakların erişim günündeki hâli kullanıcı tarafından repo dışında PDF olarak saklanır;
  doğrulanınca tablo başlığı "Doğrulandı — emryldrmr, <tarih>" olur.
- **Out of scope:** Arapça yazılış; salavat ve Hasbünallah; arama/filtre; detay ekranı, fazilet metni; sesli dinleme;
  paylaşım; "eklendi" işareti / tekrar eklemeyi engelleme; kullanıcının önerilen listeyi düzenlemesi; Ayarlar >
  Kaynaklar sayfası; tesbihat metninin (0006) değişmesi.

## Acceptance criteria
- [ ] AC-1 — Yan menüden "Önerilen Zikirler" açılınca başlık "Önerilen Zikirler" olur ve liste 7 satırı tablodaki sırayla gösterir; her satırda okunuş, anlam, hedef ("Hedef: 33", "Hedef: 100" ya da "Hedefsiz"), hadis referansı ve "Ekle" vardır; "Bu bölüm yakında." görünmez. Metin hiçbir ekran genişliğinde ve en büyük sistem yazı boyutunda kırpılmaz (üç nokta yok), alt satıra geçer.
- [ ] AC-2 — 7 satırın okunuş, anlam ve hadis referansı metni tablodaki metinle bayt düzeyinde eşittir; hedefler tablodaki gibidir; ekrandaki metin saklanan metinle bayt düzeyinde eşittir (BR-12).
- [ ] AC-3 — Her okunuş kırpıldıktan sonra 1–50 karakterdir (BR-1); her hedef 1–100000 aralığındadır ya da yoktur (BR-2). Ağ kapalıyken ilk açılışta da liste tam görünür.
- [ ] AC-4 — "Ekle" Zikirlerim'in sonuna adı okunuşla bayt düzeyinde eşit, hedefi tablodaki hedef (hedefsiz satırda hedef yok), sayım/tur/toplam 0 olan bir zikir ekler; liste ekranı ve kaydırma konumu değişmez; seçili zikir değişmez; uygulama yeniden başlatılınca zikir yerindedir.
- [ ] AC-5 — Hedefli eklenen zikir sayaçta sayılınca hedefe ulaştığında BR-4 aynen çalışır (ör. 33. dokunuşta tur 1, sayım 0).
- [ ] AC-6 — Eklemeden sonra "Zikirlerim'e eklendi" bildirimi "Say" eylemiyle görünür; "Say" Zikirlerim'i eklenen zikir seçili, sayım 0 ve hedef tablodaki gibi açar; tesbihat seçiliyken de aynıdır ve tesbihatın ilerlemesi korunur.
- [ ] AC-7 — Aynı zikrin "Ekle"sine iki kez basılınca aynı adlı iki ayrı zikir oluşur; her biri ayrı sayılır. Ekleme sırasında ve sonrasında mevcut hiçbir zikrin sayımı, turu, toplamı, hedefi ve tesbihatın durumu değişmez.
- [ ] AC-8 — Listenin en altında kaynak satırı Requirements 9'daki metinle birebir görünür.
- [ ] AC-9 — Erişilebilirlik: satır etiketi "<okunuş>, <anlam>, <hedef>"; "Ekle" etiketi "<okunuş> Zikirlerim'e ekle"; bildirim ekran okuyucuya duyurulur; dokunma hedefleri en az 48×48 dp.

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
