# Domain

> Bootstrap 2026-11-02 ile dolduruldu. İş, insanlar ve ajanlar arasındaki ortak dil.
> Bir terim burada yoksa, yapay zekânın kendi anlamını uyduracağını varsay.

## Ubiquitous language
<!-- Satır başına bir terim. Aynı kelime = her yerde aynı anlam: kod, spec, konuşma. -->

| Term | Meaning | Notes / not to be confused with |
|---|---|---|
| Zikir (`Dhikr`) | Kullanıcının tanımladığı sayılacak kayıt: ad + isteğe bağlı hedef. | "Önerilen zikir" ile aynı şey değil; önerilen zikir eklenince kullanıcının zikri olur. |
| Sayım (`count`) | Zikrin **mevcut turdaki** sayısı. | Toplam değildir; tur tamamlanınca 0'dan devam eder. |
| Hedef (`target`) | Bir turun tamamlanması için gereken sayım. İsteğe bağlı. | Hedefsiz zikirde tur yoktur. |
| Tur (`round`) | Sayımın hedefe ulaşmasıyla tamamlanan bir döngü. | "Tamamlanan tur sayısı" (`roundsCompleted`) zikir başına tutulur. |
| Toplam (`total`) | Zikrin tüm zamanlardaki toplam sayımı. | Sıfırlama sayımı ve turu sıfırlar; toplamın davranışı BR-7'de. |
| Geri al (`undo`) | Sayımı 1 azaltan işlem. | Turu geri almaz (BR-5). |
| Önerilen zikir (`SuggestedDhikr`) | Uygulamaya gömülü, anlamı ve önerilen hedefiyle hazır zikir. | Salt okunur içerik; hassas alan. |
| Esma (`AsmaName`) | Esmaü'l-Hüsna'daki 99 isimden biri: sıra no, Arapça, okunuş, anlam. | Gömülü içerik; hassas alan. Zikir olarak eklenebilir. |
| Sure (`Surah`) | Kur'an'ın 114 bölümünden biri (1–114). | |
| Ayet (`Ayah`) | Bir surenin ayeti; kimliği **(sure no, ayet no)** çiftidir. | Global ayet indeksiyle (1–6236) karıştırılmaz; o yalnızca API adaptörünün içinde kalır. |
| Meal (`Translation`) | Bir ayetin Türkçe çevirisi; kaynağı (çevirmen/yayıncı) ile birlikte. | Tefsir değildir. Ayetle birebir hizalanır. |
| Önbellek (`QuranCache`) | API'den indirilip doğrulanmış, cihazda saklanan Kur'an + meal verisi. | Doğrulanmamış veri önbellek sayılmaz (BR-11). |

## Business rules

- **BR-1:** Zikir adı zorunludur; baştaki/sondaki boşluk kırpıldıktan sonra 1–50 karakter.
- **BR-2:** Hedef isteğe bağlıdır; verilirse 1–100000 arası tam sayıdır.
- **BR-3:** Her dokunuş sayımı ve toplamı 1 artırır.
- **BR-4:** Hedefli zikirde sayım hedefe ulaştığı anda: titreşim tetiklenir, tamamlanan tur sayısı
  1 artar, sayım 0 olur. (Titreşim Ayarlar'dan kapatılabilir; kapalıysa diğer etkiler aynen olur.)
- **BR-5:** Geri al sayımı ve toplamı 1 azaltır; sayım 0 ise hiçbir şey değişmez (sayım 0'ın altına
  inmez, tamamlanmış tur geri alınmaz).
- **BR-6:** Sıfırlama ve zikir silme kullanıcı onayı olmadan gerçekleşmez.
- **BR-7:** Sıfırlama sayımı ve tamamlanan tur sayısını 0 yapar; toplam korunur.
- **BR-8:** Sayaç durumu her değişiklikte kalıcı saklanır; uygulama kapanıp açılınca aynı değerler görünür.
- **BR-9:** Önerilen zikir ya da Esma, tek dokunuşla Zikirlerim'e eklenir (adı ve önerilen hedefiyle).
- **BR-10:** Kur'an ve meal ilk kullanımda indirilir ve önbelleğe yazılır; sonrasında ağ olmadan gösterilir.
- **BR-11:** İndirilen veri önbelleğe yazılmadan doğrulanır (114 sure, toplam 6236 ayet, her ayetin
  meali birebir hizalı). Doğrulamayı geçmeyen veri reddedilir, hiçbir kısmı yazılmaz.
- **BR-12:** Kur'an metni, meal, Esma ve önerilen zikir metni gösterilirken değiştirilmez, kırpılmaz,
  normalleştirilmez. Kaynaklar Ayarlar > Kaynaklar'da anılır (Tanzil, AlQuran Cloud, meal sahibi, Amiri fontu).

## Key domain invariants

- Sayım, tur sayısı ve toplam asla negatif olmaz.
- Hedefli zikirde sayım her zaman hedeften küçüktür (hedefe ulaşan sayım aynı işlemde tura dönüşür).
- Ekranda gösterilen her meal, gösterildiği ayetin (sure, ayet) mealidir — kayma asla olmaz.
- Önbellekteki Kur'an verisi ya tam ve doğrulanmıştır ya da hiç yoktur.

## Sensitive areas

- **Dini metin bütünlüğü** — Kur'an ayetleri, mealler, Esmaü'l-Hüsna ve önerilen zikirlerin metni,
  anlamı, sırası, hizası ve kaynak gösterimi. Bu alana dokunan spec Constraints'te
  `Sensitive area: Dini metin bütünlüğü` yazar. Bu alana dokunan hiçbir değişiklik — tek harf bile
  olsa — trivial sayılmaz.
