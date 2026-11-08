# Spec 0013 — Hedefin dokunulabilir olduğu belli olsun (mini)

- Status: Shipped
- Mode: lite
- Plan: `specs/plans/0013-plan.md`
- Self-critique: done
- Source: emryldrmr, telefonda deneme, 2026-11-04 — "tur nasıl tamamlanıyor bilemedim"
- Design: none — aşağıdaki davranış tasarımdır
- Supersedes: 0002/AC-10 (yalnızca hedef satırının ekran okuyucu etiketi)

## Intent
Cihazdaki "Hedef yok" / "Hedef 33 · Tur 2" satırı dokunulunca hedef seçimini açıyor, ama düz bir yazı gibi
göründüğü için kullanıcı bunu fark etmiyor ve tur/titreşim özelliğini bulamıyor. Satır, zikir adı
seçicisi gibi dokunulabilir olduğunu belli etmeli.

## Changed behavior
- [x] CB-1 — Hedef satırı cihazın içinde ince çerçeveli bir buton olarak görünür ve metnin yanında bir açılır simge (▾) vardır; metinler aynen kalır ("Hedef yok", "Hedef 33 · Tur 2").
- [x] CB-2 — Hedef satırının ekran okuyucu etiketi "Hedef: yok. Değiştirmek için dokunun." / "Hedef: 33. Değiştirmek için dokunun." olur.
- [x] CB-3 — Çerçeve ve simge cihazın sabit renklerindedir; açık ve koyu temada aynı görünür ve cihaz yüzeyine karşı kontrastı en az 3:1'dir (grafik öğe eşiği).

## Preserved behavior
- [x] PB-1 — Hedef satırına dokunmak spec 0002'deki hedef seçimini açar (Hedef yok, 33, 99, 100, Özel…); seçim, onay ve kayıt kuralları değişmez.
- [x] PB-2 — Cihazın diğer renkleri ve görünümü açık ve koyu temada aynıdır (spec 0004 AC-4); hedef satırının dokunma hedefi en az 48×48 dp kalır.
- [x] PB-3 — Sayma, tur tamamlama ve titreşim (ayar açıkken) spec 0002/0004'teki gibi çalışır.

## Out of scope
İlk açılışta tanıtım/ipucu balonu; hedef satırının yerini değiştirmek; yeni hedef seçenekleri.

Self-critique (emryldrmr, 2026-11-04): ▾ simgesi zikir seçicisiyle tutarlı; metinler değişmez, yalnızca görünüm ve ekran okuyucu etiketi değişir.

## Definition of Done
- [x] `scripts/check` green
- [x] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [x] Criterion ↔ evidence table complete for CB-* **and** PB-* (UI: before/after screenshots, agent-captured, judged at SHIP)
- [x] Spec moved to `specs/done/` (immutable there)

## Scorecard (fill at ship — honest numbers make the process improvable)
| Metric | Value |
|---|---|
| Spec revisions | 0 (yalnız numara 0006 → 0013; 0006 tesbihat'a verilmişti) |
| Fix rounds | 0 |
| Review findings: real / noise / deferred | 0 / 0 / 0 (round 1 clean) |
| Regressions introduced | 0 |
| Bugs escaped to production | 0 (not yet released) |

## Evidence (VERIFY)
One-pass review + QA (bağımsız reviewer subagent), 2026-11-08 @29996de; verdict clean; triage `specs/plans/0013-plan.md` `## Triage`.
Full green: build CHECK GREEN (full, 6 steps, 103 s) @d75cb81; sonraki commit'ler yalnız `specs/` değiştirir.
Kasıtlı kırmalar (build, hepsi kırmızı): eski etiket metni (CB-2); eski hedef satırı, çerçevesiz ve ▾'siz (CB-1, CB-3); `Flexible` kaldırılınca uzun satır 662 px taşar (plan R2).

| Acceptance criterion | Evidence | Status |
|---|---|---|
| CB-1 | `device_counter_test.dart` — `the target row looks tappable`, `a long target row fits a narrow screen`; S-5…S-8 | PASS |
| CB-2 | `device_counter_test.dart` — `semantics labels and touch targets` | PASS |
| CB-3 | `device_counter_test.dart` — `the target row looks tappable` (açık/koyu aynı renk, kontrast ≥ 3:1; ölçülen ~9:1); S-5…S-8 | PASS |
| PB-1 | `device_counter_test.dart` hedef seçimi testleri; `back_navigation_test.dart` (`counter-target` → "Özel…") | PASS |
| PB-2 | `semantics labels and touch targets` (48×48); `display_options_test.dart`; spec 0004 tema testleri; S-1…S-8 | PASS |
| PB-3 | `device_counter_test.dart` sayma/tur ve titreşim testleri | PASS |

UI: S-1…S-8 agent-captured (başsız widget render, gerçek fontlar; önce/sonra × açık/koyu × "Hedef yok"/"Hedef 33 · Tur 2"), judged by emryldrmr at SHIP, 2026-11-08 (görüntüler repo dışında, ship sonrası silinir).
Accepted at SHIP: telefonda elle deneme yapılmadı; başsız görüntüler yeterli görüldü (emryldrmr).
