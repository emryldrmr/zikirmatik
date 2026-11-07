# Spec 0012 — portrait only (mini)

- Status: In progress
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
- [ ] CB-1 — Uygulama açılışta ekran yönünü yalnız dikeye (portrait up) kilitler; telefon yan ya da baş aşağı çevrilse de hiçbir ekran (sayaç, tam ekran, Zikirlerim, Önerilen, Esma, Kur'an, Ayarlar) dönmez.
- [ ] CB-2 — Android manifest'te ana aktivite dikey yöne kilitlidir (`android:screenOrientation="portrait"`), böylece açılışın ilk karesinde de yatay görünüm oluşmaz.
- [ ] CB-3 — Yatay ekran kabul kriteri yoktur: 0011 AC-4/5/8 ve 0010 AC-5'in yan çevrilmiş ekran testleri kaldırılmaz, dikey karşılıkları zaten var olduğundan yatay parametreleri çıkarılır ya da dikeye indirilir; dikey ve büyük sistem yazısı (2×) kapsamı aynen kalır (test zayıflatma değil, kapsam değişikliği — Supersedes satırı kaydıdır).

## Preserved behavior
- [ ] PB-1 — Dikey ekranda tüm ekranlar bugünkü gibi görünür ve çalışır: sayaç, tam ekran, Büyük rakam / el yerleşimi (0011), ekranı açık tut (0010), titreşim (0009).
- [ ] PB-2 — Dikey ekranda sayım rakamı ve tesbihat adım metni büyük sistem yazısında (2×) kesilmez, "…" içermez (0011 AC-4/AC-8'in dikey kısmı; 0010 AC-5).
- [ ] PB-3 — Dar dikey ekranda el yerleşimi cihazı ortada tutar, cihaz ekrandan taşmaz (0011 AC-5'in dikey kısmı).
- [ ] PB-4 — Dini metin (Kur'an, meal, Esma, önerilen zikir, tesbihat) hiçbir şekilde değişmez.

## Out of scope
- Yatay düzeni düzeltmek (yatay mod hiç olmayacak).
- Tablet / iOS için ayrı yön davranışı.
- Ortada yerleşimi ve kısa bilgi satırlarının yeniden tasarımı (B-4'ün yatay kısmı bu kilitle anlamsızlaşır; dikey küçük ekranda benzer sorun görülürse ayrı iş).

## Definition of Done
- [ ] `scripts/check` green
- [ ] Independent review done; real findings fixed, noise rejected with written rationale, deferred ones in `specs/backlog.md`
- [ ] Criterion ↔ evidence table complete for CB-* **and** PB-* (UI: before/after screenshots, agent-captured, judged at SHIP)
- [ ] Spec moved to `specs/done/` (immutable there)
