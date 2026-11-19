# Backlog — deferred findings

Findings a human triaged as **defer**: real, but fixed later by decision (`workflows/feature-development.md`,
step 7). Nothing lands here without that decision; noise is rejected in the triage record, not parked here.

- A criterion moved out at the ship gate (R-08, `→ moved to B-<n>`) lands here too, by the
  human's ship decision; the entry names the spec and criterion.
- One entry per finding, newest last. Delete the entry in the commit of the work that closes it.
- An entry that grows into new behavior becomes a spec (`specs/active/`), not a fix.

<!-- Format (labels stay English):
- **B-<n>** — <finding, one line> — Source: spec <NNNN>, review round <n> (<file:line>) — Severity: <…>
  — Recommendation: <the reviewer's action> — Deferred by: <name>, <YYYY-MM-DD>, <why>
  A decision deferred at bootstrap (its REPORT) uses Source: bootstrap <YYYY-MM-DD>.
-->

- **B-1** — Reklam (AdMob) eklenmesi ticari kullanım olur: önce meal lisansı yeniden değerlendirilmeli
  (yayıncı izni veya serbest lisanslı meal), gizlilik maddesi (`docs/security.md`) ve izinler güncellenmeli;
  ayrı spec, hassas alana dokunur — Source: bootstrap 2026-11-02 — Severity: Medium
  — Recommendation: reklam kararı verildiğinde önce ADR 0002'yi yeniden aç, sonra spec yaz
  — Deferred by: emryldrmr, 2026-11-02, uygulama şu an ücretsiz ve reklamsız; reklam yalnızca çok kullanılırsa

- **B-3** — Önerilen Zikirler'e salavat ve Hasbünallah eklenmesi: Diyanet/TDV'de okunuş + anlam (+ varsa sayı) birlikte veren kaynak bulunamadı — Source: spec 0008, self-critique G6 — Severity: Low
  — Recommendation: Diyanet/TDV kaynağı bulunursa spec 0008'in tablosuna ek olarak yeni spec (hassas alan)
  — Deferred by: emryldrmr, 2026-11-07, kaynaksız dini metin eklenmez (BR-12)

- **B-4** — `badges_test.dart` `badge semantics in threshold order including off screen`: the edge-mark assert checks for an `ExcludeSemantics` widget type, not that the mark adds no node to the semantics tree (behavior holds today) — Source: spec 0016, VERIFY round 2 Q-2 (`test/features/history/ui/badges_test.dart`) — Severity: Info
  — Recommendation: assert that the mark produces no separate semantics node — Deferred by: emryldrmr, 2026-11-14, behavior correct; test-quality improvement is separate work

- **B-5** — Devam bildirimi kilit ekranında görünmüyor: bildirim gönderiliyor (ekran kilitliyken `dumpsys notification` listesinde `id=17`, `vis=PUBLIC`), ama kanal `continue` `importance=2` (LOW) = sessiz bildirim; sistem kilit ekranında sessiz bildirimleri gizliyor (Xiaomi 2412DPC0AG, Android 16, `lock_screen_show_silent_notifications=null`). AC-1'in "ekran kilitlenince de görünür" kısmı karşılanmıyor — Source: spec 0017, elle gözlem O1 (`lib/features/notifications/data/local_continue_notifier.dart`) — Severity: Medium
  — Recommendation: kanalı DEFAULT önemle, ses/titreşim kapalı yeni kimlikle (ör. `continue_v2`) aç, eskisini sil; kilit ekranında O1 + O2'yi cihazda yeniden gözle — Deferred by: emryldrmr, 2026-11-15, şimdilik yapılmayacak; arka plan ve son uygulamalar çalışıyor

- **B-6** — Firebase ile kullanıcı istediğinde (elle tetiklenen) senkronizasyon: verileri cihazlar arasında eşitleme. Bugünkü kararlarla çelişir — `docs/architecture.md` "Önerilmiyor: hesap/giriş, bulut senkronu", `docs/security.md` Gizlilik ("veri cihazdan çıkmaz", "Firebase yok", üçüncü taraf SDK yok); hesap/kimlik ve yeni dış adres gerektirir — Source: kullanıcı fikri 2026-11-19 (0018 JSON yedekleme ANALYZE) — Severity: Low
  — Recommendation: önce 0018 JSON yedekleme ship olsun (aynı veri biçimi senkronda da kullanılabilir); senkron istendiğinde önce gizlilik/hesap ADR'si, sonra hassas olmayan ayrı spec — Deferred by: emryldrmr, 2026-11-19, şu an sırası değil
