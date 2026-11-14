import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/continue_notifier.dart';

/// The status bar icon: a single-colour vector (plan 0017, R5).
const continueIcon = 'ic_stat_continue';

/// The one continue notification's id: a new one replaces the old (Req. 4).
const continueNotificationId = 17;

const _channelId = 'continue';

/// Silent, low and replaceable (spec 0017, Req. 4; AC-5): no sound, no
/// vibration, no heads-up, alerts once; swipe to dismiss; shown on the lock
/// screen too (G4). [channelName] is the channel's name in the phone's
/// settings.
NotificationDetails continueDetails({required String channelName}) =>
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        channelName,
        icon: continueIcon,
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
        enableLights: false,
        onlyAlertOnce: true,
        ongoing: false,
        autoCancel: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
      ),
    );

/// [ContinueNotifier] through `flutter_local_notifications` (plan 0017, R2):
/// local only — no server, no network; nothing leaves the phone.
final class LocalContinueNotifier implements ContinueNotifier {
  LocalContinueNotifier({required this.channelName});

  /// The channel's name in the phone's settings (`continueChannelName`).
  final String channelName;

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(continueIcon),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null) _taps.add(payload);
        },
      )
      .then((_) {});

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  // Notifications are a convenience: a failing platform call is swallowed,
  // counting and the app go on without them.
  Future<T> _safe<T>(Future<T> Function() call, T fallback) async {
    try {
      await _init();
      return await call();
    } on Object catch (_) {
      return fallback;
    }
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    required String payload,
  }) => _safe(
    () => _plugin.show(
      id: continueNotificationId,
      title: title,
      body: body,
      notificationDetails: continueDetails(channelName: channelName),
      payload: payload,
    ),
    null,
  );

  @override
  Future<void> cancel() =>
      _safe(() => _plugin.cancel(id: continueNotificationId), null);

  @override
  Future<bool> permitted() => _safe(
    () async => await _android?.areNotificationsEnabled() ?? false,
    false,
  );

  @override
  Future<bool> requestPermission() => _safe(
    () async => await _android?.requestNotificationsPermission() ?? false,
    false,
  );

  @override
  Future<String?> launchPayload() => _safe(() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
  }, null);

  @override
  Stream<String> get taps {
    unawaited(_init().catchError((Object _) {}));
    return _taps.stream;
  }
}
