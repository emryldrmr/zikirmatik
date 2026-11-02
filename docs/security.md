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
- Çıktı: ham hata, yığın izi, SQL ya da URL kullanıcıya gösterilmez (`docs/conventions.md` Error handling).

## AuthN / AuthZ
- Hesap ve kimlik doğrulama yoktur; tüm veri tek kullanıcının cihazındadır.
- **Varsayılan ret (izinler):** uygulama yalnızca `INTERNET` ve `VIBRATE` Android izinlerini ister.
  Yeni bir izin eklemek spec'te gerekçelendirilir ve planda insan onayı gerektirir.
- **Gizlilik:** analitik, telemetri, crash raporlama ve üçüncü taraf SDK yoktur; kullanıcı verisi
  (zikirler, sayımlar, ayarlar) cihazdan çıkmaz. Bu madde reklam eklenirse yeniden değerlendirilir
  (`specs/backlog.md` B-1).

## Dependencies
- Her yeni paket (dependency veya dev_dependency) planda gerekçesiyle listelenir ve **insan onayıyla**
  eklenir.
- Kontrol: lisans MIT / BSD / Apache-2.0 / SIL OFL (diğerleri ADR ile); son 12 ayda bakım görmüş;
  pub.dev "verified publisher" tercih sebebi; bilinen güvenlik açığı yok.
- Sürümler `pubspec.lock` ile sabitlenir ve commit edilir.
- **Dış API'ler:** yalnızca ücretsiz, anahtarsız/kayıtsız API'ler. İçerik kullanım koşulları
  (Tanzil: metin değiştirilmeden + atıf; mealler: ticari olmayan kullanım) uygulanır ve
  Ayarlar > Kaynaklar'da gösterilir (ADR 0002).

## Review lens
Security is a mandatory dimension of every independent review (see `prompts/review.md`), not a
separate afterthought phase.
