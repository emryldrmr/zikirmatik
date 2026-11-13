# Spec 0017 — Yarım kalan zikir bildirimi

- Status: Approved
- Mode: lite
- Plan: `specs/plans/0017-plan.md`
- Self-critique: done

## Intent
Kullanıcı zikir çekmeye başlayıp uygulamadan çıktığında (başka uygulamaya geçti, ana ekrana döndü) kaldığı yeri
unutmasın ve tek dokunuşla geri dönebilsin istiyor. Uygulamadan çıkıldığı anda, en son sayılan zikrin ya da
tesbihatın adını ve mevcut sayısını gösteren sessiz bir bildirim çıkar; bildirime dokununca uygulama o sayaçla
açılır. Başarı: bildirim yalnız gerçekten sayım yapılmışsa çıkar, gösterdiği değerler doğrudur, üst üste birikmez,
uygulamaya dönünce kaybolur ve kullanıcı Ayarlar > Bildirimler'den kapatabilir. Bilinçli olarak yapılmayan: günlük
hatırlatma, seri hatırlatması (0018), bildirimden sayma ("+1" düğmesi), sesli/titreşimli bildirim.
Kararlar D1–D8 (emryldrmr, 2026-11-14) buraya katlandı.

## Requirements
1. **Tetik:** uygulama bu açılışından beri (uygulama başlatıldığından beri) sayaçta en az bir **sayma dokunuşu**
   (sayımı artıran dokunuş, BR-3; zikir ya da tesbihat) olduysa ve uygulama ön plandan çıkarsa (arka plana
   alınırsa ya da son uygulamalardan kapatılırsa) bildirim hemen gösterilir. Geri al, sıfırla, seçim değiştirme
   ya da yalnız gezinme tetik sayılmaz. Sayma dokunuşu tam ekran sayma modunda da sayılır (G5). Hedefli, hedefsiz
   zikir ve tesbihat için aynı kural geçerlidir (D1, D2). Ekran kilitlenmesi de ön plandan çıkıştır; bildirim kilit
   ekranında da görünür (G4).
2. **Neyi gösterir:** en son sayma dokunuşu yapılan zikri ya da tesbihatı, **çıkış anındaki** değerleriyle (D3).
   **İstisnalar:** o öğe son dokunuşundan sonra sıfırlandıysa (tesbihatta "Baştan başla" / "Sıfırla") ya da
   silindiyse, yeni bir sayma dokunuşu olana kadar bildirim çıkmaz (G1); tesbihat tamamlandıysa bildirim çıkmaz
   (G2). Hedefli zikirde tur tamamlanıp sayım 0'a döndüyse bildirim çıkar ("<Ad>: 0 / <hedef>", G2).
3. **Metin (D4):** başlık + tek satır gövde; sayılar binlik ayırıcılıdır (0014 G2):
   - Hedefli zikir: başlık "<Ad>: <sayım> / <hedef>"
   - Hedefsiz zikir: başlık "<Ad>: <sayım>"
   - Tesbihat: başlık "Tesbihat · <n>. adım: <sayım> / <adım hedefi>"
   - Gövde (hepsinde): "Devam etmek için dokunun"
   Zikir adı kullanıcının yazdığı gibidir (BR-1); tesbihat adımının dini metni bildirimde gösterilmez.
4. **Tek bildirim, sessiz (D5):** aynı anda en fazla bir yarım kalan zikir bildirimi vardır; yenisi eskisinin
   yerine geçer. Ses çıkarmaz, titreşmez, ekranın üstünde belirmez (yalnız bildirim çekmecesinde ve durum
   çubuğunda görünür); kullanıcı kaydırarak kaldırabilir.
5. **Dokununca (D6):** uygulama açılır (kapalıysa başlatılır, arkadaysa öne gelir) ve Zikirlerim'de bildirimdeki
   zikir ya da tesbihat seçili olarak görünür; değerler bildirimdekiyle aynıdır.
6. **Kaybolma (D7):** uygulama herhangi bir yolla ön plana döndüğünde, ayar kapatıldığında ve bildirimdeki zikir
   artık yoksa (silindi) bildirim kaldırılır.
7. **Ayar (D8):** Ayarlar'da yeni "Bildirimler" başlığı altında "Yarım kalan zikir bildirimi" anahtarı vardır
   (alt yazı: "Saymaya başlayıp uygulamadan çıkınca kaldığınız yeri gösterir"). Varsayılan **kapalı** (G3). Değer
   kalıcı saklanır (BR-8). 0018'in günlük hatırlatma ayarları da bu başlığa gelecektir.
