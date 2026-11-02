import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_count.dart';

void main() {
  test('zero is 0', () {
    expect(DhikrCount.zero.value, 0);
  });

  test('increment adds one', () {
    expect(DhikrCount.zero.increment().value, 1);
    expect(const DhikrCount(41).increment().increment().value, 43);
  });

  test('increment does not change the original value', () {
    const count = DhikrCount(5);
    count.increment();
    expect(count.value, 5);
  });

  test('a negative count is rejected', () {
    expect(() => DhikrCount(-1), throwsA(isA<AssertionError>()));
  });

  test('equal values are equal', () {
    expect(
      const DhikrCount(3),
      DhikrCount.zero.increment().increment().increment(),
    );
  });
}
