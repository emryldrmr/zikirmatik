/// Public interface of the daily history feature (docs/architecture.md, FD-2).
/// Other features and the composition root import only this file.
library;

export 'data/drift_history_repository.dart' show DriftHistoryRepository;
export 'domain/daily_history.dart' show DailyHistory, Day, DayCount;
export 'domain/history_repository.dart' show HistoryRepository;
export 'ui/history_controller.dart'
    show HistoryController, historyControllerProvider;
export 'ui/history_providers.dart' show historyRepositoryProvider;
export 'ui/history_screen.dart' show HistoryScreen;
