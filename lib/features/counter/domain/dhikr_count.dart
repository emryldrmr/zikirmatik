/// The count of the current round (docs/domain.md, "Sayım"). Never negative.
final class DhikrCount {
  const DhikrCount(this.value)
    : assert(value >= 0, 'A count is never negative.');

  static const DhikrCount zero = DhikrCount(0);

  final int value;

  /// BR-3: every tap adds one.
  DhikrCount increment() => DhikrCount(value + 1);

  @override
  bool operator ==(Object other) => other is DhikrCount && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DhikrCount($value)';
}
