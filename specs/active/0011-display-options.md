# Spec 0011 — Görünüm seçenekleri: büyük rakam ve el yerleşimi

- Status: In progress
- Mode: lite
- Plan: `specs/plans/0011-plan.md`
- Self-critique: done

## Intent
Kullanıcı sayacı kendi eline ve gözüne göre ayarlamak istiyor: sayımı uzaktan ya da gözlüksüz rahat
okumak, telefonu tek elle tutarken sayma düğmesine başparmağıyla zorlanmadan ulaşmak. Ayarlar'a iki
seçenek gelir: "Büyük rakam" sayım rakamını büyütür, "El yerleşimi" (Ortada / Sağ el / Sol el) sayacı
seçilen ele yaklaştırır. Başarı: seçenekler Zikirlerim'in normal ve tam ekranında, zikirde ve tesbihatta
hemen uygulanır; varsayılanlarla görünüm bugünküyle birebir aynıdır; tesbihat adım metni hiçbir seçenekte
kırpılmaz. Bilinçli olarak yapılmayan: yazı tipi seçimi, renk/tema değişikliği, çok seviyeli boyut ayarı,
Kur'an/Esma ekranlarında yazı boyutu; ses tuşuyla sayma (vazgeçildi, emryldrmr, 2026-11-07).

## Requirements
1. Ayarlar ekranında "Ekranı açık tut"un altında önce "Büyük rakam" aç/kapa ayarı, sonra üç seçenekli
   "El yerleşimi" ayarı (Ortada, Sağ el, Sol el; tema seçimi gibi tek seçim) vardır. Yeni kurulumda ve bu
   sürüme güncellenen kurulumda "Büyük rakam" kapalı, "El yerleşimi" Ortada'dır. Mevcut ayarlar
   güncellemede korunur. Ayarlar kalıcıdır; okunamazsa varsayılanlar kabul edilir ve hata gösterilmez
   (spec 0004, Req. 6 ile aynı tutum).
2. "Büyük rakam" açıkken yalnızca sayım rakamı büyür — yer varsa kapalıyken olduğunun en az 1,5 katı: normal ekranda cihazın ekranındaki (LCD) sayım,
   tam ekranda ortadaki sayım, tesbihatta adımın sayımı (normal ve tam ekran). Hedef, tur, toplam,
   "Adım x/y", zikir adı ve tesbihat adım metni bugünkü boyutunda kalır. Kapalıyken boyutlar bugünküyle
   aynıdır.
3. Sayım rakamı hiçbir durumda kesilmez, "…" ile kısaltılmaz ve iki satıra bölünmez: sığmazsa sığdığı en
   büyük boyutta gösterilir. Bu, en uzun sayım (hedefsiz zikirde 6 hane ve fazlası dahil), yan çevrilmiş
   telefon ve telefonun büyük yazı ayarı için de geçerlidir.
4. "El yerleşimi" normal ekranda zikir cihazını ve tesbihat görünümünü bütün olarak seçilen kenara
   yaklaştırır: Sağ el'de sağ kenara, Sol el'de sol kenara, bugünkü kenar boşluğu kadar mesafeyle yaslanır;
   Ortada'da bugünkü gibi ortadadır. Dikey ve yan çevrilmiş ekranda aynı kural geçerlidir. Cihazın
   kendi düzeni (ekran, hedef/tur, toplam, küçük düğmeler, büyük sayma düğmesi) değişmez ve cihaz ekrandan
   taşmaz. Ekran cihazdan dar olduğu için kaydırılacak yer yoksa cihaz ortada kalır.
