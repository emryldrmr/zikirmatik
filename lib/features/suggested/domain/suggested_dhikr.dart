// Sensitive area: Dini metin bütünlüğü (docs/domain.md; spec 0008).
// The text comes from assets/data/suggested_dhikrs.json and is shown exactly
// as stored: never changed, trimmed or normalized (BR-12).

/// A dhikr embedded in the app with its meaning, its source-given target (if
/// any) and its hadith reference (docs/domain.md, "Önerilen zikir").
final class SuggestedDhikr {
  const SuggestedDhikr({
    required this.number,
    required this.reading,
    required this.meaning,
    required this.target,
    required this.reference,
  });

  /// Position in the list, 1–7.
  final int number;

  /// How the dhikr is read in Turkish; also the name of a dhikr added from it.
  final String reading;
  final String meaning;

  /// The count the source gives (BR-2 range), or null when it gives none.
  final int? target;

  /// The hadith reference, written as its source writes it.
  final String reference;

  @override
  bool operator ==(Object other) =>
      other is SuggestedDhikr &&
      other.number == number &&
      other.reading == reading &&
      other.meaning == meaning &&
      other.target == target &&
      other.reference == reference;

  @override
  int get hashCode => Object.hash(number, reading, meaning, target, reference);

  @override
  String toString() => 'SuggestedDhikr($number, $reading)';
}
