import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which short message a storage failure shows (spec 0015).
enum StorageNotice {
  /// Counting group (Req 2): the screen keeps the new value, which may be
  /// lost when the app closes.
  mayBeLost,

  /// List group (Req 3–4): the change was undone on the screen.
  notSaved,

  /// The tesbihat could not be read, so it does not open (Req 6).
  tesbihatNotLoaded,
}

/// How long a message stays up (Req 7: about four seconds).
const storageNoticeDuration = Duration(seconds: 4);

/// The message on screen now, or null. Features [StorageNoticeController.report]
/// failures; the app shows the message in one place, over every route.
final storageNoticeProvider =
    NotifierProvider<StorageNoticeController, StorageNotice?>(
      StorageNoticeController.new,
    );

class StorageNoticeController extends Notifier<StorageNotice?> {
  Timer? _timer;

  @override
  StorageNotice? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  /// Shows [notice] for [storageNoticeDuration]. While a message is up, new
  /// failures neither repeat it, replace it nor extend it (Req 5, plan R4).
  void report(StorageNotice notice) {
    if (state != null) return;
    state = notice;
    _timer = Timer(storageNoticeDuration, () {
      _timer = null;
      state = null;
    });
  }
}
