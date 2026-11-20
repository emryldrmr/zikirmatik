# Security

> Bootstrap 2026-11-02 ile dolduruldu. Ajanların her plan ve incelemede uyduğu temel kurallar.

## Secrets
- Secrets never enter the repo, specs, prompts, or chat. `.env` is gitignored; provide `.env.example`.
- Agents never print secret values, even when debugging.
- Uygulamanın çalışma zamanı sırrı yoktur (AlQuran Cloud anahtarsız). Anahtar gerektiren bir API
  eklemek ADR gerektirir; uygulamaya gizli anahtar gömülmez.
- Android imza anahtarları (`*.jks`, `*.keystore`, `android/key.properties`) asla repoya girmez
  (`.gitignore`).

## Input & output
- Kullanıcı girdisi (zikir adı BR-1, hedef BR-2) `domain` katmanında doğrulanır; geçersiz girdi
  `Failure` döner, UI Türkçe mesaj gösterir.
- **Ağ:** yalnızca HTTPS; Android'de cleartext trafik açıkça kapalı
  (`android:usesCleartextTraffic="false"`). İzinli tek dış adres: `api.alquran.cloud`.
- **Dış veri güvenilmezdir:** API yanıtı ayrıştırılıp doğrulanmadan (BR-11: 114 sure, 6236 ayet,
  hiza) önbelleğe yazılmaz; doğrulama tek bir transaction içinde yapılır, hatada hiçbir kısım yazılmaz.
  Yanıt boyutu ve zaman aşımı sınırlıdır.
- **Yedek dosyası dış girdidir (spec 0018):** geri yüklenecek dosya en çok 5 MB'tır — büyüğü okunmaz (önce
  sistemin bildirdiği boyut, okurken de 5 MB + 1 bayt sınırı); içerik bütünüyle doğrulanır (biçim işareti ve
  sürümü, zorunlu alanlar, BR-1/BR-2, negatif değer yok, hedefe eşit sayım yok, tekrar eden id/gün yok, var olan
  zikre seçim, tesbihat adımına uyan ilerleme, geçerli takvim günü, tanınan ayar değeri) ve ancak sonra tek
  transaction'da yazılır; hatada hiçbir kısım yazılmaz. Yedek dosyası **şifresizdir** ve insan okuyabilir;
  Ayarlar'da bu not gösterilir.
- Çıktı: ham hata, yığın izi, SQL ya da URL kullanıcıya gösterilmez (`docs/conventions.md` Error handling).

## AuthN / AuthZ
- Hesap ve kimlik doğrulama yoktur; tüm veri tek kullanıcının cihazındadır.
- **Varsayılan ret (izinler):** uygulama yalnızca `INTERNET`, `VIBRATE` ve `POST_NOTIFICATIONS` (spec 0017: yarım
  kalan zikir bildirimi; Android 13+ kullanıcıya anahtar açılırken sorar) Android izinlerini ister. Bildirim
  yereldir (`flutter_local_notifications`): sunucu, Firebase, ağ yok; veri cihazdan çıkmaz. Birleşik manifestteki
  `<paket>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` AndroidX'in kendi imza düzeyi iznidir, kullanıcıya sorulmaz.
  Yeni bir izin eklemek spec'te gerekçelendirilir ve planda insan onayı gerektirir.
- **Dosyalar (spec 0018):** yedekleme ve geri yükleme depolama izni istemez; Android'in sistem kaydetme/açma
  penceresi (Storage Access Framework, `ACTION_CREATE_DOCUMENT` / `ACTION_OPEN_DOCUMENT`) yalnız kullanıcının
  seçtiği tek URI'ye erişim verir. Uygulama başka dosya okumaz/yazmaz, paket eklenmez (`zikirmatik/backup`
  kanalı, `MainActivity`).
- **Gizlilik:** analitik, telemetri, crash raporlama ve üçüncü taraf SDK yoktur; kullanıcı verisi
  (zikirler, sayımlar, ayarlar) uygulama tarafından cihazdan çıkarılmaz: ağ yok. Yedek dosyasını
  (spec 0018) yalnız kullanıcı, sistem penceresinde kendi seçtiği yere (telefon, Drive, …) koyar.
  Bu madde reklam eklenirse yeniden değerlendirilir (`specs/backlog.md` B-1).

## Dependencies
- Her yeni paket (dependency veya dev_dependency) planda gerekçesiyle listelenir ve **insan onayıyla**
  eklenir.
- Kontrol: lisans MIT / BSD / Apache-2.0 / SIL OFL (diğerleri ADR ile); son 12 ayda bakım görmüş;
  pub.dev "verified publisher" tercih sebebi; bilinen güvenlik açığı yok.
- Sürümler `pubspec.lock` ile sabitlenir ve commit edilir.
- Dolaylı bağımlılık istisnası (plan 0017, A-3): `dbus` (MPL-2.0) `flutter_local_notifications`'ın yalnız Linux
  eklentisinden gelir, Android APK'ya girmez; ADR'siz kabul edildi (emryldrmr, 2026-11-15).
- **Dış API'ler:** yalnızca ücretsiz, anahtarsız/kayıtsız API'ler. İçerik kullanım koşulları
  (Tanzil: metin değiştirilmeden + atıf; mealler: ticari olmayan kullanım) uygulanır ve
  Ayarlar > Kaynaklar'da gösterilir (ADR 0002).

## Review lens
Security is a mandatory dimension of every independent review (see `prompts/review.md`), not a
separate afterthought phase.
