// Sensitive area: Dini metin bütünlüğü (docs/domain.md; spec 0007).
// The text comes from assets/data/esma.json and is shown exactly as stored:
// never changed, trimmed or normalized (BR-12).

/// One of the 99 names of the Esmaü'l-Hüsna (docs/domain.md, "Esma").
final class AsmaName {
  const AsmaName({
    required this.number,
    required this.arabic,
    required this.reading,
    required this.meaning,
  });

  /// Position in the list, 1–99.
  final int number;
  final String arabic;

  /// How the name is read in Turkish; also the name of a dhikr added from it.
  final String reading;
  final String meaning;

  @override
  bool operator ==(Object other) =>
      other is AsmaName &&
      other.number == number &&
      other.arabic == arabic &&
      other.reading == reading &&
      other.meaning == meaning;

  @override
  int get hashCode => Object.hash(number, arabic, reading, meaning);

  @override
  String toString() => 'AsmaName($number, $reading)';
}
