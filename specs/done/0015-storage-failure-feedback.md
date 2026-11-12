# Spec 0015 — Depolama hatası geri bildirimi

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0015-plan.md`
- Self-critique: done

## Intent
Cihazda saklama başarısız olduğunda kullanıcı bugün bunu görmüyor: ekran değişikliği başarılı
gösteriyor, uygulama yeniden açılınca değişiklik geri geliyor ya da kayboluyor (backlog B-2). Kullanıcı
bir değişikliğin kaydedilemediğini o an, kısa ve sakin bir mesajla öğrenmeli; ekran da ya kayıtlı olanı
gösterir ya da kaybolabilecek olanı açıkça söyler. Başarı: hiçbir yazma hatası sessiz kalmaz, sayma
hiçbir hatada durmaz. Hatanın nedenini gidermek (depolama onarımı, yeniden deneme düğmesi, hata
raporlama) yapılmaz.

## Requirements
1. Kullanıcının yaptığı ve kalıcı saklanan her değişiklik bu spec'in kapsamındadır: sayaç (sayım artıran
   dokunuş, geri al, sıfırla), Zikirlerim (ekle — Önerilen Zikirler ve Esma'dan ekleme dahil —, seç,
   başka bölümden açma, yeniden adlandır, sil), tesbihat (başlat, dokunuş, geri al, sıfırla), Ayarlar'daki
   her seçenek ve günlük sayım (spec 0014).
2. **Sayma grubu** (sayaç, tesbihat, Ayarlar, günlük sayım): yazma başarısız olursa ekran yeni değeri
   göstermeye devam eder, sayma sürer ve "kaydedilemedi, kaybolabilir" mesajı görünür. Sonraki başarılı
   kayıt ekranda görüneni saklar.
3. **Liste grubu** (Zikirlerim işlemleri): yazma başarısız olursa ekran işlemden önceki hâline döner (silinen
   zikir geri gelir, eski ad ve eski seçim görünür) ve "kaydedilemedi" mesajı görünür. Yalnız başarısız
   işlemin etkisi geri alınır; kullanıcının arada yaptığı başka işlemler korunur.
4. Ekle başarısız olursa form açık kalır, girilen ad ve hedef korunur, mesaj görünür; kullanıcı yeniden
   deneyebilir. Önerilen Zikirler/Esma'dan ekleme başarısızsa satırda "eklendi" durumu görünmez.
5. Mesaj görünürken yeni hatalar mesajı çoğaltmaz; mesaj kapandıktan sonraki ilk yeni hata yeniden gösterir.
6. Tesbihat kaydı okunamazsa "Tesbihat çek" sessiz kalmaz: "Tesbihat yüklenemedi." mesajı görünür ve
   tesbihat açılmaz; zikir sayacı kullanılmaya devam eder.
7. Mesaj, tam ekran sayma (spec 0010) dahil sayacın görünebildiği her ekranda görünür, yaklaşık 4 saniye sonra
   kendiliğinden kapanır, sayma dokunuşunu hiçbir ekranda engellemez; hata kodu ya da teknik ayrıntı göstermez.

## User experience
- Flow: kullanıcı bir değişiklik yapar → kayıt başarısızsa ekranın altında kısa bir mesaj belirir → birkaç
  saniye sonra kendiliğinden kapanır; kullanıcı bir şey yapmak zorunda değildir.
- States:
  - Başarılı kayıt: bugünkü davranış, mesaj yok.
  - Sayma grubu hatası: değer ekranda kalır + "Kaydedilemedi. Bu değişiklik uygulama kapanınca kaybolabilir."
  - Liste grubu hatası: ekran eski hâle döner + "Kaydedilemedi."
  - Ekle hatası: form açık, girdi korunmuş + "Kaydedilemedi."
  - Tesbihat okunamadı: "Tesbihat yüklenemedi.", tesbihat açılmaz.
- Design reference: none — the flow above is the design (uygulamadaki mevcut kısa mesaj görünümü kullanılır;
  yeni görsel uydurulmaz).
- Accessibility: mesaj ekran okuyucu tarafından kendiliğinden okunur; en büyük sistem yazı boyutunda
  kırpılmaz; sayaç düğmesini örtmez.

## Constraints & out of scope
- Sensitive area: yok — dini metin gösterilmez ya da değiştirilmez.
- B-2'yi kapatır (`specs/backlog.md` girişi bu işin commit'inde silinir).
- Spec 0001–0014'ün kriterleri geçerli kalır; yalnız kayıt başarısız olduğunda olanlar bu spec'le tanımlanır.
- Kapsam dışı: yeniden deneme düğmesi; hatanın nedenini gösterme ya da giderme; açılışta Ayarlar okunamazsa
  varsayılanlara dönme davranışı (bugünkü gibi kalır); sayaç / zikir listesi / geçmiş okunamadığında
  zaten var olan "yüklenemedi" ekranları; hata kaydı, analitik, crash raporlama (`docs/security.md`).
- **Clarify kararları (lite, emryldrmr, 2026-11-11):**
  D1 kapsam = kalıcı saklanan her kullanıcı işlemi (sayaç, Zikirlerim, tesbihat, Ayarlar, günlük sayım), tek tip
  geri bildirim · D2 sayma grubu ekranda kalır + "kaybolabilir" (her kayıt tam durumu yazar, sonraki başarılı kayıt
  açığı kapatır); liste grubu eski hâline döner · D3 ekle başarısızsa form açık, girdi korunur · D4 mesaj görünürken
  çoğalmaz · D5 kendiliğinden kapanan kısa mesaj, yeniden deneme düğmesi yok · D6 tesbihat okuma hatası dahil;
  Ayarlar okuma hatası (varsayılana dönme) kapsam dışı.
- **Self-critique G1–G5 (emryldrmr, 2026-11-11):** G1 mesaj ~4 sn · G2 yalnız başarısız işlem geri alınır, aradaki
  işlemler korunur · G3 seçili zikrin silinmesi başarısızsa zikir ve seçim geri gelir (AC-6) · G4 "örtmez" yerine:
  mesaj sayma dokunuşunu engellemez, tam ekranda mesajın üstüne dokunuş da sayar (AC-10) · G5 boyut: 10 kriter,
  tek yetenek.
- **Split:** proposed none; kept as one — emryldrmr, 2026-11-11, tek yetenek (kayıt hatası geri bildirimi).

## Acceptance criteria
- [x] AC-1 — Sayaçta sayım artıran dokunuşun kaydı başarısız olursa yeni sayım ekranda kalır, sonraki dokunuşlar
  saymaya devam eder ve "Kaydedilemedi. Bu değişiklik uygulama kapanınca kaybolabilir." görünür; geri al ve
  sıfırla için de aynısı olur.
- [x] AC-2 — Bir kayıt başarısız olduktan sonraki ilk başarılı kayıtla uygulama yeniden başlatılınca ekranda
  son görülen sayaç değerleri görünür.
- [x] AC-3 — Tesbihat başlat, dokunuş, geri al ve sıfırla kaydı başarısız olursa AC-1'deki davranış olur.
- [x] AC-4 — Ayarlar'da bir seçeneğin kaydı başarısız olursa seçenek uygulanmış kalır ve AC-1'deki mesaj görünür.
- [x] AC-5 — Günlük sayımın kaydı başarısız olursa sayma sürer, sayaç değerleri doğru kalır ve AC-1'deki mesaj görünür.
- [x] AC-6 — Zikirlerim'de seç, başka bölümden açma, yeniden adlandır ya da silme kaydı başarısız olursa ekran
  işlemden önceki hâline döner ve "Kaydedilemedi." görünür; seçili zikrin silinmesi başarısızsa zikir ve seçim
  geri gelir; arada yapılan başarılı işlemler korunur.
- [x] AC-7 — Zikir ekleme başarısız olursa form açık kalır, girilen ad ve hedef korunur, "Kaydedilemedi." görünür;
  Önerilen Zikirler/Esma'dan eklemede satır "eklendi" göstermez ve aynı mesaj görünür.
- [x] AC-8 — Mesaj görünürken art arda başarısız kayıtlar ikinci bir mesaj açmaz; mesaj kapandıktan sonraki ilk
  başarısız kayıt mesajı yeniden gösterir.
- [x] AC-9 — Tesbihat kaydı okunamazsa "Tesbihat çek" dokunuşu "Tesbihat yüklenemedi." gösterir, tesbihat açılmaz
  ve zikir sayacı çalışmaya devam eder.
- [x] AC-10 — Mesaj tam ekran saymada da görünür, yaklaşık 4 saniye sonra kendiliğinden kapanır, ekran okuyucu
  tarafından okunur, en büyük yazı boyutunda kırpılmaz ve görünürken sayma dokunuşu sayımı artırmaya devam eder
  (tam ekranda mesajın üstüne dokunuş da sayar).

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
| Fix rounds | 1 (fix-1: F-1) |
| Review findings: real / noise / deferred | 1 / 0 / 0 (review round 1: F-1 Medium real, fixed in fix-1; review round 2 clean; VERIFY: no findings) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent VERIFY (QA session, separate from the builder and the reviewer), 2026-11-13 @8d46ec6; triage in `specs/plans/0015-plan.md` `## Triage` (review round 1: F-1 Medium real, fixed in fix-1; review round 2 on the fix diff clean).
Full green: CHECK GREEN (full, 6 steps, 379 s) @8d46ec6 — https://github.com/emryldrmr/zikirmatik/actions/runs/43303952345 (366 tests; later commits change only specs/). Residue: not required — `scripts/check.conf` unchanged.
Deliberate breaks in a temporary copy outside the repo (nothing committed), all red: B1 (visible-notice guard removed), B2 (select undo ignores a later selection), B3 (failed delete restored at the end), B3b (failed delete of the selected does not reselect), B4 (banner takes taps), B5 (fix-1 post-frame notify removed), B6 (notice lasts 5 s).

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `save_failure_test.dart` — `failed tap save keeps the count and keeps counting`, `failed undo and reset keep the screen`; S-2, S-3 | PASS |
| AC-2 | `save_failure_test.dart` — `next good save stores what the screen shows after restart` | PASS |
| AC-3 | `save_failure_test.dart` — `failed tesbihat start, tap, undo and restart keep the screen` | PASS |
| AC-4 | `settings_save_failure_test.dart` — `failed setting save stays applied and warns` (every option goes through `SettingsController._update`) | PASS |
| AC-5 | `history_save_failure_test.dart` — `failed daily count write warns and counting goes on` (error result and thrown exception) | PASS |
| AC-6 | `dhikr_list_save_failure_test.dart` — `failed select, show, rename and delete restore the screen`, `failed delete of the selected brings back dhikr and selection`, `only the failed change is undone`; `dhikr_list_test.dart` — `restored`; S-4; breaks B2, B3, B3b | PASS |
| AC-7 | `dhikr_list_save_failure_test.dart` — `failed add keeps the form and its input`, `failed add from suggested or esma shows no added`; S-5, S-10 | PASS |
| AC-8 | `storage_notice_test.dart` — `a visible notice is not repeated`, `the first failure after it closes shows again`; `storage_notice_banner_test.dart` — `repeated failures show one message`; break B1 | PASS |
| AC-9 | `save_failure_test.dart` — `unreadable tesbihat says so and the counter still counts`; S-6 | PASS |
| AC-10 | `storage_notice_banner_test.dart` — `shows in full screen and a tap on it counts`, `closes by itself after about four seconds`, `is a live region`, `largest text is not clipped`, `does not cover the count button`, `does not cover the count button after a sheet closes under it`, `stays at the bottom in full screen with the largest text`; S-7, S-8, S-9; breaks B4, B5, B6 | PASS |

UI: S-1 success, no message · S-2 counting group light · S-3 counting group dark · S-4 list group, selection undone · S-5 add failed, form kept · S-6 tesbihat not loaded · S-7 full screen · S-8 largest text, message at the top · S-9 largest text full screen, message at the bottom · S-10 suggested add failed, no "eklendi" — agent-captured (headless widget render, Roboto + Material icons, 400×800 dp), outside the repo; judged by emryldrmr at SHIP, 2026-11-13.
