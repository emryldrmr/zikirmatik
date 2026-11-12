import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../../../core/storage_notice.dart';
import '../domain/daily_history.dart';
import '../domain/history_repository.dart';
import 'history_providers.dart';

/// The daily counts (spec 0014): loading, error, or the current
/// [DailyHistory]. Kept alive for the app's lifetime.
final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, DailyHistory>(
      HistoryController.new,
    );

class HistoryController extends AsyncNotifier<DailyHistory> {
  late HistoryRepository _repo;

  /// Changes made while the first load is in flight. Storage runs its
  /// statements in order, so the load never holds them; they are applied on
  /// top of it (plan 0014, R2).
  final List<DailyHistory Function(DailyHistory)> _pending = [];
  bool _loading = true;

  @override
  Future<DailyHistory> build() async {
    _repo = ref.read(historyRepositoryProvider);
    final result = await _repo.load();
    _loading = false;
    switch (result) {
      case Ok(:final value):
        final history = _pending.fold(value, (h, change) => change(h));
        _pending.clear();
        return history;
      case Err(:final failure):
        _pending.clear();
        throw failure;
    }
  }

  /// Req. 1: one counting tap now, on the phone's current day (Req. 4).
  void counted() {
    final day = _today();
    _change((h) => h.added(day), () => _repo.add(day));
  }

  /// Req. 2: one tap taken back now; today stays at 0 when it is 0.
  void uncounted() {
    final day = _today();
    _change((h) => h.removed(day), () => _repo.remove(day));
  }

  Day _today() => Day.of(ref.read(clockProvider)());

  void _change(
    DailyHistory Function(DailyHistory) rule,
    Future<Result<void>> Function() store,
  ) {
    if (_loading) {
      _pending.add(rule);
    } else if (state case AsyncData(:final value)) {
      state = AsyncData(rule(value));
    }
    unawaited(_store(store));
  }

  // G5: a failed write never stops counting; it says the change may be lost
  // (spec 0015, Req 2).
  Future<void> _store(Future<Result<void>> Function() store) async {
    bool failed;
    try {
      failed = await store() is Err;
    } on Object catch (_) {
      failed = true;
    }
    if (failed) {
      ref.read(storageNoticeProvider.notifier).report(StorageNotice.mayBeLost);
    }
  }
}
