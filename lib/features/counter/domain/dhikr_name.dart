import '../../../core/result.dart';

/// The name of a user's dhikr (docs/domain.md, BR-1): trimmed, 1–50 characters.
///
/// Characters are Unicode code points, the same unit SQLite's `length()` counts
/// (plan 0003, R1).
final class DhikrName {
  const DhikrName._(this.value);

  static const int maxLength = 50;

  /// The name of the first dhikr on a new install or after migration (spec 0003, G1).
  static const DhikrName first = DhikrName._('Zikir');

  final String value;

  /// A name from user input (BR-1).
  static Result<DhikrName> parse(String input) {
    final text = input.trim();
    final length = text.runes.length;
    if (length < 1 || length > maxLength) return Err(ValidationFailure(input));
    return Ok(DhikrName._(text));
  }

  /// A name from storage, already validated when it was written.
  factory DhikrName.stored(String value) => switch (parse(value)) {
    Ok(:final value) => value,
    Err() => throw ArgumentError.value(
      value,
      'value',
      'not a valid dhikr name',
    ),
  };

  @override
  bool operator ==(Object other) => other is DhikrName && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DhikrName($value)';
}
