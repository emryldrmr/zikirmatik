# Spec 0018 — JSON yedekleme ve geri yükleme

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0018-plan.md`
- Self-critique: done

## Intent
Kullanıcı telefon değiştirdiğinde ya da uygulamayı silip yeniden kurduğunda zikirlerini, sayımlarını, serisini ve
ayarlarını kaybetmek istemiyor. Ayarlar'dan tek dokunuşla tüm verisini bir yedek dosyasına yazar, dosyayı kendi
seçtiği yere (telefon, Drive, kendine e-posta) koyar; sonra o dosyayı seçerek her şeyi geri yükler. Başarı: geri
yüklemeden sonra uygulama yedeğin alındığı andaki gibi görünür; bozuk ya da uyumsuz dosya mevcut veriye hiç
dokunmaz. Bilinçli olarak yapılmayan: otomatik/zamanlanmış yedekleme, bulut senkronu (B-6), hesap, şifreleme,
birleştirerek geri yükleme. Kararlar D1–D7 (emryldrmr, 2026-11-19) buraya katlandı.

## Requirements
1. **Kapsam (D1):** yedek, kullanıcının tüm verisini içerir: zikirler (ad, hedef, sayım, tamamlanan tur, toplam;
   Zikirlerim'deki sırasıyla), seçili zikir (ya da tesbihat), tesbihat ilerlemesi, günlük geçmiş ve tüm ayarlar.
   Seri, en uzun seri ve rozetler geçmişten hesaplandığı için geri yüklemeyle aynen geri gelir. Kur'an önbelleği
   ve devam noktası (yalnız bellekte) yedeğe girmez.
2. **Yedekle (D3, D4):** "Yedekle"ye dokununca Android'in sistem kaydetme penceresi açılır; önerilen dosya adı
   `zikirmatik-yedek-YYYY-AA-GG.json`'dur (yerel tarih). Kullanıcı konumu (Drive dahil, sistem ne sunuyorsa) ve adı
   seçer. Dosya kaydedilince "Yedek kaydedildi" mesajı görünür. Dosya, yedeğin alındığı anı, uygulama sürümünü ve
   bir yedek biçimi sürümünü taşır; şifresizdir ve insan okuyabilir.
3. **Geri yükle (D2, D3):** "Geri yükle"ye dokununca sistem dosya seçme penceresi açılır. Seçilen dosya geçerliyse
   onay penceresi görünür: "Mevcut tüm verileriniz yedektekiyle değiştirilecek." ile birlikte yedeğin tarihi ve
   içindeki zikir sayısı (G8). Onaylanırsa mevcut kullanıcı verisinin **tamamı** yedektekiyle değiştirilir
   (birleştirme yok); vazgeçilirse hiçbir şey değişmez. Geçersiz dosyada onay penceresi açılmaz (gerekçe 5).
4. **Sonrası (D7):** başarılı geri yüklemeden sonra "Yedek geri yüklendi" mesajı görünür; uygulama yeniden
   başlatma gerektirmeden yeni verilerle görünür (Zikirlerim, seçili zikir, Geçmiş, ayarlar, tema). Görünür bir
   yarım kalan zikir bildirimi varsa kaldırılır; devam noktası sıfırlanır.
5. **Doğrulama (D5):** dosya, hiçbir veri değişmeden önce bütünüyle doğrulanır; ya tamamı yüklenir ya hiçbiri.
   Reddedilen durumlar ve mesajlar:
   - zikirmatik yedeği değil, bozuk ya da eksik → "Bu dosya geçerli bir zikirmatik yedeği değil."
   - daha yeni bir yedek biçimiyle alınmış → "Bu yedek uygulamanın daha yeni bir sürümüyle alınmış. Uygulamayı
     güncelleyin."
   - iş kurallarını çiğneyen değer (BR-1 ad 1–50 karakter, BR-2 hedef 1–100000, negatif sayım/tur/toplam, hedefli
     zikirde hedefe eşit ya da büyük sayım, var olmayan zikre işaret eden seçim, geçersiz takvim günü, tanınmayan
     ayar değeri) → aynı "geçerli bir zikirmatik yedeği değil" mesajı.
   - dosya 5 MB'tan büyük → aynı mesaj; dosya okunmaya çalışılmaz (G4).
   Daha eski bir yedek biçimiyle alınmış geçerli dosya kabul edilir; o biçimde olmayan alanlar varsayılan değeri alır.
6. **Ayarlar (D6):** Ayarlar'da mevcut başlıkların sonunda yeni "Yedekleme" başlığı; altında "Yedekle" (alt yazı:
   "Tüm verilerinizi bir dosyaya kaydeder") ve "Geri yükle" (alt yazı: "Bir yedek dosyasından verilerinizi geri
   getirir") satırları ve başlığın altında kısa not: "Yedek dosyası şifresizdir." Son yedek tarihi gösterilmez.
7. **İptal ve hata (G3, G5):** kullanıcı sistem penceresini kapatırsa hiçbir şey olmaz, mesaj görünmez. Dosya
   yazılamazsa "Yedek kaydedilemedi." ; dosya okunamazsa "Dosya açılamadı." ; geri yükleme kaydedilirken depolama
   hatası olursa "Yedek geri yüklenemedi. Verileriniz değişmedi." görünür ve mevcut veri aynen kalır.
8. **Bildirim izni (G1):** yedekte "Yarım kalan zikir bildirimi" açıksa ama cihazda bildirim izni yoksa ayar
   kapalı olarak yüklenir; geri yükleme izin istemez.
9. **Boş veri (G2):** hiç zikri olmayan kullanıcı da yedek alabilir; böyle bir yedek geri yüklenince Zikirlerim boş
   görünür (onay penceresinde "0 zikir").

## User experience
- **Flow (yedekle):** Ayarlar → Yedekleme → "Yedekle" → sistem kaydetme penceresi (`zikirmatik-yedek-2026-11-19.json`)
  → Kaydet → "Yedek kaydedildi".
- **Flow (geri yükle):** Ayarlar → Yedekleme → "Geri yükle" → sistem dosya seçme penceresi → dosya → onay penceresi
  (uyarı + yedek tarihi + zikir sayısı) → "Geri yükle" → "Yedek geri yüklendi" → uygulama yeni verilerle.
- **States:**
  - *Yedekleme bölümü:* iki satır + şifresiz notu.
  - *Sistem penceresi açık / iptal:* uygulama değişmez, mesaj yok.
  - *Yedek kaydedildi / kaydedilemedi:* ilgili mesaj.
  - *Geçersiz dosya / daha yeni sürüm / açılamadı:* ilgili mesaj, onay penceresi yok, veri değişmez.
  - *Onay penceresi:* uyarı, tarih, zikir sayısı; "Vazgeç" ve "Geri yükle" düğmeleri.
  - *Geri yüklendi / geri yüklenemedi:* ilgili mesaj.
- **Design reference:** none — the flow above is the design. Kaydetme ve dosya seçme pencereleri Android'in
  standart pencereleridir; mesajlar uygulamanın mevcut kısa mesaj görünümünü kullanır.
- **Accessibility:** her satır tek ekran okuyucu öğesidir (başlık + alt yazı, düğme olarak); şifresiz notu okunur;
  mesajlar ekran okuyucuya duyurulur; onay penceresinin metni ve düğmeleri okunur; en büyük yazı boyutunda ve
  320 dp'de satır ve pencere metni kırpılmaz; açık ve koyu temada okunur.

## Constraints & out of scope
- Sensitive area: none (yok) — yedek yalnız kullanıcının kendi verisini (yazdığı zikir adları, sayılar, geçmiş,
  ayarlar) taşır; dini metin (Kur'an, meal, Esma, önerilen zikir içeriği) yedeğe girmez ve değişmez.
- **Gizlilik:** yeni Android izni ve ağ erişimi yok; dosyayı yalnız kullanıcının seçtiği yere sistem penceresi
  yazar ("veri cihazdan çıkmaz" maddesi korunur — dosyayı dışarı kullanıcı taşır). `docs/security.md` buna göre
  netleştirilir. Yeni paket gerekirse planda gerekçesiyle, insan onayıyla eklenir.
- **Dış veri güvenilmezdir:** yedek dosyası dış girdidir; doğrulanmadan hiçbir kısmı yazılmaz (`docs/security.md`).
- Mevcut sayma, geçmiş, rozet ve bildirim davranışı (BR-1…BR-13, 0014, 0016, 0017) değişmez.
- Roadmap (emryldrmr, 2026-11-19): günlük hatırlatma + seri hatırlatması atlandı; 0018 = JSON yedekleme → Kur'an +
  meal + Kaynaklar → Günün Ayeti. Firebase ile elle senkron backlog'da (B-6). `docs/architecture.md` sırası
  build'de güncellenir.
- **Clarify kararları (lite, emryldrmr, 2026-11-19):** D1 kapsam: tüm kullanıcı verisi, Kur'an önbelleği hariç ·
  D2 tümünü değiştir, onaylı · D3 sistem kaydet/seç penceresi, paylaşım menüsü yok · D4 `zikirmatik-yedek-YYYY-AA-GG.json`,
  sürüm + biçim sürümü, şifresiz + not · D5 hatalı/eksik/kural dışı/daha yeni dosya reddedilir, hiçbir şey
  değişmez; eski biçim kabul · D6 Ayarlar > Yedekleme, iki satır, son yedek tarihi yok · D7 "Yedek geri yüklendi",
  yeniden başlatma yok, yarım kalan zikir bildirimi kalkar.
- **Self-critique (emryldrmr, 2026-11-19):** G1 izin yoksa bildirim ayarı kapalı yüklenir, izin istenmez · G2 boş
  veriyle yedek alınabilir, geri yükleme boş Zikirlerim verir · G3 pencere iptali sessiz · G4 5 MB üstü okunmadan
  reddedilir · G5 kaydedilemedi / açılamadı / geri yüklenemedi mesajları, veri değişmez · G6 kural dışı değer
  listesi (Requirements 5) · G7 eski biçimde eksik ayar varsayılanı alır · G8 onayda yedek tarihi + zikir sayısı.
- Split: proposed 0018a yedekle + 0018b geri yükle; kept as one — emryldrmr, 2026-11-19, biri diğeri olmadan
  kullanılamaz ve gidiş-dönüş ancak birlikte doğrulanır.
- **Out of scope:** otomatik/zamanlanmış yedek; bulut senkronu ve hesap (B-6); paylaşım menüsü; şifreli/parolalı
  yedek; birleştirerek ya da seçerek (yalnız zikirler, yalnız ayarlar) geri yükleme; son yedek tarihi; Android'in
  sistem yedeğine (Auto Backup) dahil olma; başka uygulamalardan içe aktarma; CSV/başka biçim.

## Acceptance criteria
- [x] AC-1 — Ayarlar'da mevcut başlıkların sonunda "Yedekleme" başlığı, "Yedekle" ve "Geri yükle" satırları alt yazılarıyla ve "Yedek dosyası şifresizdir." notu görünür; diğer ayarlar ve sıraları değişmez.
- [x] AC-2 — "Yedekle" sistem kaydetme penceresini `zikirmatik-yedek-<bugünün yerel tarihi YYYY-AA-GG>.json` önerisiyle açar; kaydedilince "Yedek kaydedildi" görünür; pencere iptal edilirse mesaj yok ve veri değişmez; yazma hatasında "Yedek kaydedilemedi." görünür.
- [x] AC-3 — Gidiş-dönüş: hedefli ve hedefsiz zikirler (sayım, tur, toplam, sıra), seçili zikir (ya da seçili tesbihat ve adım ilerlemesi), en az iki günlük geçmiş ve varsayılandan farklı tüm ayarlarla alınan yedek; veri değiştirildikten (zikir silme/ekleme, sayma, ayar değiştirme) sonra geri yüklenince hepsi yedekteki değerlere döner; seri, en uzun seri ve rozetler yedek anındakiyle aynıdır.
- [x] AC-4 — Geçerli dosya seçilince onay penceresi "Mevcut tüm verileriniz yedektekiyle değiştirilecek." uyarısını, yedeğin tarihini ve zikir sayısını gösterir; "Vazgeç" hiçbir şeyi değiştirmez; dosya seçme penceresi iptal edilirse mesaj yok.
- [x] AC-5 — Onaydan sonra yedekte olmayan mevcut zikirler ve günler kalmaz (birleştirme yok); "Yedek geri yüklendi" görünür; uygulama yeniden başlatmadan yeni verileri (Zikirlerim, Geçmiş, tema dahil ayarlar) gösterir; uygulama kapatılıp açılınca da aynı değerler görünür.
- [x] AC-6 — Reddedilen dosyalar (JSON olmayan, zikirmatik yedeği olmayan JSON, zorunlu alanı eksik, 5 MB'tan büyük, kural dışı değer: 51 karakterli ya da boş ad, hedef 0 ya da 100001, negatif sayım, hedefe eşit sayım, var olmayan zikre seçim, geçersiz gün, tanınmayan ayar değeri) "Bu dosya geçerli bir zikirmatik yedeği değil." gösterir; daha yeni biçim sürümlü dosya "Bu yedek uygulamanın daha yeni bir sürümüyle alınmış. Uygulamayı güncelleyin." gösterir; hiçbirinde onay penceresi açılmaz ve veri değişmez.
- [x] AC-7 — Geri yükleme kaydedilirken depolama hatası olursa "Yedek geri yüklenemedi. Verileriniz değişmedi." görünür ve mevcut veri birebir korunur; okunamayan dosyada "Dosya açılamadı." görünür.
- [x] AC-8 — Sınırlar: hiç zikri olmayan veriyle alınan yedek geri yüklenince Zikirlerim boştur (onayda "0 zikir"); 50 karakterli ad, hedef 100000 ve büyük toplamlar aynen geri gelir; daha eski biçim sürümlü geçerli dosya kabul edilir, eksik ayarlar varsayılan değeri alır.
- [x] AC-9 — Yarım kalan zikir: geri yükleme sonrası devam noktası yoktur (yeni sayma dokunuşuna kadar bildirim çıkmaz); yedekte bildirim ayarı açık ama izin yoksa ayar kapalı yüklenir ve izin istenmez.
- [x] AC-10 — Erişilebilirlik: satırlar tek öğe olarak başlık + alt yazıyla okunur; not okunur; tüm mesajlar duyurulur; onay penceresi metni ve düğmeleri okunur; en büyük yazı boyutunda ve 320 dp'de metin kırpılmaz; açık ve koyu temada okunur.

## Definition of Done
- [x] Every acceptance criterion mapped to proof (test or reproducible observation)
- [x] `scripts/check` green
- [x] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [x] Docs / ADRs updated if behavior or architecture changed
- [x] Spec moved to `specs/done/` (it becomes immutable there)

## Scorecard (fill at ship — honest numbers make the process improvable)
| Metric | Value |
|---|---|
| Spec revisions | 1 |
| Fix rounds | 2 (fix-1: review round 1 Low-1, Info-1 — docs only; fix-2: VERIFY round 1 G-1 — test only) |
| Review findings: real / noise / deferred | 3 / 0 / 0 (review round 1: Low-1, Info-1 real, fixed in fix-1; VERIFY round 1: G-1 Medium real, fixed in fix-2; review round 2: clean; VERIFY round 2: clean) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent VERIFY round 2 (read-only reviewer subagent, separate from the builder), 2026-11-20 @7ff7059, after fix round 2 and review round 2 (clean); triage in `specs/plans/0018-plan.md` `## Triage`.
Full green: CHECK GREEN (full, 6 steps, 163 s) @e4ac9d6 — local (later commits change only specs/). CI @7ff7059 (run 44623089604): `check` success, `doctor` success. QA's own run of the 0018 test files: `+53: All tests passed!`. Residue: not required — `scripts/check.conf` unchanged.
Deliberate breaks (temp copy outside the repo, `lib/features/backup/data/backup_json.dart` only, restored and diffed after each): B1 5 MB check removed → `rejects larger than five megabytes` red · B2 `>` → `>=` → same test red (boundary file) · B3 target max + 1 → `rejects target 100001` red · B4 target `>= max` rejected → `fifty char name and max target kept` red · B5 BR-1 check skipped → `rejects fifty one char name` red · B6 name limit 49 → `fifty char name and max target kept` red · B7 newer format `> version + 1` → `newer format is too new` red · B8 settings keys required → `missing settings keys take defaults` red.

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `backup_section_test.dart` — `backup section after notifications with subtitles and note`; S-1 | PASS |
| AC-2 | `save suggests dated name and confirms`, `save cancelled shows nothing`, `save failure message`; O1; S-6, S-7, S-13 | PASS |
| AC-3 | `drift_backup_store_test.dart` — `round trip restores every table`, `streak and badges match`; `backup_json_test.dart` — `encode decode round trip`; O3 | PASS |
| AC-4 | `valid file shows warning date and count`, `cancel changes nothing`, `pick cancelled shows nothing`; O2; S-3 | PASS |
| AC-5 | `replace leaves no extra dhikrs or days`, `restored data loads after reopen`, `restore refreshes my dhikrs history and theme`; O3; S-11 | PASS |
| AC-6 | `backup_json_test.dart` `rejects` group (one test per case) + `newer format is too new`; `invalid file shows message no dialog`, `too large file rejected unread`; O5; B1, B2, B3, B5, B7; S-8, S-9 | PASS |
| AC-7 | `failed replace rolls back`, `restore failure message keeps data`, `unreadable file message`; S-10, S-12 | PASS |
| AC-8 | `empty backup`, `fifty char name and max target kept`, `large totals kept`, `missing settings keys take defaults`, `zero dhikrs in summary`; B4, B6, B8 | PASS |
| AC-9 | `restore clears resume point`, `notification setting off without permission and no request` | PASS |
| AC-10 | `rows are one semantics node`, `messages announced`, `largest text at 320 dp`, `light and dark`; S-1 light/dark, S-2, S-4, S-5 (O4 TalkBack not run — user decision, criterion proven by widget tests) | PASS |

UI: S-1 section light/dark · S-2 section 320 dp text ×2 · S-3 confirm dialog · S-4 confirm dialog 320 dp text ×2 · S-5 confirm dialog dark · S-6 saved · S-7 save failed · S-8 invalid · S-9 too new · S-10 open failed · S-11 restored · S-12 restore failed · S-13 cancelled, no message — agent-captured (headless widget render, Roboto + Material icons), outside the repo; judged by emryldrmr at SHIP, 2026-11-20. System save/open pickers cannot render headless — covered by device observations O1, O2. Device observations O1–O3, O5 by emryldrmr (Xiaomi 2412DPC0AG, Android 16), recorded in the plan.
