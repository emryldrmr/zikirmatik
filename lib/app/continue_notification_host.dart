import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/counter/counter.dart';
import '../features/notifications/notifications.dart';

/// The continue notification's life (spec 0017): shown when the app leaves
/// the screen after counting, removed when it comes back; a tap on it opens
/// the counter it names on Zikirlerim.
///
/// Platform calls are made straight from the lifecycle callbacks, never
/// through a rebuild: no frames are drawn while the app is away
/// (docs/conventions.md, Known traps).
class ContinueNotificationHost extends ConsumerStatefulWidget {
  const ContinueNotificationHost({
    required this.onOpenMyDhikrs,
    required this.child,
    super.key,
  });

  /// Brings Zikirlerim to the front of the shell (Req. 5).
  final VoidCallback onOpenMyDhikrs;

  final Widget child;

  @override
  ConsumerState<ContinueNotificationHost> createState() =>
      _ContinueNotificationHostState();
}

class _ContinueNotificationHostState
    extends ConsumerState<ContinueNotificationHost>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _taps;

  /// True from leaving until back in front, so one leave shows once.
  bool _away = false;

  ContinueNotifier get _notifier => ref.read(continueNotifierProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _taps = _notifier.taps.listen(_open);
    // Req. 6, cold start by the icon or the recent apps: starting is coming
    // to the front, but the first resumed is handled while the binding is
    // set up, before this observer exists (review 0017 round 1, F-1).
    _onShow();
    unawaited(_openLaunch());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_taps?.cancel());
    super.dispose();
  }

  // Req. 1, G4: leaving for the background, the recent apps or the lock
  // screen all make the app hidden (then paused); pulling down the
  // notification shade only makes it inactive, which is not leaving
  // (plan R3). An observer, not an AppLifecycleListener: it takes any
  // sequence of states.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        if (_away) return;
        _away = true;
        unawaited(_onHide());
      case AppLifecycleState.resumed:
        _away = false;
        _onShow();
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// Req. 1–4: where the user left off, if the setting is on, the phone
  /// allows it (Req. 8) and there is something to show (AC-3).
  Future<void> _onHide() async {
    if (!ref.read(continueNotificationEnabledProvider)) return;
    final point = ref.read(resumePointProvider);
    if (point == null) return;
    final notifier = _notifier;
    if (!await notifier.permitted()) return;
    final text = continueText(point);
    await notifier.show(
      title: text.title,
      body: text.body,
      payload: text.payload,
    );
  }

  /// Req. 6: back in front, by any way.
  void _onShow() => unawaited(_notifier.cancel());

  /// Req. 5, cold start: the app was started by the notification.
  Future<void> _openLaunch() async {
    final payload = await _notifier.launchPayload();
    if (payload != null) await _open(payload);
  }

  /// Req. 5: Zikirlerim with the notification's dhikr or tesbihat selected,
  /// above anything that was open (full screen, sheets, dialogs).
  Future<void> _open(String payload) async {
    final item = itemOf(payload);
    if (item == null || !mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onOpenMyDhikrs();
    await openCounted(ref, item);
  }

  @override
  Widget build(BuildContext context) {
    // Req. 6: removed when the setting is turned off or when there is no
    // longer anything to come back to (the dhikr was deleted, G1).
    ref
      ..listen(continueNotificationEnabledProvider, (_, on) {
        if (!on) unawaited(_notifier.cancel());
      })
      ..listen(lastCountedProvider, (_, item) {
        if (item == null) unawaited(_notifier.cancel());
      });
    return widget.child;
  }
}
