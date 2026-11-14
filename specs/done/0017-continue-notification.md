# Spec 0017 — Yarım kalan zikir bildirimi

- Status: Shipped
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
- Sensitive area: none (yok) — bildirim yalnız kullanıcının yazdığı zikir adını, sayıları ve uygulama metnini gösterir;
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
- [x] AC-1 — Ayar açık ve izin varken: hedefli zikirde (ör. "Sübhanallah", hedef 33) 5 dokunuştan sonra uygulama arka plana alınınca hemen başlığı "Sübhanallah: 5 / 33", gövdesi "Devam etmek için dokunun" olan bildirim görünür; son uygulamalardan kapatınca da görünür.
- [ ] ~~AC-1b — Ekran kilitlenince bildirim kilit ekranında da görünür (G4).~~ → moved to B-5 — emryldrmr, 2026-11-15, kanıtlanamadı: LOW önemli kanal kilit ekranında sistemce gizleniyor (elle gözlem O1)
- [x] AC-2 — Hedefsiz zikirde başlık "<Ad>: <sayım>" (ör. toplamı 12.345 olan hedefsiz zikirde "<Ad>: 12.345", binlik ayırıcılı); tesbihatta "Tesbihat · <n>. adım: <sayım> / <hedef>" (ör. 2. adımda 12 → "Tesbihat · 2. adım: 12 / 33"); tesbihat adım metni bildirimde yer almaz.
- [x] AC-3 — Bu açılışta hiç sayma dokunuşu yoksa (yalnız gezinme, seçim değiştirme, geri al ya da sıfırla) çıkışta bildirim çıkmaz; en son sayılan öğe sonradan sıfırlandıysa, tesbihatta "Baştan başla" yapıldıysa ya da silindiyse yeni dokunuşa kadar çıkmaz; tesbihat tamamlandıysa çıkmaz; ayar kapalıyken hiçbir koşulda çıkmaz.
- [x] AC-4 — Bildirim en son sayma dokunuşu yapılan öğeyi çıkıştaki değerleriyle gösterir (ör. A'da 3, sonra B'de 2 dokunuş → B; B'den sonra A seçilip dokunulmadan çıkılırsa yine B; A'da dokunup ardından geri al → A'nın geri alınmış değeri; hedefli zikirde turu tamamlayan dokunuştan sonra → "<Ad>: 0 / <hedef>"; tam ekran modundaki dokunuş da sayılır).
- [x] AC-5 — Aynı anda en fazla bir bildirim vardır: dönüp tekrar sayıp çıkınca yeni değerler eskisinin yerine geçer; bildirim ses ve titreşim üretmez, ekranın üstünde belirmez, kaydırarak kaldırılabilir.
- [x] AC-6 — Bildirime dokununca uygulama (kapalıyken başlatılarak ve arkadayken öne gelerek) Zikirlerim'de bildirimdeki zikir ya da tesbihat seçili ve bildirimdeki değerlerle açılır.
- [x] AC-7 — Uygulama herhangi bir yolla (bildirimle, simgeyle, son uygulamalardan) ön plana dönünce bildirim kaldırılır; ayar kapatılınca kaldırılır.
- [x] AC-8 — Ayarlar'da "Bildirimler" başlığı altında "Yarım kalan zikir bildirimi" anahtarı ve alt yazısı görünür; varsayılan kapalıdır; değer uygulama kapanıp açılınca korunur; diğer ayarlar ve sıraları değişmez.
- [x] AC-9 — İzin: izin gerektiren cihazda anahtar açılırken izin istenir (uygulama açılışında istenmez); verilirse anahtar açık kalır; reddedilirse anahtar kapalı kalır ve "Bildirim izni verilmedi. Telefonun ayarlarından açabilirsiniz." görünür; izin sonradan geri alınırsa bildirim çıkmaz ve Ayarlar'a dönülünce anahtar kapalı görünür.
- [x] AC-10 — Erişilebilirlik: ayar satırı tek öğe olarak başlık, alt yazı ve durumla okunur; izin mesajı duyurulur; en büyük yazı boyutunda ve 320 dp'de ayar metni kırpılmaz; açık ve koyu temada okunur.

## Definition of Done
- [x] Every acceptance criterion mapped to proof (test or reproducible observation)
- [x] `scripts/check` green
- [x] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [x] Docs / ADRs updated if behavior or architecture changed
- [x] Spec moved to `specs/done/` (it becomes immutable there)

## Scorecard (fill at ship — honest numbers make the process improvable)
| Metric | Value |
|---|---|
| Spec revisions | 1 (R-08 at ship: AC-1 lock screen part → B-5) |
| Fix rounds | 1 (fix-1: review round 1 F-1) |
| Review findings: real / noise / deferred | 1 / 0 / 1 (review round 1: F-1 High real, fixed in fix-1; review round 2: clean; device observation O1: lock screen → B-5, Medium; VERIFY: 2 Info, no action) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
Independent VERIFY (QA session, separate from the builder), 2026-11-15 @8332a15, after fix round 1 and review round 2 (clean); triage in `specs/plans/0017-plan.md` `## Triage`.
Full green: CHECK GREEN (full, 6 steps, 156 s) @c41b77d — local (433 tests; later commits change only specs/). CI `check` @8332a15: success. QA's own run of the 0017 test files: `+40: All tests passed!`. Residue: not required — `scripts/check.conf` unchanged.
Deliberate breaks: none — not a sensitive area, no concurrency / money / authorization / boundary criterion (plan R7); asserts read. `cold start cancels` shown red without the fix in review round 1 triage.
VERIFY notes (Info, no action): `continue details are silent and replaceable` asserts notification fields, not real silence — O2 proves the behavior; the plan's `## Build evidence` O1–O6 line predates the device observations recorded in `## Triage`.

| Acceptance criterion | Evidence | Status |
|---|---|---|
| AC-1 | `continue_notification_test.dart` — `hidden after taps shows target title`; `continue_text_test.dart` — `target title`; O1 (background, recent apps) | PASS |
| AC-1b | lock screen: no evidence — O1 shows it hidden (Xiaomi 2412DPC0AG, Android 16) | moved to B-5 (R-08) |
| AC-2 | `continue_text_test.dart` — `no target title with separator`, `tesbihat title has no step text`; `continue_notification_test.dart` — `no target and tesbihat titles` | PASS |
| AC-3 | `last_counted_test.dart` — `no counting tap gives nothing`, `reset restart delete clear`, `finished tesbihat gives nothing`; `continue_notification_test.dart` — `setting off shows nothing`, `nothing counted shows nothing`, `deleting the counted dhikr cancels` | PASS |
| AC-4 | `last_counted_test.dart` — `latest counted wins over selection`, `undo keeps the item`, `round completion shows zero`, `full screen tap counts` | PASS |
| AC-5 | `local_continue_notifier_test.dart` — `continue details are silent and replaceable`; `continue_notification_test.dart` — `second leave replaces`; O2 | PASS |
| AC-6 | `continue_notification_test.dart` — `tap opens the item warm`, `tap from another section opens Zikirlerim`, `launch payload opens the item cold`; O3 | PASS |
| AC-7 | `continue_notification_test.dart` — `shown cancels`, `cold start cancels`, `turning off cancels`; O6 | PASS |
| AC-8 | `notification_setting_test.dart` — `notifications section after theme, off by default`, `kept after restart`; `continue_notification_migration_test.dart` — `migrates a v9 database and keeps the settings`, `the continue notification survives reopening`; S-1 | PASS |
| AC-9 | `notification_setting_test.dart` — `asks on turning on, not at start`, `denied stays off with message`, `revoked shows off`; `continue_notification_test.dart` — `no permission shows nothing`; O4, O5; S-2, S-3, S-7 | PASS |
| AC-10 | `notification_setting_test.dart` — `one semantics node`, `denied message announced`, `largest text at 320 dp`, `light and dark`; O5 (TalkBack); S-4…S-6 | PASS |

UI: S-1 off by default light · S-2 on after grant · S-3 denied message light · S-4 on dark · S-5 denied message dark · S-6 320 dp largest text · S-7 revoked shows off — agent-captured (headless widget render, Roboto + Material icons), outside the repo; judged by emryldrmr at SHIP, 2026-11-15. Device observations O1–O6 by emryldrmr (Xiaomi 2412DPC0AG, Android 16), recorded in the plan's `## Triage`.
