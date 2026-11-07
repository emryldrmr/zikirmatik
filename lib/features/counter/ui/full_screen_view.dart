import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/display.dart';
import '../../../core/hand_layout.dart';
import '../../../core/screen.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/counter_state.dart';
import '../domain/dhikr_list.dart';
import '../domain/tesbihat.dart';
import '../domain/tesbihat_state.dart';
import 'counter_controller.dart';
import 'device_parts.dart';
import 'tesbihat_controller.dart';

/// Opens full screen counting (spec 0010) for [entry], or for the tesbihat
/// when [entry] is null. A page above the shell (plan R3): the system back
/// gesture closes it; the shell's own back rules (spec 0005) are untouched.
Future<void> openFullScreen(BuildContext context, {DhikrEntry? entry}) =>
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => FullScreenView(entry: entry),
      ),
    );

/// The "Tam ekran" button under a dhikr's or the tesbihat's device (AC-1).
class FullScreenButton extends StatelessWidget {
  const FullScreenButton({super.key, this.entry});

  final DhikrEntry? entry;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const Key('full-screen-open'),
    style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
    icon: const Icon(Icons.fullscreen),
    label: Text(AppLocalizations.of(context).fullScreen),
    onPressed: () => openFullScreen(context, entry: entry),
  );
}

/// Full screen counting (spec 0010, Req. 2–6): the system bars hidden, the
/// whole screen a count area, only "Geri al" and "Kapat" on top of it.
class FullScreenView extends ConsumerStatefulWidget {
  const FullScreenView({super.key, this.entry});

  /// The dhikr counted; null for the tesbihat.
  final DhikrEntry? entry;

  @override
  ConsumerState<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends ConsumerState<FullScreenView>
    with WidgetsBindingObserver {
  late final SystemBars _bars;

  @override
  void initState() {
    super.initState();
    _bars = ref.read(systemBarsProvider);
    WidgetsBinding.instance.addObserver(this);
    unawaited(_bars.hide());
  }

  /// Req. 6: back from the background, the bars are hidden again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_bars.hide());
  }

  /// Closing by "Kapat" or by the back gesture both end here (plan R4).
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_bars.show());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final content = entry == null
        ? _tesbihat(ref.watch(tesbihatControllerProvider))
        : _dhikr(entry, ref.watch(counterControllerProvider(entry.id)));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: const Key('full-screen'),
        backgroundColor: deviceBodyColor,
        body: content,
      ),
    );
  }

  Widget _dhikr(DhikrEntry entry, AsyncValue<CounterState> counter) {
    final state = counter.valueOrNull;
    if (state == null) return const _Frame();
    final controller = ref.read(counterControllerProvider(entry.id).notifier);
    final l10n = AppLocalizations.of(context);
    return _Frame(
      onUndo: state.count.value == 0 ? null : controller.undo,
      area: _CountArea(
        label: l10n.counterSemantics(state.count.value),
        onCount: controller.tap,
      ),
      info: _DhikrInfo(name: entry.name.value, state: state),
    );
  }

  Widget _tesbihat(AsyncValue<TesbihatState> tesbihat) {
    final state = tesbihat.valueOrNull;
    if (state == null) return const _Frame();
    final controller = ref.read(tesbihatControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final steps = namazSonrasiTesbihat.steps;
    final step = steps[state.step];
    return _Frame(
      // A finished tesbihat has no undo, as on the normal screen (G6).
      showUndo: !state.finished,
      onUndo: state.count.value == 0 ? null : controller.undo,
      area: _CountArea(
        label: state.finished
            ? l10n.tesbihatFinished
            : l10n.tesbihatStepSemantics(
                step.text,
                state.step + 1,
                steps.length,
                state.count.value,
                step.target.value,
              ),
        onCount: controller.tap,
        enabled: !state.finished,
      ),
      info: _TesbihatInfo(state: state),
    );
  }
}

