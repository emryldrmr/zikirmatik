# Architecture

> Bootstrap 2026-11-02 ile dolduruldu. Burada *karar verilmiş* mimari anlatılır, hedef değil.
> Ajanlar planlamadan önce bu dosyayı okur.

## System overview

zikirmatik, tek bir Flutter uygulamasıdır (Android önce, minSdk 24 — ADR 0003; kod iOS'a uyumlu tutulur).
Stil: **feature-first modüler monolit**; her özellik kendi içinde `domain` / `data` / `ui`
katmanlarına ayrılır. Sunucu, hesap ve senkron yoktur; tüm durum cihazda SQLite'ta (drift) tutulur.
Tek dış bağımlılık, Kur'an ve meal metnini ilk kullanımda indiren AlQuran Cloud API'sidir; indirilen
veri doğrulanıp önbelleğe yazılır ve sonrası offline çalışır. Gerekçe: küçük bir uygulama için yeterli
sınırlar, saf Dart'ta hızlı test edilen iş kuralları ve tek dosyada izole edilmiş API kaynağı
(ADR 0001 yığın, ADR 0002 veri kaynağı).

## Modules / components and ownership

| Module | Single responsibility | Owns |
|---|---|---|
| `lib/app/` | Uygulama kabuğu: yan menü (Drawer), yönlendirme (yerleşik `Navigator`), tema; kompozisyon kökü (`composition.dart`: soyut bağımlılıkları cihaz uygulamalarına bağlar, ör. `SystemHaptics`; özelliklerin birbirine kendisi kuramadığı bağları `featureWiring()` kurar — ör. `vibrationEnabledProvider` ve `tapVibrationEnabledProvider` ← titreşim ayarları, `appVersionProvider` ← kurulu sürüm (`package_info_plus`; yan menünün altında, spec 0009) — ve uygulama ile testler aynı listeyi kullanır); tema (açık/koyu, ayardan; içerik ayarlar okununca gösterilir); tek drift veritabanı ve şema migration'ları (`database/`) | Gezinme yapısı, tema, veritabanı şeması |
| `lib/core/` | Paylaşılan küçük yapı taşları: `Result`/`Failure` (`StorageFailure`, `ValidationFailure`), `Haptics` arayüzü + `hapticsProvider` + `vibrationEnabledProvider` (varsayılan açık); `Clock` ilk ihtiyaç duyan spec'te eklenir | Ortak tipler |
| `lib/features/counter/` | Zikirlerim + sayaç: BR-1…BR-8; tesbihat modu (BR-13); tam ekran dokunma alanı, ses tuşuyla sayma, sayaç ekranında ekranı açık tutma | Kullanıcının zikirleri (`dhikrs`) ve seçili zikir (`dhikr_selections`); her zikrin sayım, tur, toplam, hedefi (`counters`, aynı id); tesbihat dizileri ve ilerlemesi |
| `lib/features/suggested/` | Önerilen Zikirler listesi (gömülü veri), BR-9 | Önerilen zikir içeriği |
| `lib/features/esma/` | Esmaü'l-Hüsna listesi (gömülü veri), BR-9 | 99 isim içeriği |
| `lib/features/quran/` | Kur'an + meal: indirme, doğrulama, önbellek, okuma ekranı; BR-10…BR-12 | Kur'an/meal önbelleği; AlQuran Cloud adaptörü |
| `lib/features/settings/` | Ayarlar ekranı: titreşim ve tema (spec 0004); sonra ara titreşim, büyük rakam, sol/sağ el yerleşimi, ses tuşuyla sayma, ekranı açık tut, varsayılan meal ve Kaynaklar ekranı kendi spec'leriyle | Kullanıcı tercihleri (`settings`, tek satır; satır yoksa varsayılanlar) |

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

## Sürüm 1 kapsamı (2026-11-02'de kararlaştırıldı)

Walking skeleton → sayaç (BR-1…BR-8) → Zikirlerim → Ayarlar (titreşim + tema; spec 0004) → tesbihat
modu → tam ekran dokunma + ses tuşuyla sayma + ekranı açık tut + görünüm seçenekleri (büyük rakam, el
yerleşimi, ara titreşim) → Önerilen Zikirler ve Esmaü'l-Hüsna → Kur'an + meal + Kaynaklar. Her biri kendi
spec'iyle gelir; sonraki özellikler kendi ayarlarını Ayarlar ekranına ekler. (Ayarlar öne alındı,
Kaynaklar Kur'an'a bağlandı — emryldrmr, 2026-11-04.)

Kalan sıra (0001–0008 shipped; emryldrmr, 2026-11-07):
0009 her sayımda titreşim ayarı + yan menüde uygulama sürümü → 0010 sayma kolaylıkları (tam ekran
dokunma, ses tuşu, ekranı açık tut, büyük rakam, el yerleşimi) → 0011 Günün Esması kartı + kişisel Esma
notu → 0012 günlük geçmiş + seri (B-2 ile birlikte) → 0013 rozetler (4–6 sabit, seriye dayanır) → 0014
JSON yedekleme/geri yükleme → 0015 sabah hatırlatma bildirimi (sabit, dini metin içermeyen "Günün
zikrini çekmeyi unutma"; yeni izin → `docs/security.md`) → 0016 Kur'an + meal + Kaynaklar → 0017 Günün
Ayeti (0011 kartına ek). Numaralar sıra içindir; her biri spec yazılırken kesinleşir.

## Deliberately out of scope

Sürüm 1 için bilinçli olarak dışarıda:
- **Sürüm 2 adayları:** Kur'an'da yer imi / kaldığın yer; yazı boyutu, meal göster/gizle, mealde
  arama; Android ana ekran widget'ı (Günün Esması); huzurlu hatırlatıcılar (birden çok saat, mesaj
  yalnızca kaynaklı Esma/zikir metninden — kendi yazdığımız teselli metni yok, BR-12).
- **Sonraki adaylar (her biri ayrı karar ister):** ruh haline göre zikir önerisi (duygu→zikir
  eşleştirmesi dini yorumdur; yalnızca Diyanet/TDV kaynağı bulunursa, BR-12); kişisel hatim takibi; okunuş (transliterasyon) ve ayet/Esma görsel paylaşımı (hassas alan); kıraat
  dinleme (ses).
- **Önerilmiyor:** hesap/giriş, bulut senkronu, toplu hatim ve sosyal özellikler; namaz vakitleri/kıble
  (konum izni); iOS derlemesi ve mağaza süreci (ADR 0001); reklam (`specs/backlog.md` B-1);
  analitik/telemetri/crash raporlama.
