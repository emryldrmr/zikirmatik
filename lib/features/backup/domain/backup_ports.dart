import 'dart:typed_data';

import '../../../core/result.dart';
import 'backup_snapshot.dart';

/// The largest backup file that is read (spec 0018, Req. 5, G4): 5 MB.
const int maxBackupBytes = 5 * 1024 * 1024;

/// All of the user's stored data at once (spec 0018, Req. 5): read in one go,
/// replaced in one transaction — all of it or nothing.
abstract interface class BackupStore {
  Future<Result<BackupData>> read();

  /// Replaces every stored dhikr, counter, selection, tesbihat progress, day
  /// and setting with [data] (Req. 3: no merging). On failure nothing changed.
  Future<Result<void>> replaceAll(BackupData data);
}

/// How the system save dialog ended (Req. 2, Req. 7).
enum SaveOutcome { saved, cancelled, failed }

/// How the system open dialog ended (Req. 3, Req. 5, Req. 7).
sealed class OpenOutcome {
  const OpenOutcome();
}

final class Opened extends OpenOutcome {
  const Opened(this.bytes);

  final Uint8List bytes;
}

/// The user closed the dialog (G3): nothing happens.
final class OpenCancelled extends OpenOutcome {
  const OpenCancelled();
}

/// The file is over [maxBackupBytes]; it was not read (G4).
final class OpenTooLarge extends OpenOutcome {
  const OpenTooLarge();
}

/// The file could not be read (G5).
final class OpenFailed extends OpenOutcome {
  const OpenFailed();
}

/// The phone's own save and open dialogs (spec 0018, D3), behind an
/// interface so tests need no platform channel (docs/conventions.md, Known
/// traps). Only the file the user picks is touched.
abstract interface class BackupFiles {
  /// Opens the save dialog suggesting [name]; writes [bytes] where the user
  /// chooses.
  Future<SaveOutcome> save(String name, Uint8List bytes);

  /// Opens the open dialog; reads the chosen file up to [maxBackupBytes].
  Future<OpenOutcome> open();
}
