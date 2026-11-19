import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_version.dart';
import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../../notifications/notifications.dart';
import '../domain/backup_ports.dart';
import '../domain/backup_snapshot.dart';
import 'backup_providers.dart';

/// Backing up and restoring (spec 0018). The screen turns each outcome into
/// its message; nothing here shows anything.
final backupControllerProvider = Provider<BackupController>(
  BackupController.new,
);

/// What picking a file to restore gave (Req. 3, Req. 5, Req. 7).
sealed class PickOutcome {
  const PickOutcome();
}

/// A valid backup: the screen asks for confirmation (AC-4).
final class PickedBackup extends PickOutcome {
  const PickedBackup(this.snapshot);

  final BackupSnapshot snapshot;
}

/// The dialog was closed (G3): no message.
final class PickCancelled extends PickOutcome {
  const PickCancelled();
}

/// Not a valid backup, or over 5 MB (AC-6).
final class PickInvalid extends PickOutcome {
  const PickInvalid();
}

/// Taken with a newer format (AC-6).
final class PickTooNew extends PickOutcome {
  const PickTooNew();
}

/// The file could not be read (AC-7).
final class PickFailed extends PickOutcome {
  const PickFailed();
}

class BackupController {
  BackupController(this._ref);

  final Ref<Object?> _ref;

  /// Req. 2: reads everything, then opens the save dialog with
  /// `zikirmatik-yedek-YYYY-MM-DD.json` (local date). Unreadable data is a
  /// failed save; the dialog does not open.
  Future<SaveOutcome> backup() async {
    final data = await _ref.read(backupStoreProvider).read();
    if (data is! Ok<BackupData>) return SaveOutcome.failed;
    final now = _ref.read(clockProvider)();
    String? version;
    try {
      version = await _ref.read(appVersionProvider.future);
    } on Object catch (_) {
      version = null;
    }
    final bytes = _ref
        .read(backupFormatProvider)
        .encode(
          BackupSnapshot(createdAt: now, appVersion: version, data: data.value),
        );
    return _ref.read(backupFilesProvider).save(fileName(now), bytes);
  }

  /// Req. 2: the suggested file name, from the local date.
  static String fileName(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'zikirmatik-yedek-${now.year}-${two(now.month)}-${two(now.day)}'
        '.json';
  }

  /// Req. 3, Req. 5: opens the open dialog and checks the whole file; nothing
  /// is written here.
  Future<PickOutcome> pickRestore() async {
    switch (await _ref.read(backupFilesProvider).open()) {
      case OpenCancelled():
        return const PickCancelled();
      case OpenTooLarge():
        return const PickInvalid(); // G4
      case OpenFailed():
        return const PickFailed();
      case Opened(:final bytes):
        return switch (_ref.read(backupFormatProvider).decode(bytes)) {
          Valid(:final snapshot) => PickedBackup(snapshot),
          Invalid() => const PickInvalid(),
          TooNew() => const PickTooNew(),
        };
    }
  }

  /// Req. 3–4, Req. 8: replaces all data with [snapshot]'s. The continue
  /// notification setting is restored off when the phone does not permit
  /// notifications; permission is never asked for (G1). After it is stored,
  /// every feature reads its data again, the resume point is gone and a
  /// shown continue notification is removed. False when it could not be
  /// stored; then nothing changed (Req. 7).
  Future<bool> confirmRestore(BackupSnapshot snapshot) async {
    var data = snapshot.data;
    final notifier = _ref.read(continueNotifierProvider);
    if (data.settings.continueNotification && !await notifier.permitted()) {
      data = data.withSettings(data.settings.withContinueNotification(false));
    }
    if (await _ref.read(backupStoreProvider).replaceAll(data) case Err()) {
      return false;
    }
    _ref.read(backupRestoredProvider)();
    try {
      await notifier.cancel();
    } on Object catch (_) {
      // A notification that cannot be removed does not undo the restore.
    }
    return true;
  }
}
