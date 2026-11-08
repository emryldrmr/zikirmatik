# Spec 0013 — Hedefin dokunulabilir olduğu belli olsun (mini)

- Status: Approved
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
- [ ] CB-1 — Hedef satırı cihazın içinde ince çerçeveli bir buton olarak görünür ve metnin yanında bir açılır simge (▾) vardır; metinler aynen kalır ("Hedef yok", "Hedef 33 · Tur 2").
- [ ] CB-2 — Hedef satırının ekran okuyucu etiketi "Hedef: yok. Değiştirmek için dokunun." / "Hedef: 33. Değiştirmek için dokunun." olur.
- [ ] CB-3 — Çerçeve ve simge cihazın sabit renklerindedir; açık ve koyu temada aynı görünür ve cihaz yüzeyine karşı kontrastı en az 3:1'dir (grafik öğe eşiği).

## Preserved behavior
- [ ] PB-1 — Hedef satırına dokunmak spec 0002'deki hedef seçimini açar (Hedef yok, 33, 99, 100, Özel…); seçim, onay ve kayıt kuralları değişmez.
- [ ] PB-2 — Cihazın diğer renkleri ve görünümü açık ve koyu temada aynıdır (spec 0004 AC-4); hedef satırının dokunma hedefi en az 48×48 dp kalır.
- [ ] PB-3 — Sayma, tur tamamlama ve titreşim (ayar açıkken) spec 0002/0004'teki gibi çalışır.

## Out of scope
İlk açılışta tanıtım/ipucu balonu; hedef satırının yerini değiştirmek; yeni hedef seçenekleri.

Self-critique (emryldrmr, 2026-11-04): ▾ simgesi zikir seçicisiyle tutarlı; metinler değişmez, yalnızca görünüm ve ekran okuyucu etiketi değişir.

## Definition of Done
- [ ] `scripts/check` green
- [ ] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [ ] Criterion ↔ evidence table complete for CB-* **and** PB-* (UI: before/after screenshots, agent-captured, judged at SHIP)
- [ ] Spec moved to `specs/done/` (immutable there)