8. **İzin (D8):** cihaz bildirim izni gerektiriyorsa (Android 13 ve sonrası) izin, anahtar açılırken istenir;
   uygulama açılışında ya da başka bir anda istenmez. İzin verilmezse anahtar kapalı kalır ve "Bildirim izni
   verilmedi. Telefonun ayarlarından açabilirsiniz." mesajı görünür. İzin sonradan telefon ayarlarından geri
   alınırsa bildirim gösterilmez ve Ayarlar'a dönüldüğünde anahtar kapalı görünür.

## User experience
- **Flow:** Ayarlar → Bildirimler → "Yarım kalan zikir bildirimi" açık (gerekirse izin onayı) → Zikirlerim'de
  sayma → ana ekrana çıkış → bildirim çekmecesinde "<Ad>: 5 / 33 · Devam etmek için dokunun" → dokunuş →
  uygulama Zikirlerim'de o zikirle açılır → bildirim kaybolur.
- **States:**
  - *Ayar kapalı:* hiçbir koşulda bildirim yok.
  - *Ayar açık, bu açılışta sayma yok:* çıkışta bildirim yok.
  - *Ayar açık, sayma var:* çıkışta bildirim (hedefli / hedefsiz / tesbihat metni).
  - *İzin isteniyor:* sistem izin penceresi; sonuç gelene kadar anahtar kapalı görünür.
  - *İzin reddedildi / geri alındı:* anahtar kapalı + izin mesajı; bildirim yok.
  - *Bildirim varken uygulamaya dönüş:* bildirim kaldırılır.
- **Design reference:** none — the flow above is the design. Bildirimin görünümü Android'in standart bildirim
  görünümüdür (uygulama simgesi + başlık + gövde).
- **Accessibility:** ayar satırı tek ekran okuyucu öğesidir (başlık, alt yazı, açık/kapalı durumu); izin mesajı
  ekran okuyucuya duyurulur; bildirim başlığı ve gövdesi düz metindir (sistem ekran okuyucusu okur); en büyük yazı
  boyutunda ve 320 dp'de ayar metni kırpılmaz; açık ve koyu temada okunur.

## Constraints & out of scope
- Sensitive area: yok — bildirim yalnız kullanıcının yazdığı zikir adını, sayıları ve uygulama metnini gösterir;
  dini metin (tesbihat adım metni, Esma, önerilen zikir) bildirimde gösterilmez.
- **Yeni Android izni:** `POST_NOTIFICATIONS`. `docs/security.md`'deki "yalnızca INTERNET ve VIBRATE" maddesi bu
  spec'le güncellenir; ekleme planda insan onayı gerektirir. Bildirim yereldir: sunucu, Firebase, ağ yok; veri
  cihazdan çıkmaz.
- **Yeni paket:** bildirim göstermek için bir paket gerekirse planda gerekçesiyle, insan onayıyla eklenir
  (`docs/security.md`, Dependencies).
