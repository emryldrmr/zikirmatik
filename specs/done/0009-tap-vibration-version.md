# Spec 0009 — Her sayımda titreşim ve uygulama sürümü

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0009-plan.md`
- Self-critique: done

## Intent
Ürün sahibi, kullanıcının her dokunuşta kısa bir titreşimle sayımı hissedebilmesini istiyor (ekrana
bakmadan, cebinde ya da karanlıkta sayarken). Bu, Ayarlar'da ayrı bir aç/kapa olur; mevcut "tur
tamamlanınca titreşim" ayarından bağımsızdır ve yeni kurulumda kapalıdır. Ayrıca yan menünün en altında
uygulamanın sürümü görünür, kullanıcı hangi sürümü kullandığını görebilsin (geri bildirimde,
güncellemeden sonra). Başarı: ayar açıkken her sayım kısa titreşir, kapalıyken davranış bugünküyle
aynıdır; menüde doğru sürüm yazar. Bilinçli olarak yapılmayan: titreşim şiddeti/süresi seçimi, belirli
sayılarda (ör. 33'te) ara titreşim. Dini metin içermez; hassas alanın dışındadır.

## Requirements
1. Ayarlar ekranında yeni bir "Her sayımda titreşim" aç/kapa ayarı vardır; yeni kurulumda ve bu sürüme
   güncellenen kurulumda kapalıdır. Mevcut ayarlar (titreşim, tema) güncellemede korunur.
2. Ayar açıkken sayımı 1 artıran her dokunuş kısa bir titreşim verir: Zikirlerim'deki sayaçta ve
   tesbihatta. Geri al, sıfırla ve tamamlanmış tesbihata dokunuş (sayım artmaz) titreşmez.
3. Bir dokunuş aynı anda turu tamamlıyorsa (BR-4, BR-13) ve "Titreşim" (tur) ayarı açıksa yalnızca tur
   titreşimi olur — iki titreşim üst üste gelmez. Tur ayarı kapalı, her sayım ayarı açıksa o dokunuş da
   kısa titreşir.
4. Ayar kapalıyken davranış spec 0004'teki gibidir; iki ayar birbirini değiştirmez.
5. Ayar kalıcıdır; okunamazsa kapalı kabul edilir (spec 0004, Req. 6 ile aynı tutum).
6. Titreşim verilemezse (cihaz desteklemiyor, hata) sayım yine de artar ve hata gösterilmez.
7. Yan menünün en altında uygulamanın kurulu sürümü "Sürüm 1.0.0" biçiminde görünür (yalnızca sürüm
   adı; yapı numarası yok). Sürüm okunamazsa satır görünmez, menü çalışmaya devam eder.

## User experience
- **Flow:** Yan menü → "Ayarlar" → "Her sayımda titreşim" anahtarını aç → Zikirlerim → her dokunuşta
  kısa titreşim → hedefe ulaşan dokunuşta tek (tur) titreşimi → Ayarlar → anahtarı kapat → dokunuşlar
  titreşimsiz. Yan menüyü aç → en altta "Sürüm 1.0.0".
- **States:**
  - *Ayarlar ekranı:* "Titreşim" satırının hemen altında "Her sayımda titreşim" satırı (alt metin "Her
    dokunuşta kısa titreşir", sağda anahtar); geri kalan ekran spec 0004'teki gibi.
  - *Yan menü:* mevcut beş giriş aynen; en altta, girişlerden ayrık, küçük ve soluk metinle sürüm satırı.
    Girişler ekrana sığmazsa sürüm satırı kaydırmayla erişilir, girişlerin üstüne binmez.
  - *Sürüm okunamadı:* sürüm satırı yok; menü aynen çalışır.
  - *Ayar okunamadı:* hata yok; "Her sayımda titreşim" kapalı görünür ve uygulanır.
- **Design reference:** none — the flow above is the design.
- **Accessibility:** anahtarın etiketi "Her sayımda titreşim" ve açık/kapalı durumu ekran okuyucuya
  bildirilir; anahtarın dokunma hedefi en az 48×48 dp; sürüm metni ekran okuyucuda "Sürüm 1.0.0" okunur,
  dokunulabilir değildir; iki temada da metin kontrastı en az 4.5:1.

## Constraints & out of scope
- Spec 0004'ün kriterleri aynen geçerlidir; "Titreşim" satırının alt metni ("Tur tamamlanınca
  titreşir") değişmez. 0002 AC-4, BR-4 ve BR-13 tur titreşimi için aynen geçerlidir.
- Sıra ve kapsam (emryldrmr, 2026-11-07): `docs/architecture.md` "Sürüm 1 kapsamı"nda kalan sıra bu
  spec'in dalında güncellenir; planlanan "ara titreşim" maddesi bu spec'le karşılanmış sayılır.
- Self-critique G1–G6 (emryldrmr, 2026-11-07): varsayılan kapalı; sayaç + tesbihat; tur dokunuşunda tek titreşim; okuma hatasında kapalı; "Sürüm x.y.z", okunamazsa gizli; ara titreşim bu spec’le karşılanır. Split: değerlendirildi, bölünmedi — emryldrmr, iki küçük yetenek.
- **Out of scope:** titreşim şiddeti/süresi/deseni seçimi; belirli sayılarda ara titreşim; ses (tık
  sesi); ayar kaydetme hatasının bildirilmesi (B-2); menüde lisans/hakkında sayfası.

## Acceptance criteria
- [x] AC-1 — Ayarlar ekranında "Titreşim"in altında "Her sayımda titreşim" anahtarı görünür; yeni kurulumda kapalıdır. Önceki sürümden güncellenen veritabanında mevcut titreşim ve tema değerleri korunur, yeni ayar kapalıdır.
- [x] AC-2 — Ayar açıkken Zikirlerim'de sayımı artıran her dokunuş bir kısa titreşim tetikler; ayar kapalıyken hiçbir dokunuş kısa titreşim tetiklemez.
- [x] AC-3 — Ayar açıkken tesbihatta sayımı artıran her dokunuş kısa titreşim tetikler; tamamlanmış tesbihata dokunuş titreşim tetiklemez.
- [x] AC-4 — Her sayım ve tur ayarı ikisi de açıkken turu tamamlayan dokunuş (sayaçta ve tesbihatta) yalnızca bir tur titreşimi tetikler; tur ayarı kapalı, her sayım ayarı açıkken aynı dokunuş bir kısa titreşim tetikler.
- [x] AC-5 — Geri al ve sıfırla, ayar açıkken de titreşim tetiklemez.
- [x] AC-6 — Ayar, uygulama yeniden başlatılınca (aynı kalıcı depoyla) aynen görünür ve uygulanır; ayarlar okunamazsa hata gösterilmez ve ayar kapalı kabul edilir.
- [x] AC-7 — Titreşim hata verirse sayım yine 1 artar ve hata gösterilmez.
- [x] AC-8 — Yan menünün en altında kurulu sürüm "Sürüm <sürüm adı>" olarak görünür (pubspec'teki 1.0.0 için "Sürüm 1.0.0"); sürüm okunamazsa satır görünmez ve beş giriş aynen çalışır.
- [x] AC-9 — Erişilebilirlik: anahtar "Her sayımda titreşim" etiketiyle ve açık/kapalı durumuyla bildirilir, dokunma hedefi en az 48×48 dp; sürüm satırı "Sürüm 1.0.0" okunur; Ayarlar ve yan menüdeki yeni metinlerin kontrastı Açık ve Koyu temada en az 4.5:1.

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
| Fix rounds | 0 |
| Review findings: real / noise / deferred | 0 / 0 / 0 (one-pass review clean) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
One-pass review (independent reviewer subagent, REVIEW + VERIFY), 2026-11-07, @109ee4c; triage confirmed the clean verdict.
Full green: CHECK GREEN (full, 6 steps, 338 s) @7b0b6f5 — https://github.com/emryldrmr/zikirmatik/actions/runs/42400573470
(later commits touch `specs/` only). No deliberate breaks required (outside the sensitive area; no concurrency, money, authorization or boundary criterion).

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `tap_vibration_test.dart` — `settings shows tap vibration off by default`; `drift_settings_repository_test.dart` — `migrates a v5 database and keeps the settings`; `app_settings_test.dart` — `vibration per count is off by default and changes alone` | PASS |
| AC-2 | `tap_vibration_test.dart` — `tap vibration on vibrates every counted tap`, `tap vibration off never tap-vibrates` | PASS |
| AC-3 | `tap_vibration_test.dart` — `tesbihat taps vibrate and a finished tesbihat does not` | PASS |
| AC-4 | `tap_vibration_test.dart` — `a round-completing tap vibrates once`, `round off and tap on gives a short vibration`, `a step change with round vibration off is a short one` | PASS |
| AC-5 | `tap_vibration_test.dart` — `undo and reset never vibrate` | PASS |
| AC-6 | `drift_settings_repository_test.dart` — `tap vibration survives reopening`; `tap_vibration_test.dart` — `turning it on applies at once and is kept after restart`, `unreadable settings mean tap vibration off`, `unreadable settings show tap vibration off` | PASS |
| AC-7 | `tap_vibration_test.dart` — `a failing tap vibration still counts` | PASS |
| AC-8 | `shell_test.dart` — `menu shows the app version at the bottom`, `the shown version matches pubspec`, `no version row when the version is unreadable` | PASS |
| AC-9 | `tap_vibration_test.dart` — `tap vibration semantics, target and contrast`; `shell_test.dart` — `version row semantics and contrast` | PASS |

UI: no screenshots this round (owner's choice); judged on a phone (Xiaomi, Android 16) by emryldrmr at SHIP, 2026-11-07 — settings row, vibration feel (light per tap, heavy per round), version row "Sürüm 1.0.0".
