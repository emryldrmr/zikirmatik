import '../../../core/result.dart';

/// The count that completes a round (docs/domain.md, "Hedef"; BR-2).
final class Target {
  const Target._(this.value);

  static const int min = 1;
  static const int max = 100000;

  /// The presets offered in the target picker (spec 0002, G3).
  static const List<Target> presets = [
    Target._(33),
    Target._(99),
    Target._(100),
  ];

  final int value;

  /// A target from a trusted value (storage); throws on a value outside BR-2.
  factory Target.of(int value) {
    if (value < min || value > max) {
      throw ArgumentError.value(value, 'value', 'outside $min..$max');
    }
    return Target._(value);
  }

  static final _digits = RegExp(r'^[0-9]+$');

  /// A target from user input: decimal digits only, between [min] and [max]
  /// (BR-2). `int.tryParse` alone would also accept "0x21" and "+33"
  /// (docs/conventions.md, Known traps).
  static Result<Target> parse(String input) {
    final text = input.trim();
    final value = _digits.hasMatch(text) ? int.tryParse(text) : null;
    if (value == null || value < min || value > max) {
      return Err(ValidationFailure(input));
    }
    return Ok(Target._(value));
  }

  @override
  bool operator ==(Object other) => other is Target && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Target($value)';
}
