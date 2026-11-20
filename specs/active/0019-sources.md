# Spec 0019 — Kaynaklar sayfası

- Status: In progress
- Mode: lite
- Plan: `specs/plans/0019-plan.md`
- Self-critique: done

## Intent
Kullanıcı, uygulamada gördüğü dini metinlerin (Esmaü'l-Hüsna, Önerilen Zikirler, tesbihat) ve Arapça yazı tipinin
nereden geldiğini tek bir yerde görmek istiyor. Kaynakları açıkça anmak BR-12'nin de şartı. Başarı: Ayarlar'ın
sonundaki "Kaynaklar" girişi, her kaynağı adı, kullanım alanı ve kullanım koşuluyla ağ olmadan listeleyen bir
sayfa açar. Bu sayfa, Kur'an metni ekrana gelmeden önce Tanzil'in atıf şartını karşılayacak yeri de hazırlar.
Bilinçli olarak yapılmayanlar: Kur'an, meal ve AlQuran Cloud satırları (spec 0020 ekler), tıklanabilir adresler,
ekranlardaki mevcut kaynak satırlarının değişmesi. "Kur'an + meal + Kaynaklar" işinin bölünmüş ilk parçasıdır.
Kararlar S1–S7, ekran 1–8 tasarımı ve self-critique G1–G4 (emryldrmr, 2026-11-21) buraya katlandı.

## Requirements
1. **Giriş:** Ayarlar ekranının en sonunda, "Yedekleme" bölümünün altında "Hakkında" başlıklı yeni bir bölüm
   vardır. Bölümde tek satır bulunur: başlık "Kaynaklar", alt metin "Uygulamadaki dini metinlerin ve yazı tipinin
   kaynakları". Satıra dokununca Kaynaklar sayfası açılır. "Hakkında" kalıcı bir bölümdür; ileride uygulama
   hakkındaki başka satırlar da buraya gelebilir. Sürüm bilgisi yan menüde kalır (G4).
2. **Sayfa:** Üst çubukta "Kaynaklar" başlığı ve geri oku bulunur. Geri ok ya da sistem geri hareketi Ayarlar'a
   döner (spec 0005 ile tutarlı).
3. **Bölümler ve sıra:** Sayfa aşağıdaki bölümleri bu sırayla, her birini kendi başlığıyla gösterir. Metinler
   **birebir** buradaki gibidir (BR-12: değiştirilmez, kırpılmaz, normalleştirilmez):
   | Bölüm başlığı | Metin |
   |---|---|
   | Esmaü'l-Hüsna | Liste: Tirmizî, Daavât 82 — Diyanet sırası (Hadislerle İslâm, c. 1, s. 219) · Okunuş ve anlam: yasin.suresi.gen.tr · Arapça yazı: Amiri fontu |
   | Önerilen Zikirler | Okunuş, anlam ve sayılar: Diyanet, Hadislerle İslâm (c. 2) · Diyanet Aylık Dergi (Kasım 2024) · TDV İslâm Ansiklopedisi |
   | Tesbihat | Müslim, Mesâcid 146 (namaz sonrası 33 tesbih, 33 tahmid, 33 tekbir); yazım: Diyanet İşleri Başkanlığı. |
   | Yazı tipi | Amiri Quran — The Amiri Project Authors · SIL Open Font License 1.1 · github.com/aliftype/amiri |

   Esma ve Önerilen Zikirler metni, o ekranların altında bugün görünen kaynak satırıyla aynı metindir. İkisi
   ayrışamaz: biri değişirse diğeri de değişir. Tesbihat metni spec 0006'daki kaynak satırıdır. Yazı tipi satırı
   `assets/fonts/OFL.txt`'deki telif ve lisans bilgisidir. Esma metnindeki "Arapça yazı: Amiri fontu" ifadesi
   Yazı tipi bölümüyle tekrar etse de kırpılmaz (G1): metin, Esma ekranındakiyle aynı kalmalıdır.
4. **Adresler** düz metindir: dokunulunca bir şey olmaz, tarayıcı açılmaz.
5. **Ağ yok:** Sayfa tamamen uygulamanın içindeki metinden oluşur, internet olmadan aynen görünür.
6. **Mevcut satırlar korunur:** Esmaü'l-Hüsna ve Önerilen Zikirler ekranlarının altındaki kaynak satırları ve
   önerilen zikirlerin satır başı referansları olduğu gibi kalır.
7. **Genişleyebilirlik (davranış değil, kapsam notu):** Spec 0020, Kur'an bölümünü bu sayfanın en üstüne ekler.

## User experience
- **Flow:** Yan menü → Ayarlar → en alta kaydır → "Hakkında" altında "Kaynaklar" → Kaynaklar sayfası → geri →
  Ayarlar.
- **States:** Sayfanın tek durumu vardır: dolu. Metinler uygulamaya gömülü olduğu için boş, yükleniyor, hata ya
  da izin durumu yoktur. Açık ve koyu temada okunur (Ayarlar > Tema).
- **Design reference:** https://claude.ai/artifact/VQm29WVJFkwoMY7J7oPYnc, sürüm 3 (1795210359-cf13), ekran 7
  (Ayarlar girişi) ve ekran 8 (Kaynaklar sayfası). 0019'da Kur'an bölümü yoktur. Ekran 7'deki alt metin
  Gereksinim 1'deki metinle değişir: Kur'an henüz gelmediği için kaynak türlerini saymaz.
- **Accessibility:** Bölüm başlıkları ekran okuyucuya başlık olarak bildirilir. Metin, sistemin yazı boyutu
  ayarıyla büyür ve kesilmez: uzun satırlar alta kayar, sayfa kaydırılabilir. Renk karşıtlığı uygulamanın
  temasından gelir; ayrı renk yoktur.

## Constraints & out of scope
- `Sensitive area: Dini metin bütünlüğü` (kaynak gösterimi, `docs/domain.md`).
- Yeni paket ve yeni izin yok. Ağ yok.
- Split: "Kur'an + meal + Kaynaklar" üçe bölündü (S1, emryldrmr, 2026-11-21): 0019 Kaynaklar sayfası →
  0020 Kur'an + Diyanet meali (Kaynaklar'a Kur'an bölümünü ekler) → 0021 meal seçimi. 0021 isteğe bağlı değildir:
  **reklamdan önce şarttır.** Gerekçe: Diyanet'ten ticari izin alınamazsa varsayılan meal, telif süresi dolmuş ya
  da serbest lisanslı bir meale bir ayarla çevrilebilmeli (B-1).
- Kapsam dışı: Kur'an, meal ve AlQuran Cloud satırları (0020); tıklanabilir ya da kopyalanabilir adresler;
  lisans metinlerinin tamamını gösterme (Flutter'ın lisans sayfası dahil); Esma ve Önerilen Zikirler ekranlarındaki
  kaynak satırlarını değiştirmek ya da kaldırmak; Kaynaklar sayfasına yan menüden giriş.
- Font lisansı (G2): OFL, telif notunun ve lisansın fontla birlikte dağıtılmasını ister; `assets/fonts/OFL.txt`
  bugün APK'ya girmez. Plan, `AmiriQuran-Regular.ttf`'in bilgi alanlarında (copyright / license) bu notun olup
  olmadığını doğrular. Yoksa ayrı bir backlog kaydı açılır; 0019'un kapsamı büyümez.
- Docs: `docs/architecture.md`'deki "Kalan sıra" satırı 0019–0021 bölünmesiyle güncellenir (0018 shipped notu
  dahil). `docs/domain.md`'de BR-12'nin "Ayarlar > Kaynaklar" ifadesi zaten doğrudur, değişmez.

## Acceptance criteria
- [ ] AC-1 — Ayarlar'ın en sonunda, "Yedekleme" bölümünden sonra "Hakkında" başlığı ve altında "Kaynaklar" satırı
  alt metniyle görünür (Gereksinim 1).
- [ ] AC-2 — "Kaynaklar" satırına dokununca Kaynaklar sayfası açılır. Geri ok da sistem geri hareketi de
  Ayarlar'a döner.
- [ ] AC-3 — Sayfada dört bölüm başlığı Gereksinim 3'teki sırayla görünür: Esmaü'l-Hüsna, Önerilen Zikirler,
  Tesbihat, Yazı tipi.
- [ ] AC-4 — Her bölümün metni Gereksinim 3'teki tabloyla bayt bayt aynıdır. Tek bir harf değişikliği, bir
  şapka kaybı (â → a), Unicode normalleştirme (NFC → NFD), büyük harfe çevirme ya da baştaki veya sondaki
  boşluk testi düşürür.
- [ ] AC-5 — Esma ve Önerilen Zikirler bölümlerindeki metin, o ekranların altındaki kaynak satırıyla aynı
  metindir. Biri değişip diğeri değişmezse test düşer.
- [ ] AC-6 — Esmaü'l-Hüsna ve Önerilen Zikirler ekranlarının kaynak satırları ve önerilen zikirlerin satır başı
  referansları değişmemiştir (mevcut testler yeşil kalır).
- [ ] AC-7 — Sayfa ağ erişimi olmadan aynen görünür. Adreslere dokunmak hiçbir şey açmaz ve hata vermez.
- [ ] AC-8 — Bölüm başlıkları ekran okuyucuda başlık olarak bildirilir. Yazı ölçeği 2,0 kattayken (Android 14+ sistem
  üst sınırı; G3) hiçbir metin kesilmez ve sayfa sonuna kadar kaydırılabilir. Sayfa açık ve koyu temada görünür.

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
