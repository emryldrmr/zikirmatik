/// Public interface of the suggested dhikrs feature (docs/architecture.md,
/// FD-2). Other features and the composition root import only this file.
library;

export 'data/asset_suggested_repository.dart' show AssetSuggestedRepository;
export 'domain/suggested_dhikr.dart' show SuggestedDhikr;
export 'domain/suggested_repository.dart' show SuggestedRepository;
export 'ui/suggested_providers.dart' show suggestedRepositoryProvider;
export 'ui/suggested_screen.dart' show SuggestedScreen;
