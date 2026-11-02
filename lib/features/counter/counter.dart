/// Public interface of the counter feature (docs/architecture.md, FD-2).
/// Other features and the composition root import only this file.
library;

export 'data/drift_counter_repository.dart' show DriftCounterRepository;
export 'domain/counter_repository.dart' show CounterRepository;
export 'domain/counter_state.dart' show CounterState, TapOutcome;
export 'domain/dhikr_count.dart' show DhikrCount;
export 'domain/target.dart' show Target;
export 'ui/counter_providers.dart' show counterRepositoryProvider;
export 'ui/counter_screen.dart' show CounterScreen;
