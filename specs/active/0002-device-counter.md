# Spec 0002 — Cihaz sayaç ekranı

- Status: Approved
- Mode: lite
- Plan: `specs/plans/0002-plan.md`
- Self-critique: done

## Intent
Ürün sahibi, Zikirlerim ekranındaki sayacın, elde taşınan dijital zikirmatik cihazını andıran bir
görünüme geçmesini ve gerçek bir zikirmatiğin kurallarını kazanmasını istiyor: hedef belirleme, hedefe
ulaşınca titreşim ve tur tamamlama, geri alma, onaylı sıfırlama ve tüm zamanların toplamı. Başarı,
kullanıcının ekrana bakar bakmaz cihazı tanıması ve `docs/domain.md`'deki sayaç kurallarının (BR-2…BR-8)
tek zikir üzerinde eksiksiz çalışması demek. Bilinçli olarak yapılmayan: birden çok adlı zikir ve zikir
seçici (spec 0003), renk temaları, Ayarlar ve "ekranın her yerine dokunarak say" seçeneği (spec 0004).
Uygulama hiçbir hazır dini metin göstermez; iş hassas alanın dışındadır.

## Requirements
1. Zikirlerim ekranında, ortasında cihaz gövdesi olan bir sayaç gösterilir: sayımı gösteren LCD tarzı
   bir ekran, altında hedef/tur bilgisi ve toplam, küçük "geri al" ve "sıfırla" butonları ve büyük bir
   sayma butonu.
2. Sayma butonuna her dokunuş sayımı ve toplamı 1 artırır (BR-3). Cihazın başka bir yerine dokunmak saymaz.
3. Kullanıcı bir hedef seçebilir: hedef yok, 33, 99, 100 ya da 1–100000 arası özel bir sayı (BR-2).
4. Hedefli sayaçta sayım hedefe ulaşınca bir titreşim olur, tamamlanan tur sayısı 1 artar ve sayım 0'dan
   devam eder (BR-4). Hedefsiz sayaçta tur ve titreşim yoktur.
5. Geri al sayımı ve toplamı 1 azaltır; sayım 0 iken hiçbir şey değişmez (BR-5).
6. Sıfırlama onay ister; onaylanınca sayım ve tur 0 olur, toplam korunur (BR-6, BR-7).
7. Hedef değiştirmek, sayım ya da tur 0'dan büyükse onay ister; onaylanınca sayım ve tur 0 olur, toplam
   korunur, yeni hedef geçerli olur.
8. Sayım, tur, toplam ve hedef kalıcıdır (BR-8). Spec 0001'den kalan kayıtlı sayım kaybolmaz.
9. Spec 0001'in yükleniyor ve hata durumları aynen korunur; bu iki durumda hiçbir buton işlem yapmaz.

## User experience
- **Flow:** Zikirlerim'i aç → cihaz görünür → büyük butona dokun → LCD'deki sayım artar → "Hedef"e dokun
  → 33'ü seç → 33. dokunuşta titreşim, sayım 0, "Tur 1" → "geri al" ile son dokunuşu geri al →
  "sıfırla"ya dokun → onay penceresi → "Sıfırla" → sayım ve tur 0, toplam aynı.
- **States:**
  - *Yükleniyor / hata:* spec 0001'deki gibi (gösterge / "Sayaç yüklenemedi."); cihaz gösterilmez.
  - *Hedefsiz:* LCD sayımı gösterir; altında "Hedef yok" ve toplam.
  - *Hedefli:* LCD sayımı gösterir; altında "Hedef 33 · Tur 2" ve toplam.
  - *Sayım 0:* "geri al" devre dışı görünür.
  - *Sıfırlama onayı:* "Sayaç sıfırlansın mı?" — "Vazgeç" / "Sıfırla".
  - *Hedef seçimi:* seçenek listesi (Hedef yok, 33, 99, 100, Özel…); "Özel…" sayı girişi açar.
  - *Geçersiz özel hedef:* "1 ile 100.000 arasında bir sayı girin." uyarısı; kaydet devre dışı.
  - *Hedef değişikliği onayı:* "Hedef değişirse sayım ve tur sıfırlanır." — "Vazgeç" / "Değiştir".
- **Design reference:** none — the flow above and the sketch below are the design; özgün çizim, belirli
  bir markanın cihazı kopyalanmaz.
  ```
  ┌──────────────────────────────┐
  │ ≡  Zikirlerim                │
  │      ╭──────────────────╮    │
  │      │  ┌────────────┐  │    │
  │      │  │      33    │  │    │  LCD: sayım
  │      │  └────────────┘  │    │
  │      │ Hedef 33 · Tur 2 │    │  hedef/tur (dokununca hedef seçimi)
  │      │  Toplam 1.250    │    │
  │      │   ↶ geri al  ↺   │    │  küçük butonlar
  │      │     ╭──────╮     │    │
  │      │     │  ●   │     │    │  büyük sayma butonu
  │      │     ╰──────╯     │    │
  │      ╰──────────────────╯    │
  └──────────────────────────────┘
  ```
