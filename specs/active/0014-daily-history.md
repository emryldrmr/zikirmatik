# Spec 0014 — Günlük geçmiş ve seri

- Status: In progress
- Mode: lite
- Plan: `specs/plans/0014-plan.md`
- Self-critique: done

## Intent
Kullanıcı her gün ne kadar zikir çektiğini görmek ve kaç gündür ara vermeden devam ettiğini (seri) bilmek
istiyor; bu, düzenli zikre teşvik eder ve sonraki rozetler spec'inin dayanağıdır. Başarı: bugün ve önceki günlerin
sayımı doğru görünür, seri bir gün atlanınca sıfırlanır, uygulama kapanıp açılınca hiçbir şey kaybolmaz. Bilinçli
olarak yapılmayan: zikir başına döküm, grafik, hedef/günlük kota, bildirim, rozetler (sonraki spec), geçmişin
düzenlenmesi ya da silinmesi, depolama hatası geri bildirimi (B-2, ayrı spec).
Clarify kararları D1–D7 ve self-critique G1–G5 (emryldrmr, 2026-11-08) buraya katlandı.

## Requirements
1. **Günün sayımı:** sayımı artıran her dokunuş — zikirde (BR-3) ve tesbihatta — o anki yerel takvim gününün
   sayımını 1 artırır. Tamamlanmış tesbihata dokunmak (sayım artmaz) günü değiştirmez.