/// The count area under the information, with "Geri al" and "Kapat" in the
/// corners above it. The information ignores touches, so a touch on it lands
/// on the area; a touch on a button never does (AC-6).
///
/// The corners follow the hand (spec 0011, Req. 5): in the centre layout
/// "Geri al" is top left and "Kapat" top right, as in spec 0010; for the right
/// or left hand "Geri al" moves to that hand's bottom corner and "Kapat" to
/// the opposite top corner.
class _Frame extends ConsumerWidget {
  const _Frame({this.area, this.info, this.onUndo, this.showUndo = true});

  final Widget? area;
  final Widget? info;
  final VoidCallback? onUndo;
  final bool showUndo;

  /// Gives [child] a fixed place in the screen reader's reading order; its
  /// own nodes stay as they are (each line read on its own).
  static Widget _inOrder(double order, Widget child) => Semantics(
    container: true,
    explicitChildNodes: true,
    sortKey: OrdinalSortKey(order),
    child: child,
  );

  /// Room the information keeps free for a bottom "Geri al" (plan 0011, R4).
  static const _buttonRoom = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hand = ref.watch(handLayoutProvider);
    final undoBelow = hand != HandLayout.center;
    // Plan 0011, R4: above the system's bottom edge gesture area, which stays
    // when the bars are hidden (the view padding is then 0).
    final media = MediaQuery.of(context);
    final bottomInset =
        media.systemGestureInsets.bottom > media.viewPadding.bottom
        ? media.systemGestureInsets.bottom
        : media.viewPadding.bottom;

    // AC-10: a screen reader reads the count area, "Geri al", "Kapat", then
    // the information, whichever corners the buttons are in.
    final undo = showUndo && area != null
        ? _inOrder(
            1,
            IconButton(
              key: const Key('full-screen-undo'),
              color: deviceBodyText,
              disabledColor: deviceBodyText.withValues(alpha: 0.38),
              iconSize: 32,
              icon: Icon(Icons.undo, semanticLabel: l10n.undo),
              onPressed: onUndo,
            ),
          )
        : null;
    final close = _inOrder(
      2,
      IconButton(
        key: const Key('full-screen-close'),
        color: deviceBodyText,
        iconSize: 32,
        icon: Icon(Icons.close, semanticLabel: l10n.fullScreenClose),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (area != null) _inOrder(0, area!),
        if (info != null)
          IgnorePointer(
            child: SafeArea(
              minimum: EdgeInsets.fromLTRB(
                24,
                _buttonRoom,
                24,
                undoBelow ? bottomInset + _buttonRoom : 24,
              ),
              child: Center(child: _inOrder(3, info!)),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                children: switch (hand) {
                  HandLayout.center => [?undo, const Spacer(), close],
                  HandLayout.right => [close, const Spacer()],
                  HandLayout.left => [const Spacer(), close],
                },
              ),
            ),
          ),
        ),
        if (undoBelow && undo != null)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, bottomInset + 8),
              child: Align(
                alignment: hand == HandLayout.right
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: undo,
              ),
            ),
          ),
      ],
    );
  }
}

