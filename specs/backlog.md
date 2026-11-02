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