- Mevcut sayma davranışı (BR-3…BR-8, 0006, 0014) değişmez; bildirim yalnız okur, sayımı değiştirmez.
- Roadmap (emryldrmr, 2026-11-14): bildirimler JSON yedeklemenin önüne alındı — 0017 yarım kalan zikir bildirimi →
  0018 günlük hatırlatma (Günün Esması / önerilen zikir, Ayarlar'da aç/kapa + seçim) + seri hatırlatması → JSON
  yedekleme → Kur'an + meal + Kaynaklar → Günün Ayeti. `docs/architecture.md` sırası build'de güncellenir.
- **Clarify kararları (lite, emryldrmr, 2026-11-14):** D1 tetik: bu açılışta en az bir sayma dokunuşu + ön plandan
  çıkış, hemen · D2 hedefli, hedefsiz, tesbihat hepsi · D3 en son sayılan öğe, çıkıştaki değerler · D4 metinler
  yukarıdaki gibi · D5 tek, sessiz, kaldırılabilir · D6 dokununca o sayaç · D7 dönünce kaybolur · D8 Ayarlar >
  Bildirimler'de aç/kapa, izin anahtar açılırken.
- **Self-critique (emryldrmr, 2026-11-14):** G1 sıfırlama / baştan başla / silme sonrası yeni dokunuşa kadar
  bildirim yok · G2 tamamlanan tesbihatta yok; hedefli zikirde tur tamamlanınca "0 / hedef" ile var · G3 ayar
  varsayılan kapalı · G4 ekran kilidi çıkış sayılır, kilit ekranında görünür · G5 tam ekran modundaki dokunuş da
  sayılır.
- **Out of scope:** günlük hatırlatma ve seri hatırlatması (0018); bildirimden sayma / "+1" ya da başka düğme;
  sesli/titreşimli bildirim; birden çok bildirim; telefon yeniden başlayınca bildirimin geri gelmesi; tam ekran
  sayma modunun bildirimle açılması (Zikirlerim'in normal görünümü açılır); bildirim metninin özelleştirilmesi.

## Acceptance criteria
- [ ] AC-1 — Ayar açık ve izin varken: hedefli zikirde (ör. "Sübhanallah", hedef 33) 5 dokunuştan sonra uygulama arka plana alınınca hemen başlığı "Sübhanallah: 5 / 33", gövdesi "Devam etmek için dokunun" olan bildirim görünür; son uygulamalardan kapatınca ve ekran kilitlenince de görünür.
- [ ] AC-2 — Hedefsiz zikirde başlık "<Ad>: <sayım>" (ör. toplamı 12.345 olan hedefsiz zikirde "<Ad>: 12.345", binlik ayırıcılı); tesbihatta "Tesbihat · <n>. adım: <sayım> / <hedef>" (ör. 2. adımda 12 → "Tesbihat · 2. adım: 12 / 33"); tesbihat adım metni bildirimde yer almaz.
- [ ] AC-3 — Bu açılışta hiç sayma dokunuşu yoksa (yalnız gezinme, seçim değiştirme, geri al ya da sıfırla) çıkışta bildirim çıkmaz; en son sayılan öğe sonradan sıfırlandıysa, tesbihatta "Baştan başla" yapıldıysa ya da silindiyse yeni dokunuşa kadar çıkmaz; tesbihat tamamlandıysa çıkmaz; ayar kapalıyken hiçbir koşulda çıkmaz.
- [ ] AC-4 — Bildirim en son sayma dokunuşu yapılan öğeyi çıkıştaki değerleriyle gösterir (ör. A'da 3, sonra B'de 2 dokunuş → B; B'den sonra A seçilip dokunulmadan çıkılırsa yine B; A'da dokunup ardından geri al → A'nın geri alınmış değeri; hedefli zikirde turu tamamlayan dokunuştan sonra → "<Ad>: 0 / <hedef>"; tam ekran modundaki dokunuş da sayılır).
- [ ] AC-5 — Aynı anda en fazla bir bildirim vardır: dönüp tekrar sayıp çıkınca yeni değerler eskisinin yerine geçer; bildirim ses ve titreşim üretmez, ekranın üstünde belirmez, kaydırarak kaldırılabilir.
- [ ] AC-6 — Bildirime dokununca uygulama (kapalıyken başlatılarak ve arkadayken öne gelerek) Zikirlerim'de bildirimdeki zikir ya da tesbihat seçili ve bildirimdeki değerlerle açılır.
- [ ] AC-7 — Uygulama herhangi bir yolla (bildirimle, simgeyle, son uygulamalardan) ön plana dönünce bildirim kaldırılır; ayar kapatılınca kaldırılır.
- [ ] AC-8 — Ayarlar'da "Bildirimler" başlığı altında "Yarım kalan zikir bildirimi" anahtarı ve alt yazısı görünür; varsayılan kapalıdır; değer uygulama kapanıp açılınca korunur; diğer ayarlar ve sıraları değişmez.
- [ ] AC-9 — İzin: izin gerektiren cihazda anahtar açılırken izin istenir (uygulama açılışında istenmez); verilirse anahtar açık kalır; reddedilirse anahtar kapalı kalır ve "Bildirim izni verilmedi. Telefonun ayarlarından açabilirsiniz." görünür; izin sonradan geri alınırsa bildirim çıkmaz ve Ayarlar'a dönülünce anahtar kapalı görünür.
- [ ] AC-10 — Erişilebilirlik: ayar satırı tek öğe olarak başlık, alt yazı ve durumla okunur; izin mesajı duyurulur; en büyük yazı boyutunda ve 320 dp'de ayar metni kırpılmaz; açık ve koyu temada okunur.

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
