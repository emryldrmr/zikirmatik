import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The areas the storage failure message must not cover (spec 0015, plan
/// A-1): the count button. The message shows at the bottom, or at the top when
/// at the bottom it would cover one of them.
///
/// It notifies when an area comes or goes (a sheet over the counter closes),
/// after the frame: the message is placed from where the areas were laid out,
/// and a change in another subtree does not lay it out again by itself.
final class NoticeKeepClearAreas extends ChangeNotifier {
  final Set<RenderBox> _boxes = {};
  bool _pending = false;
  bool _disposed = false;

  void _add(RenderBox box) {
    if (_boxes.add(box)) _changed();
  }

  void _remove(RenderBox box) {
    if (_boxes.remove(box)) _changed();
  }

  // Areas come and go while the tree is built, when no other widget may be
  // marked to rebuild: tell the listeners once that frame is done.
  void _changed() {
    if (_pending || !hasListeners) return;
    _pending = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        _pending = false;
        if (!_disposed) notifyListeners();
      })
      ..ensureVisualUpdate();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// The screen rectangles of the areas shown now: laid out, on the current
  /// route and not hidden.
  Iterable<Rect> get shown sync* {
    for (final box in _boxes) {
      if (!box.attached || !box.hasSize || _offstage(box)) continue;
      yield MatrixUtils.transformRect(
        box.getTransformTo(null),
        Offset.zero & box.size,
      );
    }
  }

  static bool _offstage(RenderObject box) {
    for (RenderObject? o = box.parent; o != null; o = o.parent) {
      if (o is RenderOffstage && o.offstage) return true;
    }
    return false;
  }
}

final noticeKeepClearProvider = Provider<NoticeKeepClearAreas>((ref) {
  final areas = NoticeKeepClearAreas();
  ref.onDispose(areas.dispose);
  return areas;
});

/// Marks [child] as an area the storage failure message keeps clear of, while
/// its route is the current one (under a dialog or another page it is not
/// reachable anyway).
class NoticeKeepClear extends ConsumerWidget {
  const NoticeKeepClear({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _KeepClear(
    areas: ModalRoute.isCurrentOf(context) ?? true
        ? ref.watch(noticeKeepClearProvider)
        : null,
    child: child,
  );
}

class _KeepClear extends SingleChildRenderObjectWidget {
  const _KeepClear({required this.areas, super.child});

  final NoticeKeepClearAreas? areas;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderKeepClear(areas);

  @override
  void updateRenderObject(BuildContext context, _RenderKeepClear renderObject) {
    renderObject.areas = areas;
  }
}

class _RenderKeepClear extends RenderProxyBox {
  _RenderKeepClear(this._areas);

  NoticeKeepClearAreas? _areas;

  set areas(NoticeKeepClearAreas? value) {
    if (value == _areas) return;
    _areas?._remove(this);
    _areas = value;
    if (attached) _areas?._add(this);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _areas?._add(this);
  }

  @override
  void detach() {
    _areas?._remove(this);
    super.detach();
  }
}