2. **Geri al:** zikirde ya da tesbihatta sayımı 1 azaltan geri al (BR-5), o anki günün sayımını 1 azaltır;
   günün sayımı 0 ise değişmez (0'ın altına inmez). Önceki günler geri al ile hiç değişmez.
3. **Değişmeyen geçmiş:** sıfırlama (BR-7), hedef değiştirme, zikir silme, yeniden adlandırma, tesbihatı yeniden
   başlatma ve Esma/önerilen zikir ekleme geçmişi değiştirmez.
4. **Gün sınırı:** gün, cihazın yerel saatinde 00:00'da değişir. Bir dokunuş, yapıldığı andaki cihaz tarihine yazılır
   (saat geri alınsa bile o anki tarih kullanılır). Bugünden ileri tarihli günler (saat geri alındıysa) listede
   görünmez ve seriye girmez; silinmez, saklı kalır (G1).
5. **Seri:** sayımı en az 1 olan art arda günlerin sayısıdır; bugünden, bugün henüz sayım yoksa dünden geriye doğru
   sayılır. Bugün ve dün sayımı 0 ise seri 0'dır. **En uzun seri**, tüm geçmişteki en uzun böyle dizidir.
6. **Geçmiş bölümü:** yan menüde Zikirlerim'in hemen altında "Geçmiş" girişi. Bölüm üstte "Seri: N gün" ve
   "En uzun seri: N gün", altında bugünden başlayıp geriye doğru son 30 günü tarih ve sayımla listeler; sayımı 0 olan
   günler de "0" ile görünür. Sayılar Türkçe binlik ayırıcıyla yazılır ("1.250") (G2).
7. **Kalıcılık:** geçmiş her değişiklikte kalıcı saklanır (BR-8); uygulama kapanıp açılınca aynı görünür. Bu sürümden
   önceki günler için geçmiş yoktur (sayım 0 görünür). Geçmiş kaydedilemezse sayma durmaz, sayım yine artar;
   kullanıcıya hata bildirimi B-2 kapsamındadır (G5).
8. Bölüm açıkken bir dokunuş olamaz (sayma Zikirlerim'de); bölüme her girişte ve uygulama ön plana döndüğünde
   güncel gün ve değerler gösterilir.

## User experience
- **Flow:** yan menü → "Geçmiş" → seri satırları + son 30 gün listesi → geri tuşu Zikirlerim'e döner (spec 0005).
- **States:**
  - *Boş:* hiç sayım yoksa "Seri: 0 gün", "En uzun seri: 0 gün" ve altında "Henüz sayım yok." yazısı; liste gösterilmez.
  - *Dolu:* seri satırları ve 30 satırlık liste; satır biçimi "8 Kasım 2026, Pazar — 120", ilk satırın tarihi yerine "Bugün".
  - *Yükleniyor:* kısa yükleniyor göstergesi (Zikirlerim'deki gibi).
  - *Hata:* geçmiş okunamazsa "Geçmiş yüklenemedi." yazısı; sayma etkilenmez.
- **Design reference:** none — the flow above is the design.
- **Accessibility:** her liste satırı tek bir ekran okuyucu öğesidir: "<tarih>: <N> zikir"; seri satırları
  "Seri: N gün" olarak okunur; metin en büyük sistem yazı boyutunda kırpılmaz, alt satıra geçer.

## Constraints & out of scope
- Sensitive area: yok — dini metin gösterilmez ya da değiştirilmez.
- Spec 0001 AC-6'daki menü sırası değişir: Zikirlerim, **Geçmiş**, Önerilen Zikirler, Esmaü'l-Hüsna, Kur'an + Meal,
  Ayarlar. 0001–0013'ün diğer kriterleri geçerli kalır; geri tuşu (0005) Geçmiş'te de Zikirlerim'e döner.
- Geçmiş yalnız cihazda kalır; ağ, hesap, analitik yok (`docs/security.md`).
- Roadmap: "Günün Esması" maddesi bekletildi (emryldrmr, 2026-11-08; hatırlatıcı bildirimler ile birlikte yeniden
  ele alınacak); bu spec `docs/architecture.md` sırasında bir sonraki maddedir. Mimarideki sıra kaydı build'de
  güncellenir.
- **Split:** roadmap bu maddeyi "B-2 ile birlikte" yazıyordu; B-2 (depolama yazma hatası geri bildirimi) ayrı spec
  olarak bundan sonra gelir — emryldrmr, 2026-11-08 (yeni bir yetenek; kriter sayısını 10'un üstüne çıkarırdı).
- **Clarify kararları (lite, emryldrmr, 2026-11-08):**
  D1 sayılan = tesbihat dahil tüm sayım artıran dokunuşlar · D2 geri al bugünü azaltır, geçmişi değil · D3 sıfırlama
  ve silme geçmişi değiştirmez · D4 gün = yerel 00:00 · D5 seri bugün henüz sayılmadıysa dünden sayılır; en uzun seri
  de gösterilir · D6 ayrı "Geçmiş" menü bölümü, Zikirlerim'in altında; sayaç ekranına seri eklenmez · D7 son 30 gün,
  0'lı günler dahil; zikir başına döküm yok.
- **Self-critique G1–G5 (emryldrmr, 2026-11-08):** G1 ileri tarihli günler gizli ve seri dışı, saklı · G2 binlik
  ayırıcı · G3 gece yarısından sonra geri al örneği AC-2'de · G4 yükleniyor durumu AC-8'de · G5 geçmiş yazılamazsa
  sayma sürer (geri bildirim B-2).
- **Out of scope:** zikir başına döküm; grafik/takvim görünümü; 30 günden eski günlerin listelenmesi (saklanır,
  gösterilmez); günlük hedef; geçmişi düzenleme/silme; rozetler; bildirim; yedekleme (0015'e kalır); B-2.

## Acceptance criteria
- [ ] AC-1 — Zikirde her sayım artıran dokunuş (tur tamamlayan dahil) ve tesbihatta her sayım artıran dokunuş bugünün sayımını tam 1 artırır; tamamlanmış tesbihata dokunmak bugünü değiştirmez.
- [ ] AC-2 — Geri al (zikir ve tesbihat) bugünün sayımını 1 azaltır; bugünün sayımı 0 iken geri al bugünü 0'da bırakır; önceki günlerin sayımı hiçbir geri al ile değişmez (ör. dün 23:59'daki dokunuş bugün geri alınınca zikrin sayımı 1 azalır, bugün 0 kalır, dün aynı kalır).
- [ ] AC-3 — Sıfırlama, hedef değiştirme, zikir silme/yeniden adlandırma, tesbihatı yeniden başlatma ve Esma/önerilen zikir ekleme hiçbir günün sayımını değiştirmez.
- [ ] AC-4 — 23:59'da yapılan dokunuş o güne, 00:00'dan sonraki dokunuş ertesi güne yazılır (yerel saat); uygulama açıkken gece yarısı geçince Geçmiş'e girildiğinde "Bugün" yeni günü gösterir.
- [ ] AC-5 — Seri: ardışık sayımlı günler; bugün 0 ve dün sayımlıysa seri dünden sayılır; bugün ve dün 0 ise seri 0; bir 0'lı gün seriyi böler. En uzun seri tüm geçmişteki en uzun dizidir ve mevcut seri ondan büyük olamaz. (Sınırlar: 0, 1, 30'dan uzun seri, ay ve yıl geçişi.)
- [ ] AC-6 — Yan menü şu altı girişi bu sırayla gösterir: Zikirlerim, Geçmiş, Önerilen Zikirler, Esmaü'l-Hüsna, Kur'an + Meal, Ayarlar; Geçmiş'te geri tuşu Zikirlerim'e döner.
- [ ] AC-7 — Geçmiş bölümü "Seri: N gün", "En uzun seri: N gün" ve bugünden geriye 30 satır gösterir; ilk satır "Bugün", diğerleri "<gün> <ay> <yıl>, <haftanın günü>" biçiminde Türkçe; sayımı 0 olan günler "0" ile görünür; sayılar binlik ayırıcılıdır ("1.250"); bugünden ileri tarihli günler görünmez ve seriye girmez.
- [ ] AC-8 — Geçmiş yüklenirken yükleniyor göstergesi görünür; hiç sayım yokken boş durum: seri satırları 0 gün ve "Henüz sayım yok."; geçmiş okunamazsa "Geçmiş yüklenemedi." görünür ve sayma çalışmaya devam eder.
- [ ] AC-9 — Uygulama kapanıp açılınca her günün sayımı, seri ve en uzun seri aynıdır (BR-8).
- [ ] AC-10 — Erişilebilirlik: her liste satırı tek öğe "<tarih>: <N> zikir"; seri satırları okunur; en büyük yazı boyutunda ve dar ekranda metin kırpılmaz; dokunma hedefleri en az 48×48 dp.

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
