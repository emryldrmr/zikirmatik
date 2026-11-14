import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/domain/tesbihat.dart';
import 'package:zikirmatik/features/notifications/notifications.dart';

// Spec 0017 — the continue notification's text (Req. 3; AC-1, AC-2).

void main() {
  test('target title', () {
    final text = continueText(
      const DhikrResume(id: 3, name: 'Sübhanallah', count: 5, target: 33),
    );
    expect(text.title, 'Sübhanallah: 5 / 33');
    expect(text.body, 'Devam etmek için dokunun');
    expect(text.payload, 'dhikr:3');
  });

  test('no target title with separator', () {
    final text = continueText(
      const DhikrResume(id: 1, name: 'Zikir', count: 12345),
    );
    expect(text.title, 'Zikir: 12.345');
    expect(text.body, 'Devam etmek için dokunun');

    // Separators with a target too, and the name exactly as written (BR-1).
    expect(
      continueText(
        const DhikrResume(
          id: 2,
          name: '  Ya Latîf ',
          count: 1000,
          target: 1000,
        ),
      ).title,
      '  Ya Latîf : 1.000 / 1.000',
    );
  });

  test('tesbihat title has no step text', () {
    final text = continueText(
      const TesbihatResume(stepNumber: 2, count: 12, target: 33),
    );
    expect(text.title, 'Tesbihat · 2. adım: 12 / 33');
    expect(text.body, 'Devam etmek için dokunun');
    expect(text.payload, 'tesbihat');
    for (final step in namazSonrasiTesbihat.steps) {
      expect(text.title, isNot(contains(step.text)));
      expect(text.body, isNot(contains(step.text)));
    }
  });

  test('payload names the counter and nothing else', () {
    expect(itemOf(payloadOf(const CountedDhikr(42))), const CountedDhikr(42));
    expect(itemOf(payloadOf(const CountedTesbihat())), const CountedTesbihat());
    for (final bad in ['', 'dhikr:', 'dhikr:0x2', 'dhikr:+3', 'dhikr:a', 'x']) {
      expect(itemOf(bad), isNull, reason: bad);
    }
  });

  test('channel name', () {
    expect(continueChannelName(), 'Yarım kalan zikir');
  });
}
