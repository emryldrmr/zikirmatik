import 'package:flutter/services.dart';

import '../domain/backup_ports.dart';

/// [BackupFiles] through the app's own `zikirmatik/backup` channel to
/// `MainActivity`, which opens the system save and open dialogs (plan 0018,
/// R3): no permission, no package. The size limit is enforced there, before
/// and while reading (G4).
final class ChannelBackupFiles implements BackupFiles {
  const ChannelBackupFiles();

  static const _channel = MethodChannel('zikirmatik/backup');

  @override
  Future<SaveOutcome> save(String name, Uint8List bytes) async {
    try {
      final status = await _channel.invokeMethod<String>('save', {
        'name': name,
        'bytes': bytes,
      });
      return switch (status) {
        'saved' => SaveOutcome.saved,
        'cancelled' => SaveOutcome.cancelled,
        _ => SaveOutcome.failed,
      };
    } on Object catch (_) {
      return SaveOutcome.failed;
    }
  }

  @override
  Future<OpenOutcome> open() async {
    try {
      final reply = await _channel.invokeMapMethod<String, Object?>('open');
      return switch (reply?['status']) {
        'opened' => switch (reply?['bytes']) {
          final Uint8List bytes => Opened(bytes),
          _ => const OpenFailed(),
        },
        'cancelled' => const OpenCancelled(),
        'tooLarge' => const OpenTooLarge(),
        _ => const OpenFailed(),
      };
    } on Object catch (_) {
      return const OpenFailed();
    }
  }
}
