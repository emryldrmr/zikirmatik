import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/hand_layout.dart';
import 'package:zikirmatik/features/backup/backup.dart';
import 'package:zikirmatik/features/counter/counter.dart';
import 'package:zikirmatik/features/history/history.dart';
import 'package:zikirmatik/features/settings/settings.dart';

import '../../../support/test_app.dart';
import '../../settings/ui/keep_screen_on_test.dart' show contrast;

// Spec 0018 — JSON yedekleme ve geri yükleme, Ayarlar > Yedekleme
// (AC-1, AC-2, AC-4 … AC-10).

final _save = find.byKey(const Key('backup-save'));
final _restore = find.byKey(const Key('backup-restore'));
final _note = find.byKey(const Key('backup-note'));
final _dialog = find.byKey(const Key('backup-restore-dialog'));
final _confirm = find.byKey(const Key('backup-restore-confirm'));
final _cancel = find.byKey(const Key('backup-restore-cancel'));

const _warning = 'Mevcut tüm verileriniz yedektekiyle değiştirilecek.';
const _invalid = 'Bu dosya geçerli bir zikirmatik yedeği değil.';
const _tooNew =
    'Bu yedek uygulamanın daha yeni bir sürümüyle alınmış. '
    'Uygulamayı güncelleyin.';
const _restoreFailed = 'Yedek geri yüklenemedi. Verileriniz değişmedi.';

const _darkSettings = BackupSettings(
  vibration: false,
  theme: 'dark',
  tapVibration: true,
  keepScreenOn: false,
  largeCount: true,
  handLayout: 'right',
  continueNotification: false,
);

BackupSnapshot _snapshot({
  List<BackupDhikr> dhikrs = const [
    BackupDhikr(
      id: 1,
      name: 'Yeni zikir',
      target: 33,
      count: 5,
      rounds: 2,
      total: 71,
    ),
    BackupDhikr(
      id: 4,
      name: 'Hamd',
      target: null,
      count: 0,
      rounds: 0,
      total: 0,
    ),
  ],
  int? selected = 1,
  List<BackupDay> days = const [
    BackupDay('2026-11-07', 3),
    BackupDay('2026-11-08', 4),
  ],
  BackupSettings settings = _darkSettings,
}) => BackupSnapshot(
  createdAt: DateTime(2026, 11, 7, 21, 30),
  appVersion: '1.0.0',
  data: BackupData(
    dhikrs: dhikrs,
    selectedDhikrId: selected,
    tesbihat: const BackupTesbihat(),
    days: days,
    settings: settings,
  ),
);

Opened _file(BackupSnapshot snapshot) =>
    Opened(const JsonBackupFormat().encode(snapshot));

/// Writes a restore into the app's fakes, as the drift store writes every
/// table.
void Function(BackupData) _writeInto({
  required FakeDhikrStore store,
  required FakeHistoryRepository history,
  required FakeSettingsRepository settings,
}) => (data) {
  store
    ..entries.clear()
    ..counters.clear()
    ..selectedId = data.selectedDhikrId;
  for (final d in data.dhikrs) {
    store.entries.add(DhikrEntry(d.id, DhikrName.stored(d.name)));
    store.counters[d.id] = FakeCounterRepository(
      state: CounterState(
        count: DhikrCount(d.count),
        rounds: d.rounds,
        total: d.total,
        target: d.target == null ? null : Target.of(d.target!),
      ),
    );
  }
  history.stored
    ..clear()
    ..addAll({for (final d in data.days) Day.tryParse(d.day)!: d.count});
  final s = data.settings;
  settings.stored = AppSettings(
    vibration: s.vibration,
    theme: ThemeChoice.byName(s.theme)!,
    tapVibration: s.tapVibration,
    keepScreenOn: s.keepScreenOn,
    largeCount: s.largeCount,
    handLayout: HandLayout.byName(s.handLayout)!,
    continueNotification: s.continueNotification,
  );
};

