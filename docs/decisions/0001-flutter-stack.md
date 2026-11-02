# ADR 0001 — Mobil yığın olarak Flutter (Dart), önce Android

- Status: Accepted
- Date: 2026-11-02

## Context
zikirmatik offline çalışan bir mobil zikir sayacı; Kur'an + meal gibi Arapça/RTL içerik gösterecek.
Geliştirici .NET geliştiricisi, tek kişi, Windows makinesinde çalışıyor. ANEW çalışma alanı her kabul
kriterinin `scripts/check` içinde kanıtlanmasını şart koşuyor; ekran durumlarının emülatörsüz ve
deterministik test edilebilmesi bu yüzden belirleyici. Bootstrap anında makinede Flutter 3.41.2 /
Dart 3.11.0 ve Android SDK kurulu; .NET 9.0.304 kurulu ama MAUI workload'u yok.

## Decision
Uygulama Flutter (stable 3.41.x, Dart 3.11.x) ile yazılır; ilk hedef yalnızca Android (minSdk 23),
kod iOS'a uyumlu tutulur. Durum yönetimi Riverpod, kalıcı saklama drift (SQLite), HTTP `http` paketi.

## Consequences
- Artı: başsız widget testleri ekran durumlarını saniyeler içinde, emülatörsüz kanıtlar; e2e gerekmez.
- Artı: tek kod tabanı, platformlar arası aynı çizim; RTL ve özel font (Amiri Quran) desteği güçlü.
- Artı: kurulum makinede hazır.
- Eksi: geliştirici Dart öğrenmeli (C#'a yakın; maliyet düşük).
- Eksi: iOS derlemesi Mac gerektirir; ilk sürümde kapsam dışı.

## Alternatives considered
- **.NET MAUI (C#):** geliştiricinin mevcut bilgisi (MVVM, DI, xUnit) güçlü bir artı. Kaybetme sebebi:
  ekran durumları için başsız bileşen testi yok (Appium/emülatör gerekir — yavaş, kırılgan, residue
  riski), platforma özgü UI farkları daha sık, workload kurulumu gerekli.
- **React Native + Expo (TypeScript):** olgun; ama geliştiriciye Flutter'dan daha fazla avantaj
  sağlamıyor ve test hikâyesi Flutter widget testleri kadar entegre değil.
- **Kotlin + Jetpack Compose:** native performans; iOS için ikinci kod tabanı gerekir.

## Revisit triggers
- iOS'un birinci sınıf hedef olması ve Mac/CI erişimi.
- Flutter'ın Android'de engelleyici bir platform sorunu.
- Ekibe Dart bilmeyen, .NET ağırlıklı geliştiricilerin katılması.
