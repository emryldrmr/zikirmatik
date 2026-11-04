import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../support/test_app.dart';

// Spec 0005 — Geri tuşu ve çift basışla çıkış.

const _warning = 'Çıkmak için tekrar basın.';
final _value = find.byKey(const Key('counter-value'));
final _name = find.byKey(const Key('dhikr-name'));

CounterState _state({
  int count = 0,
  int rounds = 0,
  int total = 0,
  int? target,
}) => CounterState(
  count: DhikrCount(count),
  rounds: rounds,
  total: total,
  target: target == null ? null : Target.of(target),
);

Future<void> _start(
  WidgetTester tester, {
  FakeDhikrStore? store,
  FakeSettingsRepository? settings,
}) async {
  await tester.pumpWidget(testApp(tester, store: store, settings: settings));
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<void> _goTo(WidgetTester tester, String section) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('section-$section')));
  await tester.pumpAndSettle();
}

String _title(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(of: find.byType(AppBar), matching: find.byType(Text)),
    )
    .data!;

FakeDhikrStore _two() => FakeDhikrStore([
  ('Zikir', _state(count: 1, total: 1)),
  ('Sabah', _state(count: 7, rounds: 2, total: 73, target: 33)),
], selectedId: 2);

void main() {
  late List<String> calls;

  setUp(() => calls = []);

  /// Records platform calls, so the app closing itself
  /// (`SystemNavigator.pop`) can be counted.
  void watchExit(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
  }

  int exits() => calls.where((m) => m == 'SystemNavigator.pop').length;

  testWidgets(
    'back from another section returns to Zikirlerim with values kept',
    (tester) async {
      watchExit(tester);
      final store = _two();
      await _start(tester, store: store);

      for (final section in ['suggested', 'asma', 'quran', 'settings']) {
        await _goTo(tester, section);
        expect(_title(tester), isNot('Zikirlerim'), reason: section);
        await _back(tester);
        expect(_title(tester), 'Zikirlerim', reason: section);
        expect(tester.widget<Text>(_name).data, 'Sabah');
        expect(tester.widget<Text>(_value).data, '7');
        expect(find.text(_warning), findsNothing, reason: section);
      }
      expect(exits(), 0);
      expect(store.selectedId, 2);
      expect(
        store.stateOf(2),
        _state(count: 7, rounds: 2, total: 73, target: 33),
      );
    },
  );

  testWidgets('first back on Zikirlerim warns and stays', (tester) async {
    watchExit(tester);
    await _start(tester, store: _two());

    await _back(tester);
    expect(find.text(_warning), findsOneWidget);
    expect(exits(), 0);
    expect(_title(tester), 'Zikirlerim');
    expect(tester.widget<Text>(_value).data, '7');
  });

  testWidgets('second back within 2 seconds exits', (tester) async {
    watchExit(tester);
    await _start(tester, store: _two());

    await _back(tester);
    await tester.pump(const Duration(milliseconds: 1500));
    await _back(tester);
    expect(exits(), 1);
  });

  testWidgets('back after 2 seconds warns again', (tester) async {
    watchExit(tester);
    await _start(tester, store: _two());

    await _back(tester);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text(_warning), findsNothing); // the warning went away

    await _back(tester);
    expect(exits(), 0);
    expect(find.text(_warning), findsOneWidget);

    await _back(tester); // and now a quick second press exits
    expect(exits(), 1);
  });

  testWidgets('the empty state warns and exits the same way', (tester) async {
    watchExit(tester);
    await _start(tester, store: FakeDhikrStore([]));
    expect(find.text('Henüz zikir yok.'), findsOneWidget);

    await _back(tester);
    expect(find.text(_warning), findsOneWidget);
    expect(exits(), 0);
    await _back(tester);
    expect(exits(), 1);
  });

  testWidgets('back with the menu open only closes the menu', (tester) async {
    watchExit(tester);
    await _start(tester, store: _two());
    await _goTo(tester, 'settings');

    await tester.tap(find.byKey(const Key('open-menu')));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);

    await _back(tester);
    expect(find.byType(Drawer), findsNothing);
    expect(_title(tester), 'Ayarlar'); // section unchanged
    expect(find.text(_warning), findsNothing);
    expect(exits(), 0);
  });

  testWidgets('back closes an open sheet or dialog without exiting', (
    tester,
  ) async {
    watchExit(tester);
    final store = _two();
    await _start(tester, store: store);

    Future<void> openAndBack(String key, Finder open, {int backs = 1}) async {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      expect(open, findsOneWidget, reason: key);
      for (var i = 0; i < backs; i++) {
        await _back(tester);
      }
      expect(open, findsNothing, reason: key);
      expect(find.text(_warning), findsNothing, reason: key);
    }

    // Zikir seçici.
    await openAndBack(
      'dhikr-picker-button',
      find.byKey(const Key('dhikr-picker')),
    );
    // Hedef seçici.
    await openAndBack('counter-target', find.text('Özel…'));
    // Sıfırlama onayı.
    await openAndBack('counter-reset', find.byType(AlertDialog));

    // Zikir formu, seçicinin üstünde: ilk geri formu, ikincisi seçiciyi kapatır.
    await tester.tap(find.byKey(const Key('dhikr-picker-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dhikr-add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dhikr-name-field')), findsOneWidget);
    await _back(tester);
    expect(find.byKey(const Key('dhikr-name-field')), findsNothing);
    expect(find.byKey(const Key('dhikr-picker')), findsOneWidget);
    await _back(tester);
    expect(find.byKey(const Key('dhikr-picker')), findsNothing);
    expect(find.text(_warning), findsNothing);

    // Düzenleme formu, seçicinin üstünde: geri yalnızca formu kapatır.
    await tester.tap(find.byKey(const Key('dhikr-picker-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dhikr-edit-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dhikr-delete')), findsOneWidget);
    await _back(tester);
    expect(find.byKey(const Key('dhikr-delete')), findsNothing);
    expect(find.byKey(const Key('dhikr-picker')), findsOneWidget);

    // Silme onayı (Sil düzenleme formunu kapatıp onayı seçicinin üstünde
    // açar): geri onayı, sonraki geri seçiciyi kapatır.
    await tester.tap(find.byKey(const Key('dhikr-edit-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dhikr-delete')));
    await tester.pumpAndSettle();
    const confirm = '“Sabah” silinsin mi? Sayımı ve toplamı da silinir.';
    expect(find.text(confirm), findsOneWidget);
    await _back(tester);
    expect(find.text(confirm), findsNothing);
    expect(find.byKey(const Key('dhikr-picker')), findsOneWidget);
    await _back(tester);
    expect(find.byKey(const Key('dhikr-picker')), findsNothing);
    expect(find.text(_warning), findsNothing);

    expect(exits(), 0);
    expect(store.entries.length, 2); // nothing deleted
    expect(
      store.stateOf(2),
      _state(count: 7, rounds: 2, total: 73, target: 33),
    );
    expect(tester.widget<Text>(_value).data, '7');
  });

  testWidgets('the exit warning is announced', (tester) async {
    watchExit(tester);
    final semantics = tester.ensureSemantics();
    await _start(tester, store: _two());

    await _back(tester);
    expect(
      tester.getSemantics(find.text(_warning)),
      isSemantics(label: _warning, isLiveRegion: true),
    );
    semantics.dispose();
  });

  testWidgets('a settings change survives going back', (tester) async {
    watchExit(tester);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final settings = FakeSettingsRepository();
    await _start(tester, store: _two(), settings: settings);

    await _goTo(tester, 'settings');
    await tester.tap(find.byKey(const Key('settings-vibration')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-dark')));
    await tester.pumpAndSettle();
    await _back(tester);

    expect(_title(tester), 'Zikirlerim');
    expect(
      Theme.of(tester.element(find.byType(AppBar))).brightness,
      Brightness.dark,
    );
    expect(
      settings.stored,
      const AppSettings(vibration: false, theme: ThemeChoice.dark),
    );
    expect(exits(), 0);
  });
}