5. "El yerleşimi" tam ekranda düğmelerin yerini belirler: Ortada'da bugünkü gibi "Geri al" sol üst, "Kapat"
   sağ üst köşededir; Sağ el'de "Geri al" sağ alt, "Kapat" sol üst köşededir; Sol el'de "Geri al" sol
   alt, "Kapat" sağ üst köşededir. Bilgiler (ad, sayım, hedef/tur, toplam; tesbihatta adım metni, "Adım
   x/y") düğmelerle çakışmaz. Alt köşedeki "Geri al" sistemin alt kenar hareket alanının üstünde durur;
   alttan çekme hareketi ne sayar ne de geri alır. Düğmelere dokunuş saymaz, geri kalan her yer sayar
   (spec 0010 aynen).
6. Seçenekler yalnız görünümü değiştirir: sayma, geri al, sıfırla, hedef, tur, tesbihat ilerlemesi,
   titreşim, ekranı açık tutma ve kalıcı saklama (BR-3…BR-8, BR-13) bugünkü gibidir.
7. Tesbihat adım metni her seçenek bileşiminde spec 0006'daki haliyle, değiştirilmeden ve kırpılmadan
   gösterilir (BR-12); sığmazsa yazı küçülür ya da kaydırılır, asla "…" ile kesilmez (spec 0010 kuralı).
8. Bir seçeneği değiştirmek hemen uygulanır; Zikirlerim'e dönülünce yeni görünüm görülür, yeniden başlatma
   gerekmez.

## User experience
- **Flow:** Yan menü → "Ayarlar" → "Büyük rakam"ı aç ve/veya "El yerleşimi"nden "Sağ el"i seç → yan menü →
  "Zikirlerim" → sayım büyük, cihaz sağa yakın → "Tam ekran" → "Geri al" sağ altta.
- **States:**
  - *Ayarlar:* "Ekranı açık tut" satırının altında "Büyük rakam" satırı (alt metin "Sayım daha büyük
    görünür", sağda anahtar), altında "El yerleşimi" başlığı ve üç seçenek: "Ortada", "Sağ el", "Sol el";
    seçili olan işaretli.
  - *Ayar okunamadı:* hata yok; "Büyük rakam" kapalı, "El yerleşimi" Ortada görünür ve uygulanır.
  - *Zikirlerim — varsayılanlar:* bugünkü gibi (spec 0002 çizimi).
  - *Zikirlerim — büyük rakam:* cihaz aynı; LCD'deki sayım daha büyük.
  - *Zikirlerim — Sağ el / Sol el:* cihaz seçilen kenara yakın (çizim aşağıda).
  - *Tesbihat — her bileşim:* adım metni tam ve değiştirilmeden; sayım büyük rakam açıksa büyük; görünüm
    seçilen kenara yakın.
  - *Tam ekran — Ortada / Sağ el / Sol el:* düğme köşeleri Req. 5'teki gibi (çizim aşağıda); büyük rakam
    açıksa ortadaki sayım daha büyük.
  - *Zikirlerim — boş durum, yükleniyor, yüklenemedi:* bugünkü gibi; seçenekler bunları değiştirmez.
- **Design reference:** none — the flow above and the sketches below are the design (spec 0002 çizimi
  temeldir; boyutlar ve kenar boşlukları plan/uygulamada belirlenir).
  ```
  Normal ekran — Sağ el            Tam ekran — Ortada   Sağ el          Sol el
  ┌──────────────────────────┐     ┌────────────┐       ┌────────────┐  ┌────────────┐
  │ ≡  Zikirlerim            │     │ ↶        ✕ │       │ ✕          │  │          ✕ │
  │         ╭──────────────╮ │     │   Ad       │       │   Ad       │  │   Ad       │
  │         │ ┌──────────┐ │ │     │    33      │       │    33      │  │    33      │
  │         │ │     33   │ │ │     │ Hedef/Tur  │       │ Hedef/Tur  │  │ Hedef/Tur  │
  │         │ └──────────┘ │ │     │  Toplam    │       │  Toplam    │  │  Toplam    │
  │         │  ↶  geri ↺   │ │     │            │       │          ↶ │  │ ↶          │
  │         │   ╭──────╮   │ │     └────────────┘       └────────────┘  └────────────┘
  │         │   │  ●   │   │ │
  │         │   ╰──────╯   │ │     Sol el: normal ekranda aynı çizimin
  │         ╰──────────────╯ │     sol kenara yakın hali.
  └──────────────────────────┘
  ```
- **Accessibility:** "Büyük rakam" anahtarı bu etiketle ve açık/kapalı durumuyla, "El yerleşimi"
  seçenekleri etiketleriyle ve seçili olan seçili olarak bildirilir; dokunma hedefleri en az 48×48 dp.
  Ekran okuyucu sırası ve etiketleri (sayma düğmesi, "Geri al", "Kapat", "Sıfırla", hedef) seçeneklerden
  bağımsız olarak bugünküyle aynıdır. Yeni metinlerin kontrastı Açık ve Koyu temada en az 4.5:1.

## Constraints & out of scope
- Sensitive area: Dini metin bütünlüğü — seçenekler tesbihat adım metnini gösteren ekranların düzenini
  değiştirir; metin her bileşimde spec 0006'daki haliyle, kırpılmadan ve değiştirilmeden gösterilir
  (BR-12, Req. 7). Zikir adı kullanıcının metnidir, bu kurala tabi değildir (bugünkü gibi tek satır,
  sığmazsa "…").
- Spec 0002, 0003, 0004, 0006, 0009 ve 0010'un kriterleri varsayılan seçeneklerde aynen geçerlidir;
  diğer seçeneklerde de davranış (görünüm dışındaki her şey) aynen geçerlidir.
- `docs/architecture.md` "Sürüm 1 kapsamı"ndaki kalan sıra bu spec'in dalında güncellenir: ses tuşuyla
  sayma çıkarılır ve "Deliberately out of scope"a "vazgeçildi, emryldrmr, 2026-11-07" notuyla yazılır;
  sonraki maddeler birer numara geri kayar.
- Clarify Q1–Q7 (emryldrmr, 2026-11-07): tek spec; büyük rakam yalnız sayım rakamı, tek anahtar,
  varsayılan kapalı; sayım asla kesilmez, sığdığı en büyük boyut; el yerleşimi Ortada/Sağ el/Sol el,
  normal ekranda cihaz bütün olarak kayar, tam ekranda "Geri al" elin alt köşesine, "Kapat" karşı üst
  köşeye; tesbihata da uygulanır, adım metni kırpılmaz; Ayarlar'da "Ekranı açık tut"un altında; tasarım
  referansı yok, ASCII çizimler tasarımdır.
- Self-critique G1–G6 (emryldrmr, 2026-11-07): büyük rakam yer varsa en az 1,5 kat; Sağ/Sol el'de cihaz
  kenara bugünkü kenar boşluğuyla yaslanır, yan ekranda da; alt köşedeki "Geri al" sistem hareket
  alanının üstünde, alttan çekme saymaz ve geri almaz; sayım her değerde tam (örnek 1.000.000).
  Split: 10 kriter, tek kullanım amacı — bölünmedi, emryldrmr.
- **Out of scope:** yazı tipi, renk ve tema seçimi; çok seviyeli boyut ayarı; hedef/tur/toplam/adım metni
  boyutunun değişmesi; cihazın iç düzeninin değişmesi; Kur'an, Esma, Önerilen Zikirler ve Ayarlar
  ekranlarının görünümü; ses tuşuyla sayma (vazgeçildi); ayar kaydetme hatasının bildirilmesi (B-2).

## Acceptance criteria
- [ ] AC-1 — Ayarlar'da "Ekranı açık tut"un altında "Büyük rakam" anahtarı ve "El yerleşimi" seçenekleri (Ortada, Sağ el, Sol el) görünür; yeni kurulumda Büyük rakam kapalı, El yerleşimi Ortada'dır; önceki sürümden güncellenen veritabanında mevcut ayarlar korunur, yeni ayarlar varsayılandır; ayarlar yeniden başlatınca korunur; ayarlar okunamazsa hata gösterilmez ve varsayılanlar uygulanır.
- [ ] AC-2 — Varsayılan seçeneklerde Zikirlerim (zikir ve tesbihat, normal ve tam ekran) bugünkü sürümle aynı görünür: sayım boyutu, cihazın konumu ve tam ekran düğme köşeleri değişmez.
- [ ] AC-3 — Büyük rakam açıkken LCD'deki sayım, tam ekrandaki sayım ve tesbihat adım sayımı (normal ve tam ekran), yer olduğunda kapalıyken olduğunun en az 1,5 katı büyüklüktedir; hedef, tur, toplam, "Adım x/y", zikir adı ve adım metni boyutu değişmez.
- [ ] AC-4 — Sayım rakamı (ör. 0, 99.999 ve 1.000.000) her seçenek bileşiminde, dikey ve yan çevrilmiş ekranda ve büyük sistem yazısında tam görünür: kesilmez, "…" içermez, tek satırdır.
- [ ] AC-5 — Normal ekranda (dikey ve yan) Sağ el'de cihaz (ve tesbihat görünümü) sağ kenara, Sol el'de sol kenara bugünkü kenar boşluğu kadar mesafeyle yaslanır; cihazın iç düzeni aynıdır ve cihaz ekrandan taşmaz; dar ekranda kayacak yer yoksa ortada kalır.
- [ ] AC-6 — Tam ekranda "Geri al" ve "Kapat" köşeleri: Ortada sol üst / sağ üst, Sağ el sağ alt / sol üst, Sol el sol alt / sağ üst; bilgiler düğmelerle çakışmaz; alt köşedeki "Geri al" sistemin alt kenar hareket alanının üstündedir ve alttan çekme ne sayar ne geri alır; düğmelere dokunuş saymaz, köşe yakınları dahil geri kalan her yer sayar.
- [ ] AC-7 — Her seçenek bileşiminde sayma, geri al, sıfırla, hedef/tur, tesbihat adım geçişi ve titreşim bugünkü gibi çalışır ve değerler yeniden başlatınca korunur.
- [ ] AC-8 — Tesbihat adım metni her seçenek bileşiminde (normal ve tam ekran, dikey ve yan, büyük sistem yazısı) spec 0006'daki metinle birebir aynı ve kırpılmadan görünür; "…" içermez.
- [ ] AC-9 — Bir seçeneği değiştirip Zikirlerim'e dönünce yeni görünüm yeniden başlatmadan uygulanmıştır; seçili zikir ve değerleri değişmemiştir.
- [ ] AC-10 — Erişilebilirlik: "Büyük rakam" anahtarı etiketiyle ve açık/kapalı durumuyla, El yerleşimi seçenekleri etiketleriyle ve seçili olan seçili olarak bildirilir; dokunma hedefleri en az 48×48 dp; Zikirlerim'deki ekran okuyucu etiketleri seçeneklerden bağımsız olarak aynıdır; yeni metinlerin kontrastı Açık ve Koyu temada en az 4.5:1.

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
