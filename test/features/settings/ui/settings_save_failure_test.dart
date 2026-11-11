import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/storage_notice.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';

// Spec 0015 — Depolama hatası geri bildirimi: settings (AC-4).

const _mayBeLost =
    'Kaydedilemedi. Bu değişiklik uygulama kapanınca kaybolabilir.';

final _vibration = find.byKey(const Key('settings-vibration'));
final _notice = find.byKey(const Key('storage-notice'));
Finder _theme(ThemeChoice c) => find.byKey(Key('theme-${c.name}'));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('failed setting save stays applied and warns', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final settings = FakeSettingsRepository()..failWrites = true;
    await tester.pumpWidget(testApp(tester, settings: settings));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('open-menu')));
    await _tap(tester, find.byKey(const Key('section-settings')));

    await _tap(tester, _vibration);
    expect(tester.widget<SwitchListTile>(_vibration).value, isFalse);
    expect(find.text(_mayBeLost), findsOneWidget);
    await tester.pump(storageNoticeDuration);
    expect(_notice, findsNothing);

    await tester.scrollUntilVisible(
      _theme(ThemeChoice.system), // the last one, as settings_test
      100,
      scrollable: find.descendant(
        of: find.byKey(const Key('settings-screen')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, _theme(ThemeChoice.dark));
    expect(
      Theme.of(tester.element(find.byType(AppBar))).brightness,
      Brightness.dark,
    );
    expect(find.text(_mayBeLost), findsOneWidget);

    expect(settings.stored, AppSettings.defaults); // nothing was stored
    expect(settings.saves, isEmpty);
  });
}
