/// Public interface of the backup feature (docs/architecture.md, FD-2).
/// Other features and the composition root import only this file.
library;

export 'data/channel_backup_files.dart' show ChannelBackupFiles;
export 'data/drift_backup_store.dart' show DriftBackupStore;
export 'domain/backup_ports.dart'
    show
        BackupFiles,
        BackupStore,
        OpenCancelled,
        OpenFailed,
        OpenOutcome,
        OpenTooLarge,
        Opened,
        SaveOutcome,
        maxBackupBytes;
export 'domain/backup_snapshot.dart'
    show
        BackupData,
        BackupDay,
        BackupDhikr,
        BackupSettings,
        BackupSnapshot,
        BackupTesbihat;
export 'ui/backup_providers.dart'
    show backupFilesProvider, backupRestoredProvider, backupStoreProvider;
