# Spec 0018 — JSON yedekleme ve geri yükleme

- Status: In progress
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
- [ ] AC-1 — Ayarlar'da mevcut başlıkların sonunda "Yedekleme" başlığı, "Yedekle" ve "Geri yükle" satırları alt yazılarıyla ve "Yedek dosyası şifresizdir." notu görünür; diğer ayarlar ve sıraları değişmez.
- [ ] AC-2 — "Yedekle" sistem kaydetme penceresini `zikirmatik-yedek-<bugünün yerel tarihi YYYY-AA-GG>.json` önerisiyle açar; kaydedilince "Yedek kaydedildi" görünür; pencere iptal edilirse mesaj yok ve veri değişmez; yazma hatasında "Yedek kaydedilemedi." görünür.
- [ ] AC-3 — Gidiş-dönüş: hedefli ve hedefsiz zikirler (sayım, tur, toplam, sıra), seçili zikir (ya da seçili tesbihat ve adım ilerlemesi), en az iki günlük geçmiş ve varsayılandan farklı tüm ayarlarla alınan yedek; veri değiştirildikten (zikir silme/ekleme, sayma, ayar değiştirme) sonra geri yüklenince hepsi yedekteki değerlere döner; seri, en uzun seri ve rozetler yedek anındakiyle aynıdır.
- [ ] AC-4 — Geçerli dosya seçilince onay penceresi "Mevcut tüm verileriniz yedektekiyle değiştirilecek." uyarısını, yedeğin tarihini ve zikir sayısını gösterir; "Vazgeç" hiçbir şeyi değiştirmez; dosya seçme penceresi iptal edilirse mesaj yok.
- [ ] AC-5 — Onaydan sonra yedekte olmayan mevcut zikirler ve günler kalmaz (birleştirme yok); "Yedek geri yüklendi" görünür; uygulama yeniden başlatmadan yeni verileri (Zikirlerim, Geçmiş, tema dahil ayarlar) gösterir; uygulama kapatılıp açılınca da aynı değerler görünür.
- [ ] AC-6 — Reddedilen dosyalar (JSON olmayan, zikirmatik yedeği olmayan JSON, zorunlu alanı eksik, 5 MB'tan büyük, kural dışı değer: 51 karakterli ya da boş ad, hedef 0 ya da 100001, negatif sayım, hedefe eşit sayım, var olmayan zikre seçim, geçersiz gün, tanınmayan ayar değeri) "Bu dosya geçerli bir zikirmatik yedeği değil." gösterir; daha yeni biçim sürümlü dosya "Bu yedek uygulamanın daha yeni bir sürümüyle alınmış. Uygulamayı güncelleyin." gösterir; hiçbirinde onay penceresi açılmaz ve veri değişmez.
- [ ] AC-7 — Geri yükleme kaydedilirken depolama hatası olursa "Yedek geri yüklenemedi. Verileriniz değişmedi." görünür ve mevcut veri birebir korunur; okunamayan dosyada "Dosya açılamadı." görünür.
- [ ] AC-8 — Sınırlar: hiç zikri olmayan veriyle alınan yedek geri yüklenince Zikirlerim boştur (onayda "0 zikir"); 50 karakterli ad, hedef 100000 ve büyük toplamlar aynen geri gelir; daha eski biçim sürümlü geçerli dosya kabul edilir, eksik ayarlar varsayılan değeri alır.
- [ ] AC-9 — Yarım kalan zikir: geri yükleme sonrası devam noktası yoktur (yeni sayma dokunuşuna kadar bildirim çıkmaz); yedekte bildirim ayarı açık ama izin yoksa ayar kapalı yüklenir ve izin istenmez.
- [ ] AC-10 — Erişilebilirlik: satırlar tek öğe olarak başlık + alt yazıyla okunur; not okunur; tüm mesajlar duyurulur; onay penceresi metni ve düğmeleri okunur; en büyük yazı boyutunda ve 320 dp'de metin kırpılmaz; açık ve koyu temada okunur.

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
