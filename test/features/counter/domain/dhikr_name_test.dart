import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_name.dart';

String _ok(Result<DhikrName> r) => switch (r) {
  Ok(:final value) => value.value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

void main() {
  test('accepts 1 and 50 characters after trimming', () {
    expect(_ok(DhikrName.parse('a')), 'a');
    expect(_ok(DhikrName.parse('  Sabah zikri  ')), 'Sabah zikri');
    final fifty = 'ş' * 50;
    expect(_ok(DhikrName.parse(fifty)), fifty);
    expect(_ok(DhikrName.parse('  $fifty  ')), fifty);
  });

  test('rejects empty, blank and 51 characters', () {
    for (final input in ['', '   ', '\t\n', 'ğ' * 51]) {
      expect(
        DhikrName.parse(input),
        isA<Err<DhikrName>>().having(
          (e) => e.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
        reason: 'input "$input"',
      );
    }
  });

  test('counts code points, not UTF-16 units', () {
    // 25 emoji are 50 UTF-16 units but 25 characters.
    expect(_ok(DhikrName.parse('📿' * 25)), '📿' * 25);
    expect(DhikrName.parse('📿' * 51), isA<Err<DhikrName>>());
  });

  test('the first dhikr is called Zikir', () {
    expect(DhikrName.first.value, 'Zikir');
  });

  test('stored rejects an invalid stored name', () {
    expect(() => DhikrName.stored(''), throwsArgumentError);
    expect(DhikrName.stored('Akşam').value, 'Akşam');
  });
}
