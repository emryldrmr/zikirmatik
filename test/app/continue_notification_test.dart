import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/counter/ui/tesbihat_controller.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../support/test_app.dart';

// Spec 0017 — Yarım kalan zikir bildirimi: leaving, coming back, tapping
// (AC-1, AC-3, AC-5, AC-6, AC-7, AC-9).

final _tapArea = find.byKey(const Key('counter-tap-area'));
final _name = find.byKey(const Key('dhikr-name'));
final _value = find.byKey(const Key('counter-value'));

const _on = AppSettings(
  vibration: true,
  theme: ThemeChoice.system,
  continueNotification: true,
);

CounterState _state({int count = 0, int total = 0, int? target}) =>
    CounterState(
      count: DhikrCount(count),
      total: total,
      target: target == null ? null : Target.of(target),
    );

/// "Sübhanallah" (id 1, target 33) selected, "Hamd" (id 2, no target).
FakeDhikrStore _store({int? selectedId}) => FakeDhikrStore([
  ('Sübhanallah', _state(target: 33)),
  ('Hamd', _state(count: 12344, total: 12344)),
], selectedId: selectedId);

Future<void> _start(
  WidgetTester tester, {
  required FakeContinueNotifier notifier,
  AppSettings settings = _on,
  FakeDhikrStore? store,
  FakeTesbihatRepository? tesbihat,
  FakeSettingsRepository? settingsStore,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(
      tester,
      store: store ?? _store(),
      tesbihat: tesbihat,
      notifier: notifier,
      settings: settingsStore ?? FakeSettingsRepository(stored: settings),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapTimes(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.tap(_tapArea);
    await tester.pump();
  }
}

/// Home button, recent apps or the lock screen: the app is hidden.
Future<void> _leave(WidgetTester tester) async {
  tester.binding
    ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
    ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
    ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await tester.pump();
}

/// Back in front, by whatever way.
Future<void> _comeBack(WidgetTester tester) async {
  tester.binding
    ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
    ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
    ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
}

Future<void> _goTo(WidgetTester tester, String section) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('section-$section')));
  await tester.pumpAndSettle();
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ZikirmatikApp)));

String _text(WidgetTester tester, Finder f) => tester.widget<Text>(f).data!;

void main() {
  testWidgets('hidden after taps shows target title', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 5);
    await _leave(tester);

    expect(notifier.shown, (
      title: 'Sübhanallah: 5 / 33',
      body: 'Devam etmek için dokunun',
      payload: 'dhikr:1',
    ));
    expect(notifier.requests, 0); // never asked by leaving (Req. 8)
  });

  testWidgets('no target and tesbihat titles', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier, store: _store(selectedId: 2));
    await _tapTimes(tester, 1);
    await _leave(tester);
    expect(notifier.shown?.title, 'Hamd: 12.345');

    await _comeBack(tester);
    await _container(
      tester,
    ).read(tesbihatControllerProvider.notifier).select(true);
    await tester.pumpAndSettle();
    await _tapTimes(tester, 2);
    await _leave(tester);
    expect(notifier.shown?.title, 'Tesbihat · 1. adım: 2 / 33');
    expect(notifier.shown?.payload, 'tesbihat');
  });

  testWidgets('setting off shows nothing', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier, settings: AppSettings.defaults);
    await _tapTimes(tester, 5);
    await _leave(tester);
    expect(notifier.shows, isEmpty);
  });

  testWidgets('nothing counted shows nothing', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _goTo(tester, 'settings');
    await _goTo(tester, 'myDhikrs');
    await _leave(tester);
    expect(notifier.shows, isEmpty);
  });

  testWidgets('no permission shows nothing', (tester) async {
    // Taken back in the phone's settings (Req. 8; AC-9).
    final notifier = FakeContinueNotifier();
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 5);
    await _leave(tester);
    expect(notifier.shows, isEmpty);
    expect(notifier.requests, 0);
  });

  testWidgets('shade pulled down is not leaving', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(notifier.shows, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  });

  testWidgets('second leave replaces', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 5);
    await _leave(tester);
    await _comeBack(tester);
    await _tapTimes(tester, 2);
    await _leave(tester);

    // The same single notification, with the new values (Req. 4).
    expect(notifier.shows.map((n) => n.title), [
      'Sübhanallah: 5 / 33',
      'Sübhanallah: 7 / 33',
    ]);
    expect(notifier.shown?.title, 'Sübhanallah: 7 / 33');
  });

  testWidgets('shown cancels', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 3);
    await _leave(tester);
    expect(notifier.shown, isNotNull);

    await _comeBack(tester);
    expect(notifier.shown, isNull);
  });

  testWidgets('turning off cancels', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 3);
    final cancels = notifier.cancels;

    await _container(
      tester,
    ).read(settingsControllerProvider.notifier).setContinueNotification(false);
    await tester.pumpAndSettle();
    expect(notifier.cancels, greaterThan(cancels));

    await _leave(tester);
    expect(notifier.shows, isEmpty);
  });

  testWidgets('deleting the counted dhikr cancels', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 3);
    final cancels = notifier.cancels;
    await _container(
      tester,
    ).read(dhikrListControllerProvider.notifier).delete(1);
    await tester.pumpAndSettle();
    expect(notifier.cancels, greaterThan(cancels));

    await _leave(tester);
    expect(notifier.shows, isEmpty); // G1
  });

  testWidgets('tap opens the item warm', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 5);
    await _leave(tester);
    final payload = notifier.shown!.payload;

    // Meanwhile another section and the full screen are open.
    await _comeBack(tester);
    await _container(
      tester,
    ).read(dhikrListControllerProvider.notifier).select(2);
    await tester.pumpAndSettle();
    final open = find.byKey(const Key('full-screen-open'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    await _leave(tester);

    notifier.tap(payload);
    await _comeBack(tester);

    expect(find.byKey(const Key('full-screen')), findsNothing);
    expect(_text(tester, _name), 'Sübhanallah');
    expect(_text(tester, _value), '5');
    expect(notifier.shown, isNull);
  });

  testWidgets('tap from another section opens Zikirlerim', (tester) async {
    final notifier = FakeContinueNotifier(granted: true);
    await _start(tester, notifier: notifier);
    await _tapTimes(tester, 2);
    await _goTo(tester, 'settings');

    notifier.tap('dhikr:1');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-screen')), findsNothing);
    expect(_text(tester, _name), 'Sübhanallah');
  });

  testWidgets('launch payload opens the item cold', (tester) async {
    // The app was closed; the notification starts it (Req. 5).
    final notifier = FakeContinueNotifier(granted: true, launch: 'tesbihat');
    await _start(
      tester,
      notifier: notifier,
      tesbihat: FakeTesbihatRepository(
        stored: TesbihatState(step: 1, count: DhikrCount(12)),
      ),
    );

    expect(find.byKey(const Key('tesbihat-name')), findsOneWidget);
    expect(_text(tester, find.byKey(const Key('counter-value'))), '12');

    // And a dhikr.
    await tester.pumpWidget(const SizedBox());
    await _start(
      tester,
      notifier: FakeContinueNotifier(granted: true, launch: 'dhikr:2'),
    );
    expect(_text(tester, _name), 'Hamd');
  });
}
