/// Public interface of the Esmaü'l-Hüsna feature (docs/architecture.md, FD-2).
/// Other features and the composition root import only this file.
library;

export 'data/asset_esma_repository.dart' show AssetEsmaRepository;
export 'domain/asma_name.dart' show AsmaName;
export 'domain/esma_repository.dart' show EsmaRepository;
export 'ui/esma_providers.dart' show esmaRepositoryProvider;
