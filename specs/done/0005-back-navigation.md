# Spec 0005 — Geri tuşu ve çift basışla çıkış (mini)

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0005-plan.md`
- Self-critique: done
- Source: emryldrmr, telefonda deneme, 2026-11-04 — "hangi ekranda olursam olayım telefonun geri tuşuna basınca komple uygulamadan çıkıyor"
- Design: none — aşağıdaki davranış tasarımdır
- Supersedes: none — spec 0001 geri tuşu davranışını tanımlamamıştı

## Intent
Kullanıcı Android'in geri tuşuna (ya da geri hareketine) bastığında uygulama hangi bölümde olursa olsun
hemen kapanıyor; bu, yanlışlıkla çıkmaya ve kafa karışıklığına yol açıyor. Geri tuşu önce açık olan
şeyi kapatmalı, sonra ana bölüme (Zikirlerim) dönmeli; uygulamadan ise ancak geri tuşuna kısa sürede iki kez
basınca çıkılmalı.

## Changed behavior
- [x] CB-1 — Zikirlerim dışındaki bir bölümdeyken (Önerilen Zikirler, Esmaü'l-Hüsna, Kur'an + Meal, Ayarlar) geri tuşu uygulamayı kapatmaz; Zikirlerim'e döner, başlık "Zikirlerim" olur ve seçili zikir ile değerleri değişmemiştir.
- [x] CB-2 — Zikirlerim'de (boş durum dahil) geri tuşuna ilk basış uygulamayı kapatmaz; ekranın altında "Çıkmak için tekrar basın." uyarısı görünür. Bu ilk basıştan sonraki 2 saniye içinde ikinci basış uygulamayı kapatır; 2 saniye geçtikten sonraki basış yine yalnızca uyarıyı gösterir.
- [x] CB-3 — Yan menü açıkken geri tuşu yalnızca menüyü kapatır; bölüm ve uygulama değişmez.
- [x] CB-4 — Bir alt sayfa ya da pencere açıkken (zikir seçici, zikir formu, hedef seçici, sıfırlama/silme onayı) geri tuşu yalnızca onu kapatır, hiçbir değeri değiştirmez ve çıkış uyarısını başlatmaz.
- [x] CB-5 — "Çıkmak için tekrar basın." uyarısı ekran okuyucuya duyurulur.

## Preserved behavior
- [x] PB-1 — Yan menüden bölüm seçmek spec 0001'deki gibi çalışır (başlık bölüm adı olur, Zikirlerim'e dönünce sayım aynen).
- [x] PB-2 — Uygulamadan çıkılıp yeniden açılınca zikirler, değerleri, seçili zikir ve ayarlar aynen görünür (spec 0003 AC-8, spec 0004 AC-5).
- [x] PB-3 — Ayarlar'da yapılan değişiklik geri tuşuyla Zikirlerim'e dönüldüğünde korunur (tema hemen uygulanmış, titreşim ayarı geçerli).

## Out of scope
Bölümler arası geçmiş yığını (geri tuşu bir önceki bölüme değil her zaman Zikirlerim'e döner — Android'in
üst düzey bölümler için önerdiği davranış); çıkış onay penceresi; Ayarlar'a "çift basışı kapat" seçeneği; iOS.

Self-critique (emryldrmr, 2026-11-04): geri tuşu doğrudan Zikirlerim'e döner (geçmiş yığını yok); çıkış onay
penceresi yerine çift basış ("Çıkmak için tekrar basın.", 2 saniye).

## Definition of Done
- [x] `scripts/check` green
- [x] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [x] Criterion ↔ evidence table complete for CB-* **and** PB-* (UI: before/after screenshots, agent-captured, judged at SHIP)
- [x] Spec moved to `specs/done/` (immutable there)

## Evidence (VERIFY)
VERIFY (QA session, separate from the builder), 2026-11-06, @ee40996; triage in the plan's `## Triage`.
Full green: CHECK GREEN (full, 6 steps, 221 s) @ee40996 — https://github.com/emryldrmr/zikirmatik/actions/runs/41880057918
(136 tests). Deliberate breaks in a temporary copy outside the repo (nothing committed): B1 window 1 s, B2 4 s, B3 2.5 s,
B4 1.6 s, B5 drawer not closed by the scope, B6 no return to Zikirlerim, B7 warning excluded from semantics, B8 every back
exits (the old behavior). All red except B3 (G-1, triaged noise).

| Acceptance criterion | Evidence | Status |
|---|---|---|
| CB-1 | `back_navigation_test.dart` — `back from another section returns to Zikirlerim with values kept` (red under B6, B8); S-1, S-2 | PASS |
| CB-2 | `back_navigation_test.dart` — `first back on Zikirlerim warns and stays`, `second back within 2 seconds exits`, `back after 2 seconds warns again`, `the empty state warns and exits the same way` (red under B1, B2, B4, B8; B3 green → G-1); S-3, S-6 | PASS |
| CB-3 | `back_navigation_test.dart` — `back with the menu open only closes the menu` (red under B5); S-4, S-5 | PASS |
| CB-4 | `back_navigation_test.dart` — `back closes an open sheet or dialog without exiting` (seven sheets/dialogs; no exit, no warning, values and entries unchanged — asserts read) | PASS |
| CB-5 | `back_navigation_test.dart` — `the exit warning is announced` (`isLiveRegion`; red under B7) | PASS |
| PB-1 | `shell_test.dart` — `each section shows coming soon and counter keeps its value` (unchanged) | PASS |
| PB-2 | `my_dhikrs_test.dart` — `restart shows the same dhikrs and selection`; `settings_test.dart` — `restart opens in the saved theme with the saved vibration` (unchanged) | PASS |
| PB-3 | `back_navigation_test.dart` — `a settings change survives going back` (red under B6) | PASS |

UI: S-1 Ayarlar before back · S-2 Zikirlerim after back · S-3 first-back warning · S-4 menu open · S-5 menu closed by back ·
S-6 empty state warning — agent-captured (headless widget render, Roboto + Material icons), outside the repo; ship approved by
emryldrmr, 2026-11-06. Manual run on a phone also passed (emryldrmr, 2026-11-04, plan triage F-2).