Future<void> _start(
  WidgetTester tester, {
  FakeBackupStore? backupStore,
  FakeBackupFiles? files,
  FakeDhikrStore? store,
  FakeHistoryRepository? history,
  FakeSettingsRepository? settings,
  FakeContinueNotifier? notifier,
  FakeClock? clock,
  Size size = const Size(400, 2000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(
      tester,
      backupStore: backupStore,
      files: files,
      store: store,
      history: history,
      settings: settings,
      notifier: notifier,
      clock: clock,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _goTo(WidgetTester tester, String section) async {
  await tester.tap(find.byKey(const Key('open-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('section-$section')));
  await tester.pumpAndSettle();
}

Future<void> _show(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    100,
    scrollable: find.descendant(
      of: find.byKey(const Key('settings-screen')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await _show(tester, target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Finder _message(String key) => find.byKey(Key(key));

void main() {
  testWidgets('backup section after notifications with subtitles and note', (
    tester,
  ) async {
    await _start(tester);
    await _goTo(tester, 'settings');

    expect(find.text('Yedekleme'), findsOneWidget);
    expect(find.text('Yedekle'), findsOneWidget);
    expect(find.text('Tüm verilerinizi bir dosyaya kaydeder'), findsOneWidget);
    expect(find.text('Geri yükle'), findsOneWidget);
    expect(
      find.text('Bir yedek dosyasından verilerinizi geri getirir'),
      findsOneWidget,
    );
    expect(find.text('Yedek dosyası şifresizdir.'), findsOneWidget);

    // The earlier settings keep their order; the backup section comes last.
    double top(Finder f) => tester.getTopLeft(f).dy;
    final order = [
      find.byKey(const Key('settings-vibration')),
      find.byKey(const Key('theme-system')),
      find.text('Bildirimler'),
      find.byKey(const Key('settings-continue-notification')),
      find.text('Yedekleme'),
      _save,
      _restore,
      _note,
    ];
    for (var i = 1; i < order.length; i++) {
      expect(top(order[i - 1]), lessThan(top(order[i])), reason: '$i');
    }
  });

  testWidgets('save suggests dated name and confirms', (tester) async {
    final data = _snapshot().data;
    final files = FakeBackupFiles(saveOutcome: SaveOutcome.saved);
    await _start(
      tester,
      backupStore: FakeBackupStore(stored: data),
      files: files,
      clock: FakeClock(DateTime(2026, 11, 19, 9, 5)),
    );
    await _goTo(tester, 'settings');
    await _tap(tester, _save);

    final saved = files.saves.single;
    expect(saved.name, 'zikirmatik-yedek-2026-11-19.json');
    final written = switch (const JsonBackupFormat().decode(saved.bytes)) {
      Valid(:final snapshot) => snapshot,
      final other => fail('not a valid backup: $other'),
    };
    expect(written.data, data);
    expect(
      written.createdAt.isAtSameMomentAs(DateTime(2026, 11, 19, 9, 5)),
      isTrue,
    );
    // Human readable.
    expect(utf8.decode(saved.bytes), contains('"name": "Yeni zikir"'));
    expect(find.text('Yedek kaydedildi'), findsOneWidget);
  });

  testWidgets('save cancelled shows nothing', (tester) async {
    final backupStore = FakeBackupStore(stored: _snapshot().data);
    final files = FakeBackupFiles();
    await _start(tester, backupStore: backupStore, files: files);
    await _goTo(tester, 'settings');
    await _tap(tester, _save);

    expect(files.saves, hasLength(1));
    expect(find.byType(SnackBar), findsNothing);
    expect(backupStore.replaced, isEmpty);
  });

  testWidgets('save failure message', (tester) async {
    final files = FakeBackupFiles(saveOutcome: SaveOutcome.failed);
    final backupStore = FakeBackupStore();
    await _start(tester, backupStore: backupStore, files: files);
    await _goTo(tester, 'settings');
    await _tap(tester, _save);
    expect(find.text('Yedek kaydedilemedi.'), findsOneWidget);

    // Unreadable data: the dialog does not open, the same message.
    ScaffoldMessenger.of(tester.element(_save)).removeCurrentSnackBar();
    await tester.pumpAndSettle();
    backupStore.failRead = true;
    await _tap(tester, _save);
    expect(files.saves, hasLength(1));
    expect(find.text('Yedek kaydedilemedi.'), findsOneWidget);
  });

  testWidgets('valid file shows warning date and count', (tester) async {
    await _start(
      tester,
      files: FakeBackupFiles(openOutcome: _file(_snapshot())),
    );
    await _goTo(tester, 'settings');
    await _tap(tester, _restore);

    expect(_dialog, findsOneWidget);
    expect(find.text(_warning), findsOneWidget);
    expect(find.text('7 Kasım 2026 21:30 · 2 zikir'), findsOneWidget);
    expect(find.text('Vazgeç'), findsOneWidget);
    expect(
      find.descendant(of: _confirm, matching: find.text('Geri yükle')),
      findsOneWidget,
    );
  });

  testWidgets('cancel changes nothing', (tester) async {
    final backupStore = FakeBackupStore();
    final store = FakeDhikrStore([('Eski', CounterState.initial)]);
    await _start(
      tester,
      backupStore: backupStore,
      store: store,
      files: FakeBackupFiles(openOutcome: _file(_snapshot())),
    );
    await _goTo(tester, 'settings');
    await _tap(tester, _restore);
    await tester.tap(_cancel);
    await tester.pumpAndSettle();

    expect(_dialog, findsNothing);
    expect(backupStore.replaced, isEmpty);
    expect(find.byType(SnackBar), findsNothing);
    expect(store.entries.single.name.value, 'Eski');
  });

  testWidgets('pick cancelled shows nothing', (tester) async {
    final files = FakeBackupFiles();
    final backupStore = FakeBackupStore();
    await _start(tester, files: files, backupStore: backupStore);
    await _goTo(tester, 'settings');
    await _tap(tester, _restore);

    expect(files.opens, 1);
    expect(_dialog, findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(backupStore.replaced, isEmpty);
  });

  testWidgets('restore refreshes my dhikrs history and theme', (tester) async {
    final store = FakeDhikrStore([('Eski', CounterState.initial)]);
    final history = FakeHistoryRepository();
    final settings = FakeSettingsRepository();
    final backupStore = FakeBackupStore(
      onReplace: _writeInto(store: store, history: history, settings: settings),
    );
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _start(
      tester,
      store: store,
      history: history,
      settings: settings,
      backupStore: backupStore,
      files: FakeBackupFiles(openOutcome: _file(_snapshot())),
    );
    await _goTo(tester, 'settings');
    Brightness brightness() => Theme.of(
      tester.element(find.byKey(const Key('settings-screen'))),
    ).brightness;
    expect(brightness(), Brightness.light);

    await _tap(tester, _restore);
    await tester.tap(_confirm);
    await tester.pumpAndSettle();

    expect(backupStore.replaced.single, _snapshot().data);
    expect(find.text('Yedek geri yüklendi'), findsOneWidget);
    // No restart: the theme and the switches follow at once.
    expect(brightness(), Brightness.dark);
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const Key('settings-vibration')))
          .value,
      isFalse,
    );

    await _goTo(tester, 'myDhikrs');
    expect(find.text('Yeni zikir'), findsWidgets);
    expect(find.text('Eski'), findsNothing);
    await _goTo(tester, 'history');
    expect(find.text('Seri: 2 gün'), findsOneWidget);
  });

  testWidgets('invalid file shows message no dialog', (tester) async {
    final backupStore = FakeBackupStore();
    final files = FakeBackupFiles();
    await _start(tester, backupStore: backupStore, files: files);
    await _goTo(tester, 'settings');

    final longName = _snapshot(
      dhikrs: [
        BackupDhikr(
          id: 1,
          name: 'a' * 51,
          target: null,
          count: 0,
          rounds: 0,
          total: 0,
        ),
      ],
    );
    for (final bytes in [
      utf8.encode('merhaba'),
      utf8.encode('{"name":"Zikir"}'),
      const JsonBackupFormat().encode(longName),
    ]) {
      files.openOutcome = Opened(Uint8List.fromList(bytes));
      await _tap(tester, _restore);
      expect(_dialog, findsNothing);
      expect(find.text(_invalid), findsOneWidget);
      ScaffoldMessenger.of(tester.element(_restore)).removeCurrentSnackBar();
      await tester.pumpAndSettle();
    }

    files.openOutcome = Opened(
      utf8.encode('{"format":"zikirmatik-yedek","formatVersion":2}'),
    );
    await _tap(tester, _restore);
    expect(_dialog, findsNothing);
    expect(find.text(_tooNew), findsOneWidget);
    expect(backupStore.replaced, isEmpty);
  });

  testWidgets('too large file rejected unread', (tester) async {
    final backupStore = FakeBackupStore();
    await _start(
      tester,
      backupStore: backupStore,
      files: FakeBackupFiles(openOutcome: const OpenTooLarge()),
    );
    await _goTo(tester, 'settings');
    await _tap(tester, _restore);

    expect(_dialog, findsNothing);
    expect(find.text(_invalid), findsOneWidget);
    expect(backupStore.replaced, isEmpty);
  });

  testWidgets('restore failure message keeps data', (tester) async {
    final store = FakeDhikrStore([('Eski', CounterState.initial)]);
    final settings = FakeSettingsRepository();
    final backupStore = FakeBackupStore()..failReplace = true;
    await _start(
      tester,
      store: store,
      settings: settings,
      backupStore: backupStore,
      files: FakeBackupFiles(openOutcome: _file(_snapshot())),
    );
    await _goTo(tester, 'settings');
    await _tap(tester, _restore);
    await tester.tap(_confirm);
    await tester.pumpAndSettle();

    expect(find.text(_restoreFailed), findsOneWidget);
    expect(store.entries.single.name.value, 'Eski');
    expect(settings.stored, AppSettings.defaults);
    await _goTo(tester, 'myDhikrs');
    expect(find.text('Eski'), findsWidgets);
  });

  testWidgets('unreadable file message', (tester) async {
    await _start(
      tester,
      files: FakeBackupFiles(openOutcome: const OpenFailed()),
    );
    await _goTo(tester, 'settings');
    await _tap(tester, _restore);

    expect(_dialog, findsNothing);
    expect(find.text('Dosya açılamadı.'), findsOneWidget);
  });

  testWidgets('zero dhikrs in summary', (tester) async {
    final store = FakeDhikrStore([('Eski', CounterState.initial)]);
    final history = FakeHistoryRepository();
    final settings = FakeSettingsRepository();
    final empty = _snapshot(dhikrs: const [], selected: null, days: const []);
    await _start(
      tester,
      store: store,
      history: history,
      settings: settings,
      backupStore: FakeBackupStore(
        onReplace: _writeInto(
          store: store,
          history: history,
          settings: settings,
        ),
      ),
      files: FakeBackupFiles(openOutcome: _file(empty)),
    );
    await _goTo(tester, 'settings');
    await _tap(tester, _restore);
    expect(find.text('7 Kasım 2026 21:30 · 0 zikir'), findsOneWidget);
    await tester.tap(_confirm);
    await tester.pumpAndSettle();

    await _goTo(tester, 'myDhikrs');
    expect(find.text('Eski'), findsNothing);
    expect(store.entries, isEmpty);
    expect(find.byKey(const Key('dhikr-name')), findsNothing);
  });

  testWidgets('restore clears resume point', (tester) async {
    final store = FakeDhikrStore([
      ('Eski', CounterState(count: DhikrCount.zero, target: Target.of(33))),
    ]);
    final history = FakeHistoryRepository();
    final settings = FakeSettingsRepository(
      stored: const AppSettings(
        vibration: true,
        theme: ThemeChoice.system,
        continueNotification: true,
      ),
    );
    final notifier = FakeContinueNotifier(granted: true);
    // The backup keeps the setting on and has the same dhikr id 1.
    final snapshot = _snapshot(
      settings: _darkSettings.withContinueNotification(true),
    );
    await _start(
      tester,
      size: const Size(400, 800),
      store: store,
      history: history,
      settings: settings,
      notifier: notifier,
      backupStore: FakeBackupStore(
        onReplace: _writeInto(
          store: store,
          history: history,
          settings: settings,
        ),
      ),
      files: FakeBackupFiles(openOutcome: _file(snapshot)),
    );
    await tester.tap(find.byKey(const Key('counter-tap-area')));
    await tester.pump();

    Future<void> leaveAndComeBack() async {
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
    }

    // Before: leaving shows where the user left off.
    await leaveAndComeBack();
    expect(notifier.shown, isNotNull);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(notifier.shown, isNull);

    await _goTo(tester, 'settings');
    await _tap(tester, _restore);
    await tester.tap(_confirm);
    await tester.pumpAndSettle();
    expect(find.text('Yedek geri yüklendi'), findsOneWidget);
    expect(settings.stored.continueNotification, isTrue);

    // After: no resume point, so leaving shows nothing.
    final shows = notifier.shows.length;
    await leaveAndComeBack();
    expect(notifier.shown, isNull);
    expect(notifier.shows, hasLength(shows));
  });

  testWidgets('notification setting off without permission and no request', (
    tester,
  ) async {
    final backupStore = FakeBackupStore();
    final notifier = FakeContinueNotifier(grantOnRequest: true);
    final snapshot = _snapshot(
      settings: _darkSettings.withContinueNotification(true),
    );
    await _start(
      tester,
      backupStore: backupStore,
      notifier: notifier,
      files: FakeBackupFiles(openOutcome: _file(snapshot)),
    );
    await _goTo(tester, 'settings');
    await _tap(tester, _restore);
    await tester.tap(_confirm);
    await tester.pumpAndSettle();

    final restored = backupStore.replaced.single;
    expect(restored.settings.continueNotification, isFalse);
    expect(restored.settings.theme, 'dark'); // the rest as in the backup
    expect(restored.dhikrs, snapshot.data.dhikrs);
    expect(notifier.requests, 0);

    // With the permission the setting stays on.
    notifier.granted = true;
    await _tap(tester, _restore);
    await tester.tap(_confirm);
    await tester.pumpAndSettle();
    expect(backupStore.replaced.last.settings.continueNotification, isTrue);
    expect(notifier.requests, 0);
  });

  testWidgets('rows are one semantics node', (tester) async {
    final semantics = tester.ensureSemantics();
    await _start(
      tester,
      files: FakeBackupFiles(openOutcome: _file(_snapshot())),
    );
    await _goTo(tester, 'settings');
    await _show(tester, _note);

    for (final (row, title, subtitle) in [
      (_save, 'Yedekle', 'Tüm verilerinizi bir dosyaya kaydeder'),
      (
        _restore,
        'Geri yükle',
        'Bir yedek dosyasından verilerinizi geri getirir',
      ),
    ]) {
      final node = tester.getSemantics(row);
      expect(node.label, contains(title));
      expect(node.label, contains(subtitle));
      expect(node, isSemantics(isButton: true, hasTapAction: true));
      expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
    }
    expect(
      tester.getSemantics(find.text('Yedekleme')),
      isSemantics(isHeader: true),
    );
    expect(
      tester.getSemantics(_note).label,
      contains('Yedek dosyası şifresizdir.'),
    );

    // The confirmation's text and buttons are read.
    await _tap(tester, _restore);
    expect(tester.getSemantics(find.text(_warning)).label, contains(_warning));
    expect(
      tester.getSemantics(find.text('7 Kasım 2026 21:30 · 2 zikir')).label,
      contains('2 zikir'),
    );
    expect(
      tester.getSemantics(_cancel),
      isSemantics(isButton: true, label: 'Vazgeç'),
    );
    expect(
      tester.getSemantics(_confirm),
      isSemantics(isButton: true, label: 'Geri yükle'),
    );
    semantics.dispose();
  });

  testWidgets('messages announced', (tester) async {
    final semantics = tester.ensureSemantics();
    final files = FakeBackupFiles(saveOutcome: SaveOutcome.saved);
    final backupStore = FakeBackupStore();
    await _start(tester, files: files, backupStore: backupStore);
    await _goTo(tester, 'settings');

    Future<void> expectAnnounced(String key, String text) async {
      expect(_message(key), findsOneWidget, reason: key);
      expect(
        tester.getSemantics(find.text(text)),
        isSemantics(label: text, isLiveRegion: true),
        reason: key,
      );
      ScaffoldMessenger.of(tester.element(_save)).removeCurrentSnackBar();
      await tester.pumpAndSettle();
    }

    await _tap(tester, _save);
    await expectAnnounced('backup-saved', 'Yedek kaydedildi');
    files.saveOutcome = SaveOutcome.failed;
    await _tap(tester, _save);
    await expectAnnounced('backup-save-failed', 'Yedek kaydedilemedi.');

    for (final (outcome, key, text) in [
      (Opened(utf8.encode('x')), 'backup-invalid', _invalid),
      (
        Opened(utf8.encode('{"format":"zikirmatik-yedek","formatVersion":9}')),
        'backup-too-new',
        _tooNew,
      ),
      (const OpenFailed(), 'backup-open-failed', 'Dosya açılamadı.'),
    ]) {
      files.openOutcome = outcome;
      await _tap(tester, _restore);
      await expectAnnounced(key, text);
    }

    files.openOutcome = _file(_snapshot());
    await _tap(tester, _restore);
    await tester.tap(_confirm);
    await tester.pumpAndSettle();
    await expectAnnounced('backup-restored', 'Yedek geri yüklendi');

    backupStore.failReplace = true;
    await _tap(tester, _restore);
    await tester.tap(_confirm);
    await tester.pumpAndSettle();
    await expectAnnounced('backup-restore-failed', _restoreFailed);
    semantics.dispose();
  });

  testWidgets('largest text at 320 dp', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _start(
      tester,
      size: const Size(320, 640),
      files: FakeBackupFiles(openOutcome: _file(_snapshot())),
    );
    await _goTo(tester, 'settings');

    void expectWhole(Finder text) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: text, matching: find.byType(RichText)).first,
      );
      expect(paragraph.didExceedMaxLines, isFalse);
      final whole = TextPainter(
        text: paragraph.text,
        textDirection: paragraph.textDirection,
        textScaler: paragraph.textScaler,
      )..layout(maxWidth: paragraph.size.width);
      addTearDown(whole.dispose);
      expect(paragraph.size.height, greaterThanOrEqualTo(whole.height - 0.5));
    }

    for (final text in [
      'Yedekleme',
      'Yedekle',
      'Tüm verilerinizi bir dosyaya kaydeder',
      'Geri yükle',
      'Bir yedek dosyasından verilerinizi geri getirir',
      'Yedek dosyası şifresizdir.',
    ]) {
      await _show(tester, find.text(text));
      expectWhole(find.text(text));
    }
    expect(tester.takeException(), isNull);

    await _tap(tester, _restore);
    expect(tester.takeException(), isNull);
    expectWhole(find.text(_warning));
    expectWhole(find.text('7 Kasım 2026 21:30 · 2 zikir'));
    expectWhole(find.text('Vazgeç'));
  });

  testWidgets('light and dark', (tester) async {
    for (final brightness in Brightness.values) {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(const SizedBox());
      await _start(tester);
      await _goTo(tester, 'settings');
      await _show(tester, _note);

      final context = tester.element(_note);
      final theme = Theme.of(context);
      expect(theme.brightness, brightness);
      final background = theme.colorScheme.surface;
      for (final text in [
        'Yedekleme',
        'Yedekle',
        'Tüm verilerinizi bir dosyaya kaydeder',
        'Yedek dosyası şifresizdir.',
      ]) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        );
        final color = paragraph.text.style!.color!;
        expect(
          contrast(color, background),
          greaterThanOrEqualTo(4.5),
          reason: '$brightness $text',
        );
      }
    }
  });
}
