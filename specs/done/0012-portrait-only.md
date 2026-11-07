# Spec 0012 — portrait only (mini)

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0012-plan.md`
- Self-critique: done
- Source: B-5 (`specs/backlog.md`; spec 0011 VERIFY G-5)
- Design: — (yeni ekran yok; mevcut dikey görünüm aynen kalır)
- Supersedes: 0011/AC-4 (yalnız "yan çevrilmiş ekranda" kısmı), 0011/AC-5 (yalnız "ve yan" kısmı), 0011/AC-8 (yalnız "ve yan" kısmı); 0010/AC-5'in yatay testleri (`full screen step text stays readable sideways and large`, `full screen fits sideways with large text`) kanıt olmaktan çıkar. B-4 bununla kapanır.

## Intent
Telefon yan çevrildiğinde ekranlar bozuluyor (Xiaomi, Android 16'da gözlendi). Uygulama yatay
görünümü düzeltmek yerine hep dikey kalacak: yatay mod hiç olmayacak. Böylece kullanıcı sayarken
telefonu nasıl tutarsa tutsun düzen bozulmaz.

## Changed behavior
- [x] CB-1 — Uygulama açılışta ekran yönünü yalnız dikeye (portrait up) kilitler; telefon yan ya da baş aşağı çevrilse de hiçbir ekran (sayaç, tam ekran, Zikirlerim, Önerilen, Esma, Kur'an, Ayarlar) dönmez.
- [x] CB-2 — Android manifest'te ana aktivite dikey yöne kilitlidir (`android:screenOrientation="portrait"`), böylece açılışın ilk karesinde de yatay görünüm oluşmaz.
- [x] CB-3 — Yatay ekran kabul kriteri yoktur: 0011 AC-4/5/8 ve 0010 AC-5'in yan çevrilmiş ekran testleri kaldırılmaz, dikey karşılıkları zaten var olduğundan yatay parametreleri çıkarılır ya da dikeye indirilir; dikey ve büyük sistem yazısı (2×) kapsamı aynen kalır (test zayıflatma değil, kapsam değişikliği — Supersedes satırı kaydıdır).

## Preserved behavior
- [x] PB-1 — Dikey ekranda tüm ekranlar bugünkü gibi görünür ve çalışır: sayaç, tam ekran, Büyük rakam / el yerleşimi (0011), ekranı açık tut (0010), titreşim (0009).
- [x] PB-2 — Dikey ekranda sayım rakamı ve tesbihat adım metni büyük sistem yazısında (2×) kesilmez, "…" içermez (0011 AC-4/AC-8'in dikey kısmı; 0010 AC-5).
- [x] PB-3 — Dar dikey ekranda el yerleşimi cihazı ortada tutar, cihaz ekrandan taşmaz (0011 AC-5'in dikey kısmı).
- [x] PB-4 — Dini metin (Kur'an, meal, Esma, önerilen zikir, tesbihat) hiçbir şekilde değişmez.

## Out of scope
- Yatay düzeni düzeltmek (yatay mod hiç olmayacak).
- Tablet / iOS için ayrı yön davranışı.
- Ortada yerleşimi ve kısa bilgi satırlarının yeniden tasarımı (B-4'ün yatay kısmı bu kilitle anlamsızlaşır; dikey küçük ekranda benzer sorun görülürse ayrı iş).

## Definition of Done
- [x] `scripts/check` green
- [x] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [x] Criterion ↔ evidence table complete for CB-* **and** PB-* (UI: before/after screenshots, agent-captured, judged at SHIP)
- [x] Spec moved to `specs/done/` (immutable there)

## Scorecard (fill at ship — honest numbers make the process improvable)
| Metric | Value |
|---|---|
| Spec revisions | 0 |
| Fix rounds | 0 |
| Review findings: real / noise / deferred | 0 / 0 / 0 (round 1 clean) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
QA oturumu, 2026-11-08 @7ee0d3c. Review: bir bağımsız reviewer turu, verdict clean; triage `specs/plans/0012-plan.md` `## Triage`.
Full green: CI run 42417682355 @77743e7 (success); build CHECK GREEN (full, 6 steps, 125 s) @99428e1; sonraki commit'ler yalnız `specs/` değiştirir.
Kasıtlı kırmalar (repo dışında geçici kopya, hepsi kırmızı): K1 `lockPortrait` listesine `landscapeLeft` (CB-1); K2 manifest'ten `screenOrientation` silindi (CB-2); K3 Esma 1 okunuşu `Allah`→`Alah` (PB-4, hassas alan).

| Acceptance criterion | Evidence | Status |
|---|---|---|
| CB-1 | `orientation_test.dart` — `the app locks to portrait`; kırma K1; telefon (Xiaomi, Android 16) `cmd window user-rotation lock 1`: HEAD `mCurrentRotation=ROTATION_0`, `requestedOrientation=SCREEN_ORIENTATION_PORTRAIT` — main `ROTATION_90`, `UNSPECIFIED`; S-1, S-2 | PASS |
| CB-2 | `orientation_test.dart` — `the manifest locks the activity to portrait`; kırma K2 | PASS |
| CB-3 | diff (review round 1): yalnız boyut listeleri, test adları ve yorumlar; hiçbir `expect` değişmedi; dikeye inen testler yeşil | PASS |
| PB-1 | `display_options_test.dart`, `full_screen_test.dart`, `settings/` takımı yeşil; S-3, S-4 (dikey önce/sonra aynı) | PASS |
| PB-2 | `display_options_test.dart` — `the count is never cut`; `tesbihat_text_test.dart` | PASS |
| PB-3 | `display_options_test.dart` — `a narrow screen keeps the device centred` | PASS |
| PB-4 | `test/integrity/` (17 test) yeşil; kırma K3; diff'te dini metin dosyası yok | PASS |

UI: S-1…S-4 agent-captured (telefon, adb screencap: önce/sonra × dikey/yan), judged by emryldrmr at SHIP, 2026-11-08 (görüntüler repo dışında, ship sonrası silinir).
Accepted at SHIP: telefonda yalnız sayaç ekranı görüntülendi (adb dokunma göndermesine Xiaomi izin vermiyor); tek aktivite olduğundan kilit tüm ekranlar için aynıdır.
