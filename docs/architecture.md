# Architecture

> Bootstrap 2026-11-02 ile dolduruldu. Burada *karar verilmiş* mimari anlatılır, hedef değil.
> Ajanlar planlamadan önce bu dosyayı okur.

## System overview

zikirmatik, tek bir Flutter uygulamasıdır (Android önce, minSdk 23; kod iOS'a uyumlu tutulur).
Stil: **feature-first modüler monolit**; her özellik kendi içinde `domain` / `data` / `ui`
katmanlarına ayrılır. Sunucu, hesap ve senkron yoktur; tüm durum cihazda SQLite'ta (drift) tutulur.
Tek dış bağımlılık, Kur'an ve meal metnini ilk kullanımda indiren AlQuran Cloud API'sidir; indirilen
veri doğrulanıp önbelleğe yazılır ve sonrası offline çalışır. Gerekçe: küçük bir uygulama için yeterli
sınırlar, saf Dart'ta hızlı test edilen iş kuralları ve tek dosyada izole edilmiş API kaynağı
(ADR 0001 yığın, ADR 0002 veri kaynağı).

## Modules / components and ownership

| Module | Single responsibility | Owns |
|---|---|---|
| `lib/app/` | Uygulama kabuğu: yan menü (Drawer), yönlendirme (yerleşik `Navigator`), tema, DI kökü (Riverpod `ProviderScope`) | Gezinme yapısı, tema |
| `lib/core/` | Paylaşılan küçük yapı taşları: `Result`/`Failure`, `Clock`, `Haptics` arayüzü, veritabanı açılışı | Ortak tipler |
| `lib/features/counter/` | Zikirlerim + sayaç: BR-1…BR-8 | Kullanıcının zikirleri, sayım, tur, toplam |
| `lib/features/suggested/` | Önerilen Zikirler listesi (gömülü veri), BR-9 | Önerilen zikir içeriği |
| `lib/features/esma/` | Esmaü'l-Hüsna listesi (gömülü veri), BR-9 | 99 isim içeriği |
| `lib/features/quran/` | Kur'an + meal: indirme, doğrulama, önbellek, okuma ekranı; BR-10…BR-12 | Kur'an/meal önbelleği; AlQuran Cloud adaptörü |
| `lib/features/settings/` | Ayarlar (titreşim, tema, varsayılan meal) ve Kaynaklar ekranı | Kullanıcı tercihleri |

## Communication rules

- Özellikler arası iletişim yalnızca hedef özelliğin genel arayüz dosyası (`features/<x>/<x>.dart`)
  üzerinden, doğrudan çağrıyla olur. Örnek: `suggested` ve `esma`, zikir eklemek için `counter`'ın
  genel arayüzünü kullanır.
- `ui` → durum (Riverpod provider) → `domain` / repository. `ui` depolamaya doğrudan erişmez.
- Olay yolu / mesaj kuyruğu yoktur; ihtiyaç doğarsa ADR ile eklenir.

## Forbidden dependencies (make them testable)

Hepsi `test/architecture/` altındaki import-tarama testiyle `scripts/check` içinde doğrulanır:

1. **FD-1:** `lib/**/domain/**` saf Dart'tır: `package:flutter/*`, herhangi bir `data/` ya da `ui/`
   dosyasını, `drift` ve `http` paketlerini import etmez.
2. **FD-2:** `lib/features/<a>/**`, başka bir özelliğin (`lib/features/<b>/`) yalnızca genel arayüz
   dosyasını (`lib/features/<b>/<b>.dart`) import edebilir; iç dosyalarını asla.
3. **FD-3:** `package:http` ve AlQuran Cloud adresi yalnızca `lib/features/quran/data/` içinde geçer.
4. **FD-4:** `lib/**/ui/**`, `drift` paketini ve herhangi bir `data/` dosyasını import etmez.

## Deliberately out of scope

Hesap/giriş, bulut senkronu, istatistik/grafik, bildirim/hatırlatıcı, iOS derlemesi ve mağaza süreci,
reklam (bkz. `specs/backlog.md` B-1), analitik/telemetri/crash raporlama, ses (sesli okuma/kıraat).
