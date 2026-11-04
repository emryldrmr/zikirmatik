# Spec 0005 — Geri tuşu ve çift basışla çıkış (mini)

- Status: In progress
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
- [ ] CB-1 — Zikirlerim dışındaki bir bölümdeyken (Önerilen Zikirler, Esmaü'l-Hüsna, Kur'an + Meal, Ayarlar) geri tuşu uygulamayı kapatmaz; Zikirlerim'e döner, başlık "Zikirlerim" olur ve seçili zikir ile değerleri değişmemiştir.
- [ ] CB-2 — Zikirlerim'de (boş durum dahil) geri tuşuna ilk basış uygulamayı kapatmaz; ekranın altında "Çıkmak için tekrar basın." uyarısı görünür. Bu ilk basıştan sonraki 2 saniye içinde ikinci basış uygulamayı kapatır; 2 saniye geçtikten sonraki basış yine yalnızca uyarıyı gösterir.
- [ ] CB-3 — Yan menü açıkken geri tuşu yalnızca menüyü kapatır; bölüm ve uygulama değişmez.
- [ ] CB-4 — Bir alt sayfa ya da pencere açıkken (zikir seçici, zikir formu, hedef seçici, sıfırlama/silme onayı) geri tuşu yalnızca onu kapatır, hiçbir değeri değiştirmez ve çıkış uyarısını başlatmaz.
- [ ] CB-5 — "Çıkmak için tekrar basın." uyarısı ekran okuyucuya duyurulur.

## Preserved behavior
- [ ] PB-1 — Yan menüden bölüm seçmek spec 0001'deki gibi çalışır (başlık bölüm adı olur, Zikirlerim'e dönünce sayım aynen).
- [ ] PB-2 — Uygulamadan çıkılıp yeniden açılınca zikirler, değerleri, seçili zikir ve ayarlar aynen görünür (spec 0003 AC-8, spec 0004 AC-5).
- [ ] PB-3 — Ayarlar'da yapılan değişiklik geri tuşuyla Zikirlerim'e dönüldüğünde korunur (tema hemen uygulanmış, titreşim ayarı geçerli).

## Out of scope
Bölümler arası geçmiş yığını (geri tuşu bir önceki bölüme değil her zaman Zikirlerim'e döner — Android'in
üst düzey bölümler için önerdiği davranış); çıkış onay penceresi; Ayarlar'a "çift basışı kapat" seçeneği; iOS.

Self-critique (emryldrmr, 2026-11-04): geri tuşu doğrudan Zikirlerim'e döner (geçmiş yığını yok); çıkış onay
penceresi yerine çift basış ("Çıkmak için tekrar basın.", 2 saniye).

## Definition of Done
- [ ] `scripts/check` green
- [ ] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [ ] Criterion ↔ evidence table complete for CB-* **and** PB-* (UI: before/after screenshots, agent-captured, judged at SHIP)
- [ ] Spec moved to `specs/done/` (immutable there)
