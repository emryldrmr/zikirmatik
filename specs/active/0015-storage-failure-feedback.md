# Spec 0015 — Depolama hatası geri bildirimi

- Status: In progress
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
- [ ] AC-1 — Sayaçta sayım artıran dokunuşun kaydı başarısız olursa yeni sayım ekranda kalır, sonraki dokunuşlar
  saymaya devam eder ve "Kaydedilemedi. Bu değişiklik uygulama kapanınca kaybolabilir." görünür; geri al ve
  sıfırla için de aynısı olur.
- [ ] AC-2 — Bir kayıt başarısız olduktan sonraki ilk başarılı kayıtla uygulama yeniden başlatılınca ekranda
  son görülen sayaç değerleri görünür.
- [ ] AC-3 — Tesbihat başlat, dokunuş, geri al ve sıfırla kaydı başarısız olursa AC-1'deki davranış olur.
- [ ] AC-4 — Ayarlar'da bir seçeneğin kaydı başarısız olursa seçenek uygulanmış kalır ve AC-1'deki mesaj görünür.
- [ ] AC-5 — Günlük sayımın kaydı başarısız olursa sayma sürer, sayaç değerleri doğru kalır ve AC-1'deki mesaj görünür.
- [ ] AC-6 — Zikirlerim'de seç, başka bölümden açma, yeniden adlandır ya da silme kaydı başarısız olursa ekran
  işlemden önceki hâline döner ve "Kaydedilemedi." görünür; seçili zikrin silinmesi başarısızsa zikir ve seçim
  geri gelir; arada yapılan başarılı işlemler korunur.
- [ ] AC-7 — Zikir ekleme başarısız olursa form açık kalır, girilen ad ve hedef korunur, "Kaydedilemedi." görünür;
  Önerilen Zikirler/Esma'dan eklemede satır "eklendi" göstermez ve aynı mesaj görünür.
- [ ] AC-8 — Mesaj görünürken art arda başarısız kayıtlar ikinci bir mesaj açmaz; mesaj kapandıktan sonraki ilk
  başarısız kayıt mesajı yeniden gösterir.
- [ ] AC-9 — Tesbihat kaydı okunamazsa "Tesbihat çek" dokunuşu "Tesbihat yüklenemedi." gösterir, tesbihat açılmaz
  ve zikir sayacı çalışmaya devam eder.
- [ ] AC-10 — Mesaj tam ekran saymada da görünür, yaklaşık 4 saniye sonra kendiliğinden kapanır, ekran okuyucu
  tarafından okunur, en büyük yazı boyutunda kırpılmaz ve görünürken sayma dokunuşu sayımı artırmaya devam eder
  (tam ekranda mesajın üstüne dokunuş da sayar).

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
