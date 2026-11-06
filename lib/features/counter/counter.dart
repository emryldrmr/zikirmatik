/// Public interface of the counter feature (docs/architecture.md, FD-2).
/// Other features and the composition root import only this file.
library;

export 'data/drift_counter_repository.dart' show DriftCounterRepository;
export 'data/drift_dhikr_list_repository.dart' show DriftDhikrListRepository;
export 'data/drift_tesbihat_repository.dart' show DriftTesbihatRepository;
export 'domain/counter_repository.dart' show CounterRepository;
export 'domain/counter_state.dart' show CounterState, TapOutcome;
export 'domain/dhikr_count.dart' show DhikrCount;
export 'domain/dhikr_list.dart' show DhikrEntry, DhikrList;
export 'domain/dhikr_list_repository.dart' show DhikrListRepository;
export 'domain/dhikr_name.dart' show DhikrName;
export 'domain/target.dart' show Target;
export 'domain/tesbihat_repository.dart' show TesbihatRepository;
export 'domain/tesbihat_state.dart' show TesbihatState;
export 'ui/counter_providers.dart'
    show
        counterRepositoryForProvider,
        dhikrListRepositoryProvider,
        tesbihatRepositoryProvider;
export 'ui/counter_screen.dart' show CounterScreen;
