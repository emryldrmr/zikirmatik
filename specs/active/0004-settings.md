# Spec 0004 — Ayarlar

- Status: In progress
- Mode: lite
- Plan: `specs/plans/0004-plan.md`
- Self-critique: done

## Intent
Ürün sahibi, kullanıcının uygulamayı kendi kullanımına göre ayarlayabilmesini istiyor: tur tamamlanınca
gelen titreşimi kapatabilsin (sessiz ortamda, toplulukta) ve uygulamayı açık, koyu ya da telefonun
ayarına uyan temada kullanabilsin. Başarı, menüdeki "Ayarlar"ın artık "yakında" yerine bu iki ayarı
göstermesi, seçimlerin anında uygulanması ve uygulama yeniden açılınca korunması demek. Ayarlar ekranı
sonraki özelliklerin kendi ayarlarını ekleyeceği yerdir; bu spec onu iki ayarla açar. Bilinçli olarak
yapılmayan: Kaynaklar sayfası (Kur'an ve Esma spec'leriyle gelir — emryldrmr, 2026-11-04), renk paleti
seçimi, sürüm 1'deki diğer ayarlar (kendi özellikleriyle gelir). Dini metin içermez; hassas alanın
dışındadır.

## Requirements
1. Yan menüdeki "Ayarlar" girişi Ayarlar ekranını açar; ekranda "Titreşim" ve "Tema" ayarları vardır.
2. Titreşim açık ya da kapalı olabilir; yeni kurulumda açıktır. Kapalıyken hedefe ulaşıldığında
   titreşim olmaz; turun tamamlanması ve sayımın 0'a dönmesi aynen olur (BR-4).
3. Tema Açık, Koyu ya da Sistem olabilir; yeni kurulumda Sistem'dir. Sistem, telefonun açık/koyu
   ayarını izler. Seçilen tema hemen bütün uygulamaya uygulanır.
4. Zikirmatik cihazının kendi görünümü (gövde, ekran, buton) temadan etkilenmez; yalnızca çevresi değişir.
5. İki ayar da kalıcıdır: uygulama kapanıp açılınca aynen görünür ve uygulanır; uygulama kaydedilen
   temayla açılır.
6. Ayarlar okunamazsa uygulama varsayılanlarla (titreşim açık, tema Sistem) çalışmaya devam eder.

## User experience
- **Flow:** Yan menü → "Ayarlar" → "Titreşim" anahtarını kapat → Zikirlerim'e dön → hedefe ulaş →
  titreşim yok, tur 1 artar → Ayarlar → Tema "Koyu" → uygulama hemen koyu → uygulamayı kapat/aç →
  koyu tema ve kapalı titreşim aynen.
- **States:**
  - *Ayarlar ekranı:* başlık "Ayarlar"; "Titreşim" satırı (alt metin "Tur tamamlanınca titreşir",
    sağda açık/kapalı anahtarı); "Tema" başlığı altında üç seçenek: "Açık", "Koyu", "Sistem" — seçili
    olan işaretli.
  - *Açık tema / Koyu tema:* menü, Zikirlerim (seçici, boş durum dahil), Ayarlar ve "yakında"
    ekranları seçilen temada; zikirmatik cihazı her iki temada aynı.
  - *Yükleniyor:* uygulama açılırken ayarlar okunana kadar kısa bir yükleniyor ekranı (spec 0001'deki
    gibi); ardından içerik kaydedilen temayla görünür.
  - *Ayarlar okunamadı:* hata gösterilmez; varsayılanlar kullanılır ve Ayarlar ekranı onları gösterir.
- **Design reference:** none — the flow above is the design; koyu tema Material 3'ün koyu şemasıdır
  (mevcut teal tohum rengiyle).
- **Accessibility:** anahtarın etiketi "Titreşim" ve açık/kapalı durumu ekran okuyucuya bildirilir;
  tema seçeneklerinde seçili olan "seçili" okunur; tüm dokunma hedefleri en az 48×48 dp; iki temada da
  metin kontrastı en az 4.5:1.

