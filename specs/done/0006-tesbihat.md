# Spec 0006 — Namaz sonrası tesbihat

- Status: Shipped
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
- [x] AC-1 — Seçicinin en üstünde "Namaz sonrası tesbihat" satırı vardır (düzenle simgesi yok), altında kullanıcının zikirleri eklenme sırasıyla; seçilince cihazın üstünde "Namaz sonrası tesbihat", cihazda "Sübhânallah", "Adım 1/3", sayım 0, "Hedef 33", "Tamamlanan 0" görünür; "Tur" ve "Toplam" ile hedef butonu görünmez. Yeni kurulumda ve mevcut kurulumda açılışta seçili olan zikir değişmez (tesbihat ancak seçilince açılır).
- [x] AC-2 — Adımların metni, sırası ve hedefleri Requirements 1'deki tabloyla birebir aynıdır (ekrandaki metin tablodaki metinle bayt düzeyinde eşit, BR-12).
- [x] AC-3 — Her dokunuş adımın sayımını 1 artırır; 32. dokunuşta adım değişmez; 33. dokunuşta titreşim olur ve "Elhamdülillâh", "Adım 2/3", sayım 0 görünür; 2. adımdan 3. adıma geçiş aynıdır. Titreşim kapalıysa geçiş aynen olur, titreşim olmaz.
- [x] AC-4 — 3. adımın 33. dokunuşunda titreşim olur, "Tesbihat tamamlandı" ve "Tamamlanan 1" görünür; bu durumda dokunuş hiçbir değeri değiştirmez; "Baştan başla" 1. adımı sayım 0 ile açar, "Tamamlanan" 1 kalır; ikinci tamamlanma "Tamamlanan 2" yapar.
- [x] AC-5 — Geri al adım içinde sayımı 1 azaltır; adımın sayımı 0 iken (2. adımın başı dahil) hiçbir şey değişmez ve önceki adıma dönülmez; tamamlandı durumunda geri al yoktur.
- [x] AC-6 — Sıfırla onay sorar; "Sıfırla" 1. adımı sayım 0 ile açar ve "Tamamlanan" değişmez; "Vazgeç" hiçbir şeyi değiştirmez.
- [x] AC-7 — Uygulama yeniden başlatılınca (aynı kalıcı depoyla) tesbihat seçili açılır ve adımı, sayımı, tamamlandı durumu ve "Tamamlanan" sayısı aynen görünür.
- [x] AC-8 — Tesbihat sayılırken, sıfırlanırken ve tamamlanırken hiçbir zikrin sayımı, turu, toplamı ya da hedefi değişmez; zikirden tesbihata ve geri geçişte her ikisi kendi değerlerini korur.
- [x] AC-9 — Boş durumda "Tesbihat çek" butonu tesbihatı açar; tesbihattan seçiciye dönülerek "Yeni zikir" eklenebilir.
- [x] AC-10 — Erişilebilirlik: adım etiketi "<metin>, adım n/3, <sayım> / 33"; adım geçişinde "<yeni metin>, adım n/3" ve "Tesbihat tamamlandı" ekran okuyucuya duyurulur; seçicideki tesbihat satırı seçiliyse seçili bildirilir; dokunma hedefleri en az 48×48 dp.

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
| Fix rounds | 1 (fix-1: F-1, F-2, F-3) |
| Review findings: real / noise / deferred | 3 / 0 / 1 (1 Medium, 2 Low, 1 Info; F-4 → B-2) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent VERIFY (QA subagent, separate from the builder), 2026-11-07, @ea7e94f; triage in the plan's `## Triage` (round 1: F-1…F-3 fixed in fix-1, F-4 → B-2; round 2 clean).
Full green: CHECK GREEN (full, 6 steps, 262 s) @9858e23 — https://github.com/emryldrmr/zikirmatik/actions/runs/42292808622
(169 tests; HEAD differs only in specs/). Sensitive area: 37 deliberate breaks in a temporary copy outside the repo (nothing committed), at least one per criterion; every one turned its test red. No gaps.

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `tesbihat_test.dart` — `picker shows the tesbihat row first without an edit button`, `choosing the tesbihat shows step 1 of 3 without total, rounds or target button`, `the selection at launch is unchanged`; breaks K1a–K1d; S-1, S-2 | PASS |
| AC-2 | `tesbihat_text_test.dart` — `the steps match the source table byte for byte`; `tesbihat_test.dart` — `each step's text on screen equals the stored text`; breaks K2a (NFD "â"), K2a' (integrity test alone), K2b (target 34), K2c (order), K2d (trailing space), K2e (shown uppercased), K2f ("â" → "a"); S-2, S-3, S-4 | PASS |
| AC-3 | `tesbihat_state_test.dart` — `32 taps stay on the step, the 33rd moves on and signals vibration`; `tesbihat_test.dart` — `step changes vibrate once`, `with vibration off the step still changes`, `a tap during a slow vibration is stored in order`, `a failing vibration does not stop the step change`; breaks K3a (`<=`), K3b (target − 1), K3c–K3e; S-3, S-4 | PASS |
| AC-4 | `tesbihat_state_test.dart` — `the last step completes and counts the completion`, `taps after completion change nothing`; `tesbihat_test.dart` — `completion shows the finished state and restart begins again`; breaks K4a–K4d; S-5 | PASS |
| AC-5 | `tesbihat_state_test.dart` — `undo stays within the step`; `tesbihat_test.dart` — `undo is hidden when finished`; breaks K5a–K5c; S-2, S-5 | PASS |
| AC-6 | `tesbihat_test.dart` — `reset asks and keeps the completed count`, `reset cancel changes nothing`; breaks K6a, K6b (K4c); S-6 | PASS |
| AC-7 | `drift_tesbihat_repository_test.dart` — `progress and selection survive reopening`, `migrates a v4 database and keeps dhikrs and settings`; `tesbihat_test.dart` — `restart opens the tesbihat where it was`; breaks K7a–K7d | PASS |
| AC-8 | `tesbihat_test.dart` — `counting the tesbihat changes no dhikr`, `switching keeps both values`; breaks K8a–K8c | PASS |
| AC-9 | `tesbihat_test.dart` — `the empty state opens the tesbihat`, `adding a dhikr from the tesbihat selects it`; breaks K9a, K9b; S-7 | PASS |
| AC-10 | `tesbihat_test.dart` — `step semantics, live announcements and touch targets`; breaks K10a–K10e | PASS |

UI: S-1 picker with the tesbihat row · S-2 step 1 · S-3 step 2 after the 33rd tap · S-4 step 3 · S-5 finished · S-6 reset confirmation · S-7 empty state with "Tesbihat çek" — agent-captured (headless widget render, Roboto + Material icons), outside the repo; ship approved by emryldrmr. Manual run on a phone (Android 16, installed over the v4 data) passed, emryldrmr, 2026-11-07.
