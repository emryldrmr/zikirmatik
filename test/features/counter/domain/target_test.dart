import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/result.dart';
import 'package:zikirmatik/features/counter/domain/target.dart';

int _ok(Result<Target> r) => switch (r) {
  Ok(:final value) => value.value,
  Err(:final failure) => fail('expected Ok, got $failure'),
};

void main() {
  test('parse accepts 1 and 100000', () {
    expect(_ok(Target.parse('1')), 1);
    expect(_ok(Target.parse('100000')), 100000);
    expect(_ok(Target.parse(' 33 ')), 33);
  });

  test('parse rejects 0, 100001, empty and non-numbers', () {
    for (final input in [
      '0',
      '100001',
      '',
      '   ',
      'abc',
      '3.5',
      '-5',
      '1e3',
      '0x21',
      '0X186A0',
      '+33',
      '١٢',
      '99999999999999999999',
    ]) {
      expect(
        Target.parse(input),
        isA<Err<Target>>().having(
          (e) => e.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
        reason: 'input "$input"',
      );
    }
  });

  test('presets are 33, 99 and 100', () {
    expect(Target.presets.map((t) => t.value), [33, 99, 100]);
  });

  test('of rejects values outside the range', () {
    expect(() => Target.of(0), throwsArgumentError);
    expect(() => Target.of(100001), throwsArgumentError);
    expect(Target.of(7).value, 7);
  });
}
