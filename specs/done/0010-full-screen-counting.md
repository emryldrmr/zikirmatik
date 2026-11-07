# Spec 0010 — Tam ekran sayma ve ekranı açık tut

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0010-plan.md`
- Self-critique: done

## Intent
Kullanıcı, ekrana bakmadan ve telefonu elinde rahatça tutarak uzun süre zikir çekmek istiyor. Sayaç
ekranından açılan bir tam ekran sayma modu gelir: ekranın her yerine dokunmak sayar, küçük bir düğmeyi
aramak gerekmez. Ayarlar'a "Ekranı açık tut" eklenir; uzun tesbihatta ekran kararmaz. Başarı: tam ekranda
her dokunuş bugünkü sayaçla aynı kurallarla sayar (BR-3, BR-4, BR-5, BR-13, titreşim ayarları), ayar
açıkken Zikirlerim'de ekran sönmez. Bilinçli olarak yapılmayan: ses tuşuyla sayma (0011), büyük rakam ve
sol/sağ el yerleşimi (0012); tam ekranda sıfırlama ve hedef değiştirme.

## Requirements
1. Zikirlerim'de bir zikir ya da tesbihat seçiliyken sayaç ekranında bir "Tam ekran" düğmesi vardır.
   Zikir yokken (boş durum), sayaç yüklenirken ya da yüklenemediğinde bu düğme yoktur.
2. Tam ekran açılınca sistem çubukları (durum ve gezinme çubuğu) gizlenir. Ekranın tamamı dokunma
   alanıdır; yalnızca "Geri al" ve "Kapat" düğmeleri kendi işini yapar.
3. Tam ekranda dokunma alanına her dokunuş, normal ekrandaki sayma düğmesine dokunuşla aynı etkiyi
   yapar: sayım ve toplam 1 artar (BR-3), hedefe ulaşınca tur tamamlanır (BR-4), tesbihatta adım
   ilerler (BR-13), titreşim ayarları (spec 0004, 0009) aynen uygulanır, durum kalıcı saklanır (BR-8).
   Hızlı ardışık dokunuşların hiçbiri kaybolmaz; çift dokunma gibi hareketler ayrıca algılanmaz.
   Aynı anda ekrana değen ikinci bir parmak ayrı sayım yapmaz.
4. Tam ekranda zikir için zikrin adı, sayım, hedef ve tur (hedef yoksa "Hedef yok") ve toplam görünür.
   Tesbihat için adımın zikir metni, "Adım x/y", sayım ve hedef görünür; tesbihat tamamlanınca
   "Tesbihat tamamlandı" görünür ve dokunuşlar saymaz (spec 0006).
5. Tam ekrandaki "Geri al", normal ekrandaki geri al ile aynıdır (BR-5; tesbihatta spec 0006'daki
   gibi). Sayım 0 iken pasiftir. Tam ekranda sıfırlama, hedef değiştirme ve zikir seçme yoktur.
6. "Kapat" düğmesi ya da sistemin geri tuşu/hareketi tam ekrandan çıkar: normal sayaç ekranı aynı
   değerlerle görünür, sistem çubukları geri gelir. Uygulama arka plana alınıp geri dönülünce tam ekran
   sürer ve sistem çubukları yine gizlidir.
7. Ayarlar ekranında "Her sayımda titreşim"in altında yeni bir "Ekranı açık tut" aç/kapa ayarı vardır;
   yeni kurulumda ve bu sürüme güncellenen kurulumda kapalıdır. Mevcut ayarlar güncellemede korunur.
   Ayar kalıcıdır; okunamazsa kapalı kabul edilir (spec 0004, Req. 6 ile aynı tutum).
8. "Ekranı açık tut" açıkken Zikirlerim ekranı (normal ya da tam ekran; zikir, tesbihat ya da boş
   durum) öndeyken ekran kendiliğinden kararmaz. Başka bir ekrana geçilince ya da uygulama arka plana
   alınınca sistemin olağan davranışı geri gelir. Ayar kapalıyken uygulama ekranın kararmasına hiç
   karışmaz.

## User experience
- **Flow:** Zikirlerim → "Tam ekran" düğmesi → ekranın herhangi bir yerine dokunarak say → yanlış
  dokunuşta köşedeki "Geri al" → "Kapat" ya da geri hareketi → normal sayaç aynı değerlerle. Yan menü →
  "Ayarlar" → "Ekranı açık tut"u aç → Zikirlerim'de ekran kararmaz.
- **States:**
  - *Sayaç ekranı (zikir / tesbihat):* bugünkü gibi; ek olarak bir "Tam ekran" düğmesi.
  - *Boş durum, yükleniyor, yüklenemedi:* bugünkü gibi; "Tam ekran" düğmesi yok.
  - *Tam ekran — zikir:* sistem çubukları yok; ortada büyük sayım; üstünde zikir adı; altında hedef/tur
    ve toplam; bir köşede "Geri al", karşı köşede "Kapat".
  - *Tam ekran — zikir, sayım 0:* "Geri al" pasif görünür.
  - *Tam ekran — tesbihat:* adımın zikir metni (tamamı, değiştirilmeden), "Adım x/y", sayım / hedef;
    "Geri al" ve "Kapat" köşelerde.
  - *Tam ekran — tesbihat tamamlandı:* "Tesbihat tamamlandı"; dokunuşlar saymaz; "Kapat" çalışır.
  - *Ayarlar:* "Her sayımda titreşim" satırının altında "Ekranı açık tut" satırı (alt metin "Zikirlerim
    açıkken ekran kararmaz", sağda anahtar); geri kalan ekran bugünkü gibi.
  - *Ayar okunamadı:* hata yok; "Ekranı açık tut" kapalı görünür ve uygulanır.
- **Design reference:** none — the flow above is the design.
- **Accessibility:** "Tam ekran", "Geri al" ve "Kapat" düğmeleri ekran okuyucuda bu adlarla
  okunur, dokunma hedefleri en az 48×48 dp. Tam ekran dokunma alanı normal sayma düğmesiyle aynı
  biçimde okunur ("Sayım {n}. Saymak için dokunun."; tesbihatta spec 0006'daki adım bildirimi). Anahtar
  "Ekranı açık tut" etiketiyle ve açık/kapalı durumuyla bildirilir. Yeni metinlerin kontrastı Açık ve
  Koyu temada en az 4.5:1.

## Constraints & out of scope
- Sensitive area: Dini metin bütünlüğü — tam ekran, tesbihat adımının zikir metnini yeni bir yerde
  gösterir; metin spec 0006'daki haliyle, kırpılmadan ve değiştirilmeden gösterilir (BR-12). Metin
  sığmazsa yazı küçülür ya da kaydırılır; asla "…" ile kesilmez. Zikir adı kullanıcının metnidir,
  bu kurala tabi değildir (normal ekrandaki gibi tek satır, sığmazsa "…").
- Spec 0002, 0003, 0004, 0006 ve 0009'un kriterleri normal ekranda aynen geçerlidir.
- Bölme (emryldrmr, 2026-11-07): "sayma kolaylıkları" üçe bölündü — 0010 tam ekran + ekranı açık tut,
  0011 ses tuşuyla sayma, 0012 görünüm seçenekleri (büyük rakam, sol/sağ el). `docs/architecture.md`
  "Sürüm 1 kapsamı"ndaki kalan sıra bu spec'in dalında güncellenir (sonraki maddeler ikişer kayar).
- Clarify S1–S4 (emryldrmr, 2026-11-07): üçe bölme; tam ekran sayaç ekranındaki düğmeyle açılan ayrı
  bir mod (Ayarlar seçeneği değil); tam ekranda yalnız Geri al ve Kapat; "Ekranı açık tut" Ayarlar'da,
  varsayılan kapalı, yalnız Zikirlerim'de etkili.
- Self-critique G1–G7 (emryldrmr, 2026-11-07): hassas alan işaretli, tesbihat metni tam ekranda
  değiştirilmeden ve kesilmeden; aynı anda iki parmak = 1 sayım; hızlı dokunuş kaybolmaz; arka plandan
  dönünce tam ekran sürer, yeniden başlatınca normal ekran; "Ekranı açık tut" Zikirlerim'in her
  durumunda (yan menü açıkken dahil); tam ekranda "Baştan başla" yok. Split: 10 kriter, tek kullanım
  amacı — bölünmedi, emryldrmr.
- **Out of scope:** ses tuşuyla sayma (0011); büyük rakam, sol/sağ el yerleşimi (0012); tam ekranda
  sıfırlama, hedef değiştirme, zikir seçme, tesbihatı baştan başlatma; ekran parlaklığını kısma;
  uygulamanın tam ekranda açılması/hatırlanması (yeniden başlatınca normal ekran açılır); ayar kaydetme
  hatasının bildirilmesi (B-2).

## Acceptance criteria
- [x] AC-1 — Seçili zikirde ve tesbihatta sayaç ekranında "Tam ekran" düğmesi görünür; boş durumda, yüklenirken ve yükleme hatasında görünmez.
- [x] AC-2 — Tam ekranda sistem çubukları gizlidir; zikir için ad, sayım, hedef/tur (hedefsizde "Hedef yok") ve toplam görünür.
- [x] AC-3 — Tam ekranda Geri al ve Kapat dışında ekranın herhangi bir noktasına (dört köşe yakını ve orta dahil) dokunuş sayımı ve toplamı 1 artırır; hedefte tur tamamlanır ve sayım 0 olur (BR-4); art arda 10 hızlı dokunuş 10 sayar; aynı anda iki parmak 1 sayar; değerler yeniden başlatınca korunur.
- [x] AC-4 — Tam ekrandaki dokunuşlarda titreşim kuralları normal ekrandakiyle aynıdır (tur titreşimi, her sayımda titreşim, tur dokunuşunda tek titreşim — spec 0009 AC-2…AC-4).
- [x] AC-5 — Tesbihat tam ekranda adımın zikir metnini spec 0006'daki metinle birebir aynı ve kırpılmadan, "Adım x/y" ve sayım/hedefi gösterir; adım hedefinde sıradaki adıma geçer (BR-13); tamamlanınca "Tesbihat tamamlandı" görünür ve dokunuşlar saymaz.
- [x] AC-6 — Tam ekrandaki "Geri al" sayımı ve toplamı 1 azaltır, sayım 0'da pasiftir; "Geri al" ve "Kapat" dokunuşları sayım yapmaz; tam ekranda sıfırla, hedef ve zikir seçici yoktur.
- [x] AC-7 — "Kapat" ve sistem geri hareketi tam ekrandan çıkarır: normal sayaç aynı değerlerle görünür, sistem çubukları geri gelir; arka plandan dönünce tam ekran sürer, çubuklar gizlidir.
- [x] AC-8 — Ayarlar'da "Her sayımda titreşim"in altında "Ekranı açık tut" anahtarı görünür; yeni kurulumda kapalıdır; önceki sürümden güncellenen veritabanında mevcut ayarlar korunur, yeni ayar kapalıdır; ayar yeniden başlatınca korunur; ayarlar okunamazsa hata gösterilmez ve kapalı kabul edilir.
- [x] AC-9 — Ayar açıkken Zikirlerim (normal, tam ekran, boş durum) öndeyken ekranı açık tutma etkindir; başka ekrana geçince ve arka plana alınınca bırakılır, geri dönünce yeniden etkinleşir; ayar kapalıyken hiçbir zaman etkin değildir; ayarı değiştirmek hemen uygulanır.
- [x] AC-10 — Erişilebilirlik: "Tam ekran", "Geri al", "Kapat" ve "Ekranı açık tut" bu etiketlerle (anahtar açık/kapalı durumuyla) bildirilir, dokunma hedefleri en az 48×48 dp; tam ekran dokunma alanı normal sayma düğmesinin etiketiyle okunur; yeni metinlerin kontrastı Açık ve Koyu temada en az 4.5:1.

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
| Fix rounds | 4 (R-06 before the 4th: continue) |
| Review findings: real / noise / deferred | 4 / 0 / 0 (F-1 round 1, S-1 phone check, F-1 round 3, V-1 verify) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent QA subagent, three VERIFY rounds; final round 2026-11-07 @a30053b. Reviews: four independent reviewer rounds (plain — sensitive area); triage in `specs/plans/0010-plan.md` `## Triage`.
Full green: CI https://github.com/emryldrmr/zikirmatik/actions/runs/42408084378 @81cca7c (later commits touch `specs/` only); local CHECK GREEN (full, 6 steps, 113 s) @29838a6.
Deliberate breaks (temporary clone outside the repo, all red): B1 step text char change, B2/B-AC5 maxLines+ellipsis, B3 F-1 layout (AC-5); B4 two fingers count twice, B5a cancel flag removed, B5b cancel counts, B11–B13 swipe check removed / last position / `>=` (AC-3); B6 undo at 0, B7 tap area over buttons (AC-6); B8 no release in background, B9 no release on dispose (AC-9).

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `full_screen_test.dart` — `full screen button on dhikr and tesbihat`, `no full screen button when empty, loading or failed`; S-01, S-02, S-08, S-09, S-10 | PASS |
| AC-2 | `full_screen_test.dart` — `full screen hides the bars and shows the dhikr`, `full screen without a target says no target`; S-03; phone T-1 | PASS |
| AC-3 | `full_screen_test.dart` — `a tap anywhere counts`, `ten fast taps count ten`, `two fingers count once`, `a cancelled touch does not count`, `a swipe does not count`, `full screen reaches the target and keeps it after restart`; breaks B4, B5a, B5b, B11–B13; phone T-2 | PASS |
| AC-4 | `full_screen_test.dart` — `full screen taps follow the vibration settings` | PASS |
| AC-5 | `tesbihat_text_test.dart` — `full screen shows the step text unchanged`, `full screen step text stays readable sideways and large`; `full_screen_test.dart` — `tesbihat full screen steps and finishes`, `full screen fits sideways with large text`; breaks B1, B2, B3; S-05, S-06 | PASS |
| AC-6 | `full_screen_test.dart` — `full screen undo`, `undo and close do not count`, `no reset, target or picker in full screen`; breaks B6, B7; S-04 | PASS |
| AC-7 | `full_screen_test.dart` — `close and back leave full screen with the same values`, `full screen hides the bars again on resume`; phone T-1, T-2 | PASS |
| AC-8 | `keep_screen_on_test.dart` — `keep screen on is off by default`, `unreadable settings mean keep screen on off`, `turning it on applies at once and is kept after restart`; `drift_settings_repository_test.dart` — `migrates a v6 database and keeps the settings`, `keep screen on survives reopening`; S-07, S-07b, S-11 | PASS |
| AC-9 | `keep_screen_on_test.dart` — `keep screen on holds on my dhikrs and full screen`, `keep screen on holds in the empty state`, `released on other sections and in background`, `never on when the setting is off`; breaks B8, B9; phone T-3 | PASS |
| AC-10 | `full_screen_test.dart` — `full screen semantics, targets and contrast`; `keep_screen_on_test.dart` — `keep screen on semantics, target and contrast` | PASS |

UI: S-1…S-12 agent-captured (S-01…S-11, S-07b), judged by emryldrmr at SHIP, 2026-11-07.
Phone (Xiaomi, Android 16) by emryldrmr, 2026-11-07: T-1 system bars hide/return/resume and T-3 keep screen on (Zikirlerim stays lit, Ayarlar dims) OK @9b93070; T-2 back gesture closes without counting, bottom-bar pull no longer counts OK @01f8401 (S-1 fixed); update kept dhikrs and settings (v6 → v7).
