# Spec 0016 — Rozetler

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0016-plan.md`
- Self-critique: done

## Intent
Kullanıcı seriyi (spec 0014) sürdürmek için görünür hedefler istiyor: belirli seri uzunluklarına ulaştıkça sabit
rozetler kazanır, kazandıklarını ve sıradaki rozete kaç gün kaldığını Geçmiş bölümünde görür. Başarı: rozetler
geçmişteki gerçek en uzun seriye göre doğru açılır, seri bozulsa da kazanılan rozet kaybolmaz, uygulama kapanıp
açılınca aynı görünür. Bilinçli olarak yapılmayan: kazanım anında duyuru/bildirim, paylaşım, puan/sıralama, toplam
sayıma dayalı rozet, kullanıcı tanımlı rozet, kazanılma tarihi ve dini ifade içeren rozet adı.
Clarify kararları D1–D7 (emryldrmr, 2026-11-13) buraya katlandı.

## Requirements
1. **Rozet seti:** sabit beş rozet vardır, şu sırayla; her biri bir seri eşiğiyle tanımlıdır:
   "İlk gün" (1 gün), "Bir hafta" (7 gün), "Bir ay" (30 gün), "100 gün" (100 gün), "Bir yıl" (365 gün).
2. **Kazanım:** bir rozet, en uzun seri (spec 0014, Requirement 5) eşiğine eşit ya da büyükse kazanılmıştır.
   En uzun seri azalmadığından kazanılan rozet seri bozulsa da kazanılmış kalır (D2). Bu sürümden önce biriken
   geçmiş de sayılır: 0014'ten beri oluşmuş seri rozetleri geriye dönük açar. Bugünden ileri tarihli günler
   (saat geri alındıysa; 0014 G1) seriye girmediği gibi rozet de kazandırmaz (G1).
3. **Sıradaki rozet:** eşiği en küçük kazanılmamış rozettir. Ona kalan gün sayısı = o rozetin eşiği − mevcut seri
   (spec 0014'teki "Seri"). Mevcut seri en uzun seriden büyük olamadığından (0014 AC-5) N her zaman en az 1'dir;
   0 ya da negatif gösterilmez (G2). Beş rozetin hepsi kazanılmışsa sıradaki rozet yoktur.
4. **Gösterim yeri:** rozetler Geçmiş bölümünde, "Seri" ve "En uzun seri" satırlarının altında, günlük listenin
   üstünde gösterilir. Yan menüye giriş eklenmez (D3).
5. **Diziliş (G3):** rozetler yatay kaydırılabilir tek bir satırdadır, sıra her zaman eşik sırasıdır (1 → 365);
   satır alt satıra kaymaz. Bölüme girişte satır, en son kazanılan rozet (eşiği en büyük kazanılmış rozet) sol
   kenarda başlayacak şekilde konumlanır (satırın sonu buna izin vermiyorsa, ör. "Bir yıl" kazanılmışsa, satır
   sona dayalı durur ve o rozet görünür kalır); hiç rozet kazanılmamışsa satır başından ("İlk gün") başlar. Ekran dışında
   kalan rozet olan her kenarda (sol ve/veya sağ) orada başka rozet olduğunu gösteren bir işaret görünür; o kenarda
   gizli rozet kalmayınca işaret kaybolur.
6. **Gösterim:** beş rozetin hepsi satırda bulunur, kaydırarak hepsine ulaşılır (D4). Kazanılmış rozet belirgin, kazanılmamış rozet soluk
   görünür ve altında şartını yazar ("7 gün seri"). Rozetlerin altında tek satır: "Sıradaki rozete N gün" (sayı
   binlik ayırıcılı, 0014 G2) ya da hepsi kazanılmışsa "Tüm rozetler kazanıldı.".
7. **Güncellik:** rozetler, Geçmiş'teki seri değerleriyle aynı anda ve aynı kaynaktan güncellenir (0014,
   Requirement 8): bölüme her girişte ve uygulama ön plana döndüğünde.
8. **Duyuru yok:** rozet kazanıldığı anda sayma ekranında ya da başka yerde hiçbir mesaj, titreşim veya bildirim
   olmaz (D5).
9. **Görsel:** her rozet adı ve uygulamanın mevcut simge setinden bir simgeyle gösterilir; yeni görsel dosyası
   eklenmez (D6). Kazanılma tarihi gösterilmez (D7).

## User experience
- **Flow:** yan menü → "Geçmiş" → seri satırları → rozetler + "Sıradaki rozete N gün" → son 30 gün listesi →
  geri tuşu Zikirlerim'e döner (0005).
- **States:**
  - *Boş (hiç sayım yok):* seri satırları 0 gün; beş rozet de kazanılmamış; "Sıradaki rozete 1 gün"; altında
    0014'teki "Henüz sayım yok." yazısı.
  - *Kısmen kazanılmış:* kazanılanlar belirgin, diğerleri soluk ve şartlı; "Sıradaki rozete N gün".
  - *Hepsi kazanılmış:* beşi belirgin; "Tüm rozetler kazanıldı.".
  - *Yükleniyor:* 0014'teki yükleniyor göstergesi; rozetler gösterilmez.
  - *Hata:* geçmiş okunamazsa 0014'teki "Geçmiş yüklenemedi." görünür; rozetler gösterilmez (yanlış bir rozet
    durumu göstermek yerine), sayma etkilenmez.
- **Design reference:** none — the flow above is the design.
- **Accessibility:** her rozet tek bir ekran okuyucu öğesidir: kazanılmışsa "Rozet: <ad>, kazanıldı", değilse
  "Rozet: <ad>, kazanılmadı, <eşik> gün seri gerekir"; kazanılmış/kazanılmamış ayrımı yalnız renge dayanmaz
  (soluk görünüm + şart metni); ekran okuyucu rozetleri eşik sırasıyla (1 → 365) okur ve ekran dışındaki rozetlere
  de ulaşır; kenar işaretleri yalnız görseldir, ayrı öğe olarak okunmaz; en büyük sistem yazı boyutunda ve 320 dp
  genişlikte rozet metni kırpılmaz (rozet uzar, satır kaydırılabilir kalır).

## Constraints & out of scope
- Sensitive area: yok — rozet adları sayısal/nötr; dini metin gösterilmez ya da değiştirilmez (D6).
- 0014'ün kriterleri geçerli kalır; Geçmiş'teki seri satırları, liste, boş/yükleniyor/hata durumları ve menü sırası
  değişmez, yalnız seri satırları ile liste arasına rozet alanı eklenir.
- Rozetler yalnız cihazdaki geçmişten türetilir; ağ, hesap, analitik yok (`docs/security.md`).
- Roadmap: `docs/architecture.md` sırasında 0015'ten sonraki madde; mimarideki sıra kaydı build'de güncellenir.
- **Clarify kararları (lite, emryldrmr, 2026-11-13):**
  D1 beş rozet: 1, 7, 30, 100, 365 gün, en uzun seriye göre · D2 kalıcı (en uzun seriye göre) · D3 Geçmiş bölümünde,
  seri satırlarının altında; yeni menü girişi yok · D4 beşi de görünür; kazanılmamış soluk + şart; "Sıradaki rozete
  N gün" · D5 kazanım anında duyuru yok · D6 nötr sayısal adlar, mevcut simge seti, yeni görsel yok · D7 kazanılma
  tarihi yok.
- **Self-critique (emryldrmr, 2026-11-13):** G1 ileri tarihli günler rozet kazandırmaz · G2 "Sıradaki rozete N gün"de N ≥ 1 · G3 (kullanıcının düzeltmesiyle)
  yatay kaydırılabilir tek satır, eşik sırası sabit, girişte en son kazanılan sol kenarda, gizli rozet olan kenarda işaret.
- **Out of scope:** kazanım duyurusu/bildirimi; paylaşım; puan, seviye, sıralama; toplam sayıma ya da zikre/tesbihata
  özel rozet; kullanıcı tanımlı rozet; kazanılma tarihi; rozetin elle kaldırılması/sıfırlanması; ayrı rozet ekranı.

## Acceptance criteria
- [x] AC-1 — Beş rozet "İlk gün" (1), "Bir hafta" (7), "Bir ay" (30), "100 gün" (100), "Bir yıl" (365) bu sırayla Geçmiş'te seri satırlarının altında, günlük listenin üstünde görünür; yan menü girişleri ve sırası 0014 AC-6 ile aynıdır.
- [x] AC-2 — Bir rozet en uzun seri eşiğine eşit ya da büyükse kazanılmış, değilse kazanılmamış görünür. (Sınırlar: en uzun seri 0, 1, 6, 7, 29, 30, 99, 100, 364, 365, 400.) Bugünden ileri tarihli günler rozet kazandırmaz (ör. yalnız ileri tarihli 7 ardışık sayımlı gün varken "Bir hafta" kazanılmamıştır).
- [x] AC-3 — Seri bozulduktan sonra (mevcut seri 0 ya da eşikten küçük) daha önce en uzun seriyle kazanılmış rozetler kazanılmış kalır; bu sürümden önce biriken geçmişteki seri rozetleri açar.
- [x] AC-4 — "Sıradaki rozete N gün": N = en küçük kazanılmamış eşik − mevcut seri (ör. seri 5, en uzun seri 40 → "Sıradaki rozete 95 gün"; seri 0, en uzun 0 → "Sıradaki rozete 1 gün"; bugün henüz sayım yok ve dünden seri 6 → "Sıradaki rozete 1 gün"); N hiçbir geçmişte 1'den küçük olmaz (G2); hepsi kazanılmışsa "Tüm rozetler kazanıldı." görünür; N binlik ayırıcılıdır.
- [x] AC-5 — Kazanılmamış rozet soluk görünür ve şartını ("<eşik> gün seri") yazar; kazanılmış rozet belirgin görünür ve şart yazmaz; kazanılma tarihi hiçbir rozette görünmez.
- [x] AC-6 — Rozetler bölüme her girişte ve uygulama ön plana döndüğünde seriyle birlikte güncellenir (ör. Geçmiş açıkken arkaya alınıp gece yarısı geçtikten sonra öne getirilince seriyle tutarlıdır).
- [x] AC-7 — Rozet kazandıran dokunuş (ör. 7. günün ilk dokunuşu) sayma ekranında hiçbir mesaj, ek titreşim ya da bildirim üretmez; dokunuşun etkisi 0014/BR-3/BR-4'teki gibidir.
- [x] AC-8 — Durumlar: hiç sayım yokken beş rozet kazanılmamış, "Sıradaki rozete 1 gün" ve "Henüz sayım yok." görünür; yüklenirken rozetler görünmez, yükleniyor göstergesi görünür; geçmiş okunamazsa rozetler görünmez, "Geçmiş yüklenemedi." görünür ve sayma çalışır.
- [x] AC-9 — Uygulama kapanıp açılınca rozetlerin kazanılmış/kazanılmamış durumu ve "Sıradaki rozete N gün" aynıdır (BR-8).
- [x] AC-10 — Erişilebilirlik: her rozet tek öğe olarak "Rozet: <ad>, kazanıldı" ya da "Rozet: <ad>, kazanılmadı, <eşik> gün seri gerekir" okunur, eşik sırasıyla ve ekran dışındakiler dahil; kenar işaretleri ayrı öğe olarak okunmaz; durum yalnız renkle ayrılmaz; en büyük yazı boyutunda ve 320 dp genişlikte rozet metni kırpılmaz; açık ve koyu temada okunur.
- [x] AC-11 — Diziliş: rozetler yatay kaydırılabilir tek satırdadır ve sıra hep 1 → 365'tir; girişte en son kazanılan rozet sol kenardadır (ör. en uzun seri 40 → "Bir ay" sol kenarda, "İlk gün" ve "Bir hafta" sola kaydırınca görünür), hiç kazanılmamışsa satır "İlk gün" ile başlar; solda ya da sağda ekran dışında rozet varsa o kenarda işaret görünür, yoksa görünmez (320 dp ve geniş ekranda).

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
| Fix rounds | 1 (fix-1: VERIFY V-1) |
| Review findings: real / noise / deferred | 1 / 2 / 1 (review round 1: 1 Low noise; VERIFY round 1: V-1 Low real, fixed in fix-1; VERIFY round 2: Q-1 Info noise, Q-2 Info → B-4) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent VERIFY round 2 (read-only QA subagent, separate from the builder), 2026-11-14 @e458456, after fix round 1; triage in `specs/plans/0016-plan.md` `## Triage` (review round 1: 1 Low noise; VERIFY round 1: V-1 Low real, fixed in fix-1; VERIFY round 2: Q-1 Info noise, Q-2 Info → B-4). Fix-1 diff (`6646735..HEAD`) read: nothing beyond V-1.
Full green: CHECK GREEN (full, 6 steps, 157 s) @65cd93d — local (393 tests; later commits change only specs/). QA's own run on a copy of HEAD: `+393: All tests passed!`. Residue: not required — `scripts/check.conf` unchanged.
Deliberate breaks in a temporary copy outside the repo (nothing committed), all red: K1 (pre-fix overlay marks → `edge marks never cover a badge in view`), K2 (`>=` → `>`, 11 red), K3 (`daysToNext` from longest, 5 red), K4 (no entry jump, 3 red), K5 (left mark never shown, 4 red). VERIFY round 1 breaks K1–K6 also all red.

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `badges_test.dart` — `five badges in order between streaks and days`; `shell_test.dart` menu order (unchanged); S01, S11 | PASS |
| AC-2 | `badges_test.dart` (domain) — `earned at and above each threshold`, `future days earn nothing`; (ui) `earned and locked follow the longest streak`; break K2 | PASS |
| AC-3 | `badges_test.dart` (domain) — `a broken streak keeps earned badges`; (ui) `history from before badges opens them`; break K2 | PASS |
| AC-4 | `badges_test.dart` (domain) — `days to next badge examples`, `days to next is never below one`; (ui) `next badge line and all earned`, `today not counted yet, six days to yesterday` (A-2: separator cannot appear, N ≤ 365); break K3; S01, S03 | PASS |
| AC-5 | `badges_test.dart` — `locked shows its condition, earned shows none, no dates`; S02, S11 | PASS |
| AC-6 | `badges_test.dart` — `badges follow the streak on resume after midnight` | PASS |
| AC-7 | `badges_test.dart` — `earning tap shows no message and no extra vibration` | PASS |
| AC-8 | `badges_test.dart` — `empty state shows five locked and next in one day`, `no badges while loading`, `no badges on load error, counting works`; S01, S04, S05, S12, S13 | PASS |
| AC-9 | `badges_test.dart` — `badges are the same after restart`; break K3 | PASS |
| AC-10 | `badges_test.dart` — `badge semantics in threshold order including off screen`, `largest text at 320 dp clips nothing`, `readable in light and dark`, `edge marks never cover a badge in view`; S06–S09 | PASS |
| AC-11 | `badges_test.dart` — `latest earned starts at the left edge`, `nothing earned starts with İlk gün`, `all earned rests at the end`, `edge marks follow hidden badges at 320 dp and wide`, `edge marks never cover a badge in view`; breaks K1, K4, K5; S02, S06, S09, S10, S11 | PASS |

UI: S01 empty light · S02 partial (longest 40, streak 5) · S03 all earned · S04 loading · S05 error light · S06 dark entry, latest earned at the left edge · S07 320 dp 2× light · S08 320 dp 2× dark · S09 320 dp 2× all earned dark · S10 320 dp both marks · S11 wide 1200 dp, no marks · S12 empty dark · S13 error dark — agent-captured (headless widget render, Roboto + Material icons), outside the repo; judged by emryldrmr at SHIP, 2026-11-14.
