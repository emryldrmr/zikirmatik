// Sensitive area: Dini metin bütünlüğü (docs/domain.md; spec 0006, Requirements 1).
//
// Source: Müslim, Mesâcid 146 — after the prayer, 33 tesbih, 33 tahmid,
// 33 tekbir. Spelling: Diyanet İşleri Başkanlığı. The text is shown exactly as
// written here: never changed, trimmed or normalized (BR-12). Any change is a
// spec change (R-08); test/integrity/tesbihat_text_test.dart locks it.

import 'target.dart';

/// One step of a tesbihat: the text recited and how many times
/// (docs/domain.md, "Adım").
final class TesbihatStep {
  const TesbihatStep(this.text, this.target);

  final String text;
  final Target target;
}

/// The single built-in tesbihat (spec 0006): its steps in order.
final class Tesbihat {
  const Tesbihat._(this.steps);

  final List<TesbihatStep> steps;
}

/// "Namaz sonrası tesbihat" (spec 0006, Requirements 1).
final Tesbihat namazSonrasiTesbihat = Tesbihat._(
  List.unmodifiable([
    TesbihatStep('Sübhânallah', Target.of(33)),
    TesbihatStep('Elhamdülillâh', Target.of(33)),
    TesbihatStep('Allâhu ekber', Target.of(33)),
  ]),
);
