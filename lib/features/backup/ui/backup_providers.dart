import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/backup_ports.dart';

/// All the user's stored data (spec 0018). Has no default: the composition
/// root overrides it with the drift store, tests with a fake.
final backupStoreProvider = Provider<BackupStore>(
  (ref) => throw UnimplementedError(
    'backupStoreProvider must be overridden in the composition root.',
  ),
);

/// The phone's save and open dialogs (spec 0018). Overridden like
/// [backupStoreProvider].
final backupFilesProvider = Provider<BackupFiles>(
  (ref) => throw UnimplementedError(
    'backupFilesProvider must be overridden in the composition root.',
  ),
);

/// The backup file's format (plan 0018, A-2). Overridden like
/// [backupStoreProvider]; tests bind the real JSON one.
final backupFormatProvider = Provider<BackupFormat>(
  (ref) => throw UnimplementedError(
    'backupFormatProvider must be overridden in the composition root.',
  ),
);

/// Called after a restore was stored (plan 0018, R4), so every feature reads
/// its data again without a restart. Does nothing by default; the composition
/// root binds it, so this feature need not reach into the others (FD-2).
final backupRestoredProvider = Provider<void Function()>((ref) => () {});
