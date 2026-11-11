import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notice_keep_clear.dart';
import '../core/storage_notice.dart';
import '../l10n/app_localizations.dart';

/// The one place a storage failure is shown (spec 0015): a short message over
/// every route — the shell, full screen counting, forms and dialogs (Req 7).
/// It looks like the app's snackbars (their theme colours and floating shape;
/// no new visual, plan R1), but it is not one: it never takes a touch, so a
/// tap on it reaches the counter underneath (AC-10). It has no fixed height,
/// so the largest text wraps instead of being clipped.
///
/// It sits at the bottom, above the keyboard when one is open; when there it
/// would cover the count button (large text), it sits at the top instead
/// (plan 0015 R6, A-1). It is laid out over the whole app, so its own
/// coordinates are the screen's.
class StorageNoticeBanner extends ConsumerWidget {
  const StorageNoticeBanner({super.key});

  /// Distance to the screen edges and the safe area.
  static const margin = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(storageNoticeProvider);
    if (notice == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final snackBar = theme.snackBarTheme;
    final colors = theme.colorScheme;
    final text = switch (notice) {
      StorageNotice.mayBeLost => l10n.storageMayBeLost,
      StorageNotice.notSaved => l10n.storageNotSaved,
      StorageNotice.tesbihatNotLoaded => l10n.storageTesbihatNotLoaded,
    };

    return IgnorePointer(
      child: CustomSingleChildLayout(
        delegate: _Placement(
          // Where the count button was laid out in the last frame: its
          // place on the screen now (layout may not read other subtrees).
          keepClear: ref.watch(noticeKeepClearProvider).shown.toList(),
          safe: MediaQuery.viewPaddingOf(context),
          keyboard: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Semantics(
          key: const Key('storage-notice'),
          container: true,
          liveRegion: true,
          child: Material(
            color: snackBar.backgroundColor ?? colors.inverseSurface,
            elevation: snackBar.elevation ?? 6,
            shape:
                snackBar.shape ??
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                text,
                style:
                    snackBar.contentTextStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onInverseSurface,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Placement extends SingleChildLayoutDelegate {
  _Placement({
    required this.keepClear,
    required this.safe,
    required this.keyboard,
  });

  final List<Rect> keepClear;
  final EdgeInsets safe;
  final double keyboard;

  static const _m = StorageNoticeBanner.margin;

  double get _bottomInset => math.max(safe.bottom, keyboard) + _m;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final width = math.max(
      0.0,
      constraints.maxWidth - safe.horizontal - 2 * _m,
    );
    final height = math.max(
      0.0,
      constraints.maxHeight - safe.top - _m - _bottomInset,
    );
    return BoxConstraints(minWidth: width, maxWidth: width, maxHeight: height);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = safe.left + _m;
    final bottom = Offset(left, size.height - _bottomInset - childSize.height);
    final covers = keepClear.any((r) => (bottom & childSize).overlaps(r));
    return covers ? Offset(left, safe.top + _m) : bottom;
  }

  // Rebuilt only while a message shows; the rectangles are new each build.
  @override
  bool shouldRelayout(_Placement oldDelegate) => true;
}
