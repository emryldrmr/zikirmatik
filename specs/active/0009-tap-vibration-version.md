# Spec 0009 — Her sayımda titreşim ve uygulama sürümü

- Status: In progress
- Mode: lite
- Plan: `specs/plans/0009-plan.md`
- Self-critique: done

## Intent
Ürün sahibi, kullanıcının her dokunuşta kısa bir titreşimle sayımı hissedebilmesini istiyor (ekrana
bakmadan, cebinde ya da karanlıkta sayarken). Bu, Ayarlar'da ayrı bir aç/kapa olur; mevcut "tur
tamamlanınca titreşim" ayarından bağımsızdır ve yeni kurulumda kapalıdır. Ayrıca yan menünün en altında
uygulamanın sürümü görünür, kullanıcı hangi sürümü kullandığını görebilsin (geri bildirimde,
güncellemeden sonra). Başarı: ayar açıkken her sayım kısa titreşir, kapalıyken davranış bugünküyle
aynıdır; menüde doğru sürüm yazar. Bilinçli olarak yapılmayan: titreşim şiddeti/süresi seçimi, belirli
sayılarda (ör. 33'te) ara titreşim. Dini metin içermez; hassas alanın dışındadır.

## Requirements
1. Ayarlar ekranında yeni bir "Her sayımda titreşim" aç/kapa ayarı vardır; yeni kurulumda ve bu sürüme
   güncellenen kurulumda kapalıdır. Mevcut ayarlar (titreşim, tema) güncellemede korunur.
2. Ayar açıkken sayımı 1 artıran her dokunuş kısa bir titreşim verir: Zikirlerim'deki sayaçta ve
   tesbihatta. Geri al, sıfırla ve tamamlanmış tesbihata dokunuş (sayım artmaz) titreşmez.
3. Bir dokunuş aynı anda turu tamamlıyorsa (BR-4, BR-13) ve "Titreşim" (tur) ayarı açıksa yalnızca tur
   titreşimi olur — iki titreşim üst üste gelmez. Tur ayarı kapalı, her sayım ayarı açıksa o dokunuş da
   kısa titreşir.
4. Ayar kapalıyken davranış spec 0004'teki gibidir; iki ayar birbirini değiştirmez.
5. Ayar kalıcıdır; okunamazsa kapalı kabul edilir (spec 0004, Req. 6 ile aynı tutum).
6. Titreşim verilemezse (cihaz desteklemiyor, hata) sayım yine de artar ve hata gösterilmez.
7. Yan menünün en altında uygulamanın kurulu sürümü "Sürüm 1.0.0" biçiminde görünür (yalnızca sürüm
   adı; yapı numarası yok). Sürüm okunamazsa satır görünmez, menü çalışmaya devam eder.

## User experience
- **Flow:** Yan menü → "Ayarlar" → "Her sayımda titreşim" anahtarını aç → Zikirlerim → her dokunuşta
  kısa titreşim → hedefe ulaşan dokunuşta tek (tur) titreşimi → Ayarlar → anahtarı kapat → dokunuşlar
  titreşimsiz. Yan menüyü aç → en altta "Sürüm 1.0.0".
- **States:**
  - *Ayarlar ekranı:* "Titreşim" satırının hemen altında "Her sayımda titreşim" satırı (alt metin "Her
    dokunuşta kısa titreşir", sağda anahtar); geri kalan ekran spec 0004'teki gibi.
  - *Yan menü:* mevcut beş giriş aynen; en altta, girişlerden ayrık, küçük ve soluk metinle sürüm satırı.
    Girişler ekrana sığmazsa sürüm satırı kaydırmayla erişilir, girişlerin üstüne binmez.
  - *Sürüm okunamadı:* sürüm satırı yok; menü aynen çalışır.
  - *Ayar okunamadı:* hata yok; "Her sayımda titreşim" kapalı görünür ve uygulanır.
- **Design reference:** none — the flow above is the design.
- **Accessibility:** anahtarın etiketi "Her sayımda titreşim" ve açık/kapalı durumu ekran okuyucuya
  bildirilir; anahtarın dokunma hedefi en az 48×48 dp; sürüm metni ekran okuyucuda "Sürüm 1.0.0" okunur,
  dokunulabilir değildir; iki temada da metin kontrastı en az 4.5:1.

## Constraints & out of scope
- Spec 0004'ün kriterleri aynen geçerlidir; "Titreşim" satırının alt metni ("Tur tamamlanınca
  titreşir") değişmez. 0002 AC-4, BR-4 ve BR-13 tur titreşimi için aynen geçerlidir.
- Sıra ve kapsam (emryldrmr, 2026-11-07): `docs/architecture.md` "Sürüm 1 kapsamı"nda kalan sıra bu
  spec'in dalında güncellenir; planlanan "ara titreşim" maddesi bu spec'le karşılanmış sayılır.
- Self-critique G1–G6 (emryldrmr, 2026-11-07): varsayılan kapalı; sayaç + tesbihat; tur dokunuşunda tek titreşim; okuma hatasında kapalı; "Sürüm x.y.z", okunamazsa gizli; ara titreşim bu spec’le karşılanır. Split: değerlendirildi, bölünmedi — emryldrmr, iki küçük yetenek.
- **Out of scope:** titreşim şiddeti/süresi/deseni seçimi; belirli sayılarda ara titreşim; ses (tık
  sesi); ayar kaydetme hatasının bildirilmesi (B-2); menüde lisans/hakkında sayfası.

## Acceptance criteria
- [ ] AC-1 — Ayarlar ekranında "Titreşim"in altında "Her sayımda titreşim" anahtarı görünür; yeni kurulumda kapalıdır. Önceki sürümden güncellenen veritabanında mevcut titreşim ve tema değerleri korunur, yeni ayar kapalıdır.
- [ ] AC-2 — Ayar açıkken Zikirlerim'de sayımı artıran her dokunuş bir kısa titreşim tetikler; ayar kapalıyken hiçbir dokunuş kısa titreşim tetiklemez.
- [ ] AC-3 — Ayar açıkken tesbihatta sayımı artıran her dokunuş kısa titreşim tetikler; tamamlanmış tesbihata dokunuş titreşim tetiklemez.
- [ ] AC-4 — Her sayım ve tur ayarı ikisi de açıkken turu tamamlayan dokunuş (sayaçta ve tesbihatta) yalnızca bir tur titreşimi tetikler; tur ayarı kapalı, her sayım ayarı açıkken aynı dokunuş bir kısa titreşim tetikler.
- [ ] AC-5 — Geri al ve sıfırla, ayar açıkken de titreşim tetiklemez.
- [ ] AC-6 — Ayar, uygulama yeniden başlatılınca (aynı kalıcı depoyla) aynen görünür ve uygulanır; ayarlar okunamazsa hata gösterilmez ve ayar kapalı kabul edilir.
- [ ] AC-7 — Titreşim hata verirse sayım yine 1 artar ve hata gösterilmez.
- [ ] AC-8 — Yan menünün en altında kurulu sürüm "Sürüm <sürüm adı>" olarak görünür (pubspec'teki 1.0.0 için "Sürüm 1.0.0"); sürüm okunamazsa satır görünmez ve beş giriş aynen çalışır.
- [ ] AC-9 — Erişilebilirlik: anahtar "Her sayımda titreşim" etiketiyle ve açık/kapalı durumuyla bildirilir, dokunma hedefi en az 48×48 dp; sürüm satırı "Sürüm 1.0.0" okunur; Ayarlar ve yan menüdeki yeni metinlerin kontrastı Açık ve Koyu temada en az 4.5:1.

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