- **Accessibility:** sayma butonunun etiketi spec 0001'deki gibi güncel sayımı içerir ("Sayım 3. Saymak
  için dokunun."); "Geri al", "Sıfırla" ve "Hedef: 33" / "Hedef: yok" etiketleri; tüm dokunma hedefleri en
  az 48×48 dp; LCD rakamları ile arka planı arasında WCAG AA kontrast.

## Constraints & out of scope
- Platform ve yığın: `docs/conventions.md`; titreşim enjekte edilen `Haptics` arayüzüyle (Known traps).
- Spec 0001'in kriterleri geçerli kalır: "sayaç alanı" artık büyük sayma butonudur.
- Sayılar Türkçe biçimlenir (binlik ayırıcı nokta: 1.250).
- Self-critique G1–G10 (emryldrmr, 2026-11-02): yalnızca büyük buton sayar; sıfırlama küçük buton + onay (uzun basma yok); hedef seçenekleri yok/33/99/100/özel 1–100000; hedef değişikliği onaylı ve sayım+turu sıfırlar; tur geri alınmaz; 0001 sayımı N → sayım N, toplam N; titreşim yalnızca tur sonunda tek sefer; üst çubukta yalnızca menü ve başlık; LCD için yeni font yok (eşit genişlikli rakam, koyu yeşil panel); toplamın üst sınırı yok.
- **Out of scope:** adlı/çoklu zikir ve zikir seçici (0003); renk teması, Ayarlar, titreşimi kapatma,
  ara titreşim, tam ekran sayma, ses tuşuyla sayma, ekranı açık tutma (0004 ve sonrası); tesbihat;
  sayım kaydedilemediğinde gösterilecek davranış.
- Split: proposed 0002 cihaz sayaç ekranı → 0003 Zikirlerim → 0004 Görünüm ve Ayarlar; emryldrmr, 2026-11-02.

## Acceptance criteria
- [ ] AC-1 — Zikirlerim ekranında cihaz gösterilir: LCD sayımı, hedef/tur satırı, toplam, "geri al", "sıfırla" ve büyük sayma butonu; ilk açılışta hedef yok, sayım 0, toplam 0.
- [ ] AC-2 — Sayma butonuna 3 dokunuş (hızlı ardışık dahil) sayımı ve toplamı 3 artırır; cihazın buton dışındaki bir yerine dokunmak hiçbir şeyi değiştirmez.
- [ ] AC-3 — Hedef seçimi: "Hedef yok", 33, 99, 100 seçilebilir; "Özel…" ile 1 ve 100000 kabul edilir; 0, 100001, boş ve sayı olmayan giriş reddedilir ("1 ile 100.000 arasında bir sayı girin.") ve hedef değişmez.
- [ ] AC-4 — Hedef 33 iken sayım 32'den sonraki dokunuşta: titreşim tam bir kez tetiklenir, tur 1 artar, sayım 0 olur, toplam 1 artar; hedefsizken 33. dokunuşta titreşim olmaz ve sayım 33 olur.
- [ ] AC-5 — Geri al: sayım ve toplam 1 azalır; sayım 0 iken (tur tamamlandıktan hemen sonra dahil) hiçbir değer değişmez ve buton devre dışıdır.
- [ ] AC-6 — Sıfırla: onay penceresi açılır; "Sıfırla" sayımı ve turu 0 yapar, toplamı ve hedefi korur; "Vazgeç" hiçbir şeyi değiştirmez.
- [ ] AC-7 — Sayım veya tur 0'dan büyükken hedef değişikliği onay ister; "Değiştir" yeni hedefi uygular, sayım ve turu 0 yapar, toplamı korur; "Vazgeç" hedefi ve değerleri değiştirmez. Sayım ve tur 0 iken onay sorulmaz.
- [ ] AC-8 — Sayım, tur, toplam ve hedef uygulama yeniden başlatılınca (aynı kalıcı depoyla) aynen görünür; spec 0001'den kalan sayım N ise ilk açılışta sayım N, toplam N, hedef yok, tur 0'dır.
- [ ] AC-9 — Yükleniyor ve hata durumlarında cihaz yerine spec 0001'deki gösterge/mesaj görünür ve hiçbir sayaç değeri değişmez.
- [ ] AC-10 — Erişilebilirlik: sayma butonu "Sayım n. Saymak için dokunun.", geri al "Geri al", sıfırla "Sıfırla", hedef "Hedef: 33" / "Hedef: yok" etiketini taşır; her dokunma hedefi en az 48×48 dp; toplam Türkçe binlik ayırıcıyla gösterilir (1250 → "1.250").

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