/// The whole screen as the count button (Req. 3, plan R2): one count when the
/// last finger lifts, so two fingers count once and fast taps are never lost
/// (no double-tap wait); nothing when the system cancels the touch (a back
/// gesture) or when a finger moved more than [swipeLimit] — a swipe, such as
/// pulling the system bar up from the bottom edge (plan A-1). A screen reader
/// activates it like the normal count button.
class _CountArea extends StatefulWidget {
  const _CountArea({
    required this.label,
    required this.onCount,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onCount;
  final bool enabled;

  @override
  State<_CountArea> createState() => _CountAreaState();
}

/// How far a finger may move and still tap (plan A-1): holding the phone
/// moves it a little; a swipe moves it more.
const swipeLimit = 64.0;

class _CountAreaState extends State<_CountArea> {
  /// Where each finger now down touched first.
  final Map<int, Offset> _down = {};
  bool _cancelled = false;

  void _onDown(PointerDownEvent e) {
    if (_down.isEmpty) _cancelled = false;
    _down[e.pointer] = e.position;
  }

  void _onMove(PointerMoveEvent e) {
    final start = _down[e.pointer];
    if (start != null && (e.position - start).distance > swipeLimit) {
      _cancelled = true;
    }
  }

  void _onUp(PointerUpEvent e) {
    if (_down.remove(e.pointer) == null) return;
    if (_down.isEmpty && !_cancelled && widget.enabled) widget.onCount();
  }

  void _onCancel(PointerCancelEvent e) {
    if (_down.remove(e.pointer) != null) _cancelled = true;
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    enabled: widget.enabled,
    label: widget.label,
    excludeSemantics: true,
    onTap: widget.enabled ? widget.onCount : null,
    child: Listener(
      key: const Key('full-screen-tap-area'),
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onCancel,
      child: const SizedBox.expand(),
    ),
  );
}

/// AC-2: the dhikr's name, the count, target and round, and the total.
class _DhikrInfo extends StatelessWidget {
  const _DhikrInfo({required this.name, required this.state});

  final String name;
  final CounterState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final target = state.target;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          key: const Key('full-screen-name'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(color: deviceBodyText),
        ),
        const SizedBox(height: 16),
        // Review round 1, F-1: on a short screen the count gives way.
        Flexible(child: _BigCount(count: state.count.value)),
        const SizedBox(height: 16),
        _OneLine(
          Text(
            target == null
                ? l10n.targetNone
                : l10n.targetAndRound(
                    thousands.format(target.value),
                    thousands.format(state.rounds),
                  ),
            key: const Key('full-screen-target'),
            style: theme.textTheme.titleLarge?.copyWith(color: deviceBodyText),
          ),
        ),
        _OneLine(
          Text(
            l10n.totalLabel(thousands.format(state.total)),
            key: const Key('full-screen-total'),
            style: theme.textTheme.titleMedium?.copyWith(color: deviceBodyText),
          ),
        ),
      ],
    );
  }
}

/// AC-5: the step's text (BR-12: exactly as stored, never cut — it shrinks
/// only to fit the width, plan R5, review round 1 F-1), "Adım x/y", the count
/// and the target; or the finish.
class _TesbihatInfo extends StatelessWidget {
  const _TesbihatInfo({required this.state});

  final TesbihatState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final steps = namazSonrasiTesbihat.steps;
    final step = steps[state.step];
    if (state.finished) {
      return Semantics(
        liveRegion: true,
        child: Text(
          l10n.tesbihatFinished,
          key: const Key('full-screen-finished'),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: deviceBodyText,
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Review round 1, F-1: the text keeps its height; it shrinks only to
        // fit the width. When the screen is short, the count gives way.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Semantics(
            liveRegion: true,
            label: l10n.tesbihatStepAnnouncement(
              step.text,
              state.step + 1,
              steps.length,
            ),
            excludeSemantics: true,
            child: Text(
              step.text,
              key: const Key('full-screen-step-text'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: deviceBodyText,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _OneLine(
          Text(
            l10n.tesbihatStep(state.step + 1, steps.length),
            key: const Key('full-screen-step'),
            style: theme.textTheme.titleLarge?.copyWith(color: deviceBodyText),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(child: _BigCount(count: state.count.value)),
        const SizedBox(height: 16),
        _OneLine(
          Text(
            l10n.tesbihatTarget(thousands.format(step.target.value)),
            key: const Key('full-screen-target'),
            style: theme.textTheme.titleLarge?.copyWith(color: deviceBodyText),
          ),
        ),
      ],
    );
  }
}

/// The count in the middle; larger with "Büyük rakam" (spec 0011, Req. 2). It
/// shrinks to fit, never cut (Req. 3).
class _BigCount extends ConsumerWidget {
  const _BigCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      '$count',
      key: const Key('full-screen-count'),
      maxLines: 1,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        color: deviceBodyText,
        fontSize: ref.watch(largeCountEnabledProvider)
            ? 120 * largeCountScale
            : 120,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

/// A short information line (target and round, total, "Adım x/y") in the
/// hand layouts: kept on one line, shrinking only when it does not fit the
/// width — never cut — so the count keeps its room above the bottom "Geri al"
/// (plan 0011, A-2). The centre layout shows it as spec 0010 does (AC-2).
class _OneLine extends ConsumerWidget {
  const _OneLine(this.text);

  final Text text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(handLayoutProvider) == HandLayout.center) return text;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text.data!, key: text.key, maxLines: 1, style: text.style),
    );
  }
}
