import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/screen.dart';

/// Keeps the screen on while Zikirlerim is in front and the setting is on
/// (spec 0010, Req. 8, AC-9). Wraps the Zikirlerim body: the shell swaps
/// bodies per section, so "in front" means mounted here; the full screen view
/// opens above it and leaves it mounted. Gives the screen back to the system
/// when it leaves (another section), when the app goes to the background, and
/// when the setting is turned off.
class KeepScreenAwake extends ConsumerStatefulWidget {
  const KeepScreenAwake({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<KeepScreenAwake> createState() => _KeepScreenAwakeState();
}

class _KeepScreenAwakeState extends ConsumerState<KeepScreenAwake>
    with WidgetsBindingObserver {
  late final ScreenAwake _screen;

  bool _foreground = true;

  /// What was last asked of the phone; nothing is asked while the setting is
  /// off and nothing was kept on (AC-9: never on when off).
  bool _kept = false;

  @override
  void initState() {
    super.initState();
    _screen = ref.read(screenAwakeProvider);
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = switch (state) {
      AppLifecycleState.resumed => true,
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => false,
      // A shade or a dialog over the app: it is still in front.
      AppLifecycleState.inactive => _foreground,
    };
    // Applied here, not by a rebuild: no frames are drawn in the background.
    _foreground = foreground;
    _apply(ref.read(keepScreenOnEnabledProvider) && _foreground);
  }

  void _apply(bool on) {
    if (on == _kept) return;
    _kept = on;
    unawaited(_screen.set(on: on));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _apply(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _apply(ref.watch(keepScreenOnEnabledProvider) && _foreground);
    return widget.child;
  }
}