## Constraints & out of scope
- Spec 0001 AC-7 ("Zikirlerim dışındaki her giriş 'Bu bölüm yakında.' gösterir") Ayarlar için artık
  geçerli değildir; Önerilen Zikirler, Esmaü'l-Hüsna ve Kur'an için aynen geçerlidir. Bu yüzden
  `shell_test.dart`'taki "yakında" döngüsü Ayarlar'ı dışarıda bırakacak şekilde daralır — bilinçli
  davranış değişikliğidir, test zayıflatma değildir; Ayarlar'ın yeni davranışı AC-1 ile kanıtlanır.
- Self-critique G1–G7 (emryldrmr, 2026-11-04): ayarlar okunana kadar yükleniyor, sonra kaydedilen tema;
  okuma hatasında sessizce varsayılanlar; kaydetme hatası B-2'de; Sistem modunda canlı geçiş; alt metin
  "Tur tamamlanınca titreşir"; kontrast en az 4.5:1. Split: proposed titreşim ve tema ayrı spec'ler;
  kept as one — emryldrmr, aynı ekran ve aynı ayar deposu.
- Spec 0001, 0002 ve 0003'ün diğer kriterleri aynen geçerli kalır (titreşim açıkken 0002 AC-4 değişmez).
- Sıra kararı (emryldrmr, 2026-11-04): Ayarlar, `docs/architecture.md` "Sürüm 1 kapsamı"ndaki sıradan
  öne alındı; o bölüm bu spec'le güncellenir.
- **Out of scope:** Kaynaklar sayfası (BR-12 — Kur'an/Esma spec'leri); renk paleti / vurgu rengi
  seçimi; ara titreşim, büyük rakam, el yerleşimi, ses tuşuyla sayma, ekranı açık tut, varsayılan meal
  (her biri kendi özelliğiyle); ayar kaydetme hatasının kullanıcıya bildirilmesi (B-2'nin kapsamı);
  tesbihat titreşimi (BR-13 kendi spec'inde bu ayara uyar).

## Acceptance criteria
- [ ] AC-1 — Yan menüden "Ayarlar"a dokununca başlığı "Ayarlar" olan ekran açılır; "Titreşim" anahtarı ve "Açık", "Koyu", "Sistem" tema seçenekleri görünür, "Bu bölüm yakında." görünmez. Yeni kurulumda Titreşim açık, Tema "Sistem" seçilidir.
- [ ] AC-2 — Titreşim kapalıyken hedefli zikirde sayım hedefe ulaşınca titreşim tetiklenmez; tur 1 artar ve sayım 0 olur. Tekrar açılınca bir sonraki tur tamamlanmasında titreşim tetiklenir.
- [ ] AC-3 — "Koyu" seçilince uygulama hemen koyu temaya, "Açık" seçilince açık temaya geçer; "Sistem" seçiliyken uygulama telefonun açık/koyu ayarını izler ve telefon ayarı değişince uygulama da değişir.
- [ ] AC-4 — Zikirmatik cihazının gövde, ekran ve buton renkleri Açık ve Koyu temada aynıdır.
- [ ] AC-5 — Titreşim ve tema seçimi uygulama yeniden başlatılınca (aynı kalıcı depoyla) aynen görünür; uygulama içeriği kaydedilen temayla açılır.
- [ ] AC-6 — Ayarlar okunamazsa hata gösterilmez; titreşim açık ve tema Sistem olarak çalışılır ve Ayarlar ekranı bu değerleri gösterir.
- [ ] AC-7 — Ayarlar ekranından yan menüyle Zikirlerim'e dönülünce seçili zikir ve değerleri değişmemiştir; Önerilen Zikirler, Esmaü'l-Hüsna ve Kur'an hâlâ "Bu bölüm yakında." gösterir.
- [ ] AC-8 — Erişilebilirlik: Titreşim anahtarının etiketi "Titreşim" ve açık/kapalı durumu bildirilir; seçili tema seçeneği ekran okuyucuya seçili olarak bildirilir; Ayarlar ekranındaki tüm dokunma hedefleri en az 48×48 dp; Açık ve Koyu temada Ayarlar ekranı ve Zikirlerim'deki metinlerin kontrastı en az 4.5:1.

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
