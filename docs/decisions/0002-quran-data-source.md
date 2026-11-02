# ADR 0002 — Kur'an ve meal verisi: AlQuran Cloud + cihazda doğrulanmış önbellek

- Status: Accepted
- Date: 2026-11-02

## Context
Kur'an + Meal sekmesi Arapça ayet metnini ve seçilebilir Türkçe meali gösterecek. Ürün sahibinin
şartı: **ücretsiz, anahtarsız/kayıtsız API**. Uygulama offline çalışmalı. İçerik hassas alandadır
(dini metin bütünlüğü, `docs/domain.md`). İş modeli: ücretsiz ve reklamsız (ileride reklam olasılığı
`specs/backlog.md` B-1'de).

## Decision
Birincil kaynak AlQuran Cloud API'si (`api.alquran.cloud`, anahtarsız, Tanzil kaynaklı metin).
Veri ilk kullanımda indirilir, doğrulanır (BR-11) ve tek transaction'la drift önbelleğine yazılır;
sonrası offline. API'ye erişim yalnızca `lib/features/quran/data/` içindeki adaptörde (FD-3), böylece
kaynak tek dosyada değiştirilebilir. Kaynaklar Ayarlar > Kaynaklar'da anılır.

## Consequences
- Artı: anahtar/sır yok; uzun ömürlü, birçok Türkçe meali tek kaynaktan sunuyor.
- Artı: ilk indirmeden sonra tamamen offline; doğrulama sayesinde yarım/bozuk metin gösterilmez.
- Eksi: ilk açılışta ağ gerekir; üçüncü taraf hizmetin sürekliliğine bağımlılık (önbellek bunu yumuşatır).
- Eksi / koşul: içerik kullanım koşulları geçerli — Tanzil metni değiştirilmeden ve atıfla; mealler
  genellikle yalnızca ticari olmayan kullanım için serbest. Uygulama ticari olursa (reklam) meal lisansı
  yeniden değerlendirilmeli (B-1).
- Doğrulanmadı (açık iş): Diyanet mealinin edition kimliği (`tr.diyanet` olması bekleniyor) ve
  sunulan Türkçe meal listesi — Kur'an spec'inde `/v1/edition?language=tr` ile doğrulanır.

## Alternatives considered
- **Açık Kuran API (`api.acikkuran.com`):** Türkçe meal çeşitliliği zengin, açık kaynak. Kaybetme
  sebebi: gönüllü işletme (Patreon), lisans ve hız limiti açıkça yazılı değil — süreklilik riski.
  Yedek kaynak adayı olarak kalır.
- **Quran Foundation / Quran.com API:** istemci kimlik bilgisi (OAuth) istiyor → anahtarsız şartını
  karşılamıyor ve uygulamaya sır gömmeyi gerektirir.
- **Metni derleme anında uygulamaya gömmek (Tanzil verisi):** API'siz, tamamen offline; uygulama boyutu
  büyür ve meal seçimi sınırlanır. Ürün sahibi API'yi tercih etti.

## Revisit triggers
- AlQuran Cloud erişilemez olur, koşullarını değiştirir veya anahtar ister.
- Uygulamaya reklam/ücret eklenmesi (ticari kullanım).
- Kullanıcıların AlQuran Cloud'da bulunmayan bir meal talep etmesi.
