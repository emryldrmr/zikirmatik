import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/backup_ports.dart';
import '../domain/backup_snapshot.dart';
import 'backup_controller.dart';

/// "Yedekleme" in Ayarlar (spec 0018, Req. 6): the heading, "Yedekle" and
/// "Geri yükle" with their subtitles, and the note that the file is not
/// encrypted. Messages are short SnackBars, which screen readers announce.
class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  /// A dialog or a write is under way; further taps wait for it.
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    _busy = true;
    try {
      await action();
    } finally {
      _busy = false;
    }
  }

  Future<void> _backup() => _run(() async {
    final l10n = AppLocalizations.of(context);
    final outcome = await ref.read(backupControllerProvider).backup();
    switch (outcome) {
      case SaveOutcome.saved:
        _say('backup-saved', l10n.backupSaved);
      case SaveOutcome.failed:
        _say('backup-save-failed', l10n.backupSaveFailed);
      case SaveOutcome.cancelled:
        break; // G3
    }
  });

  Future<void> _restore() => _run(() async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(backupControllerProvider);
    switch (await controller.pickRestore()) {
      case PickCancelled():
        return; // G3
      case PickInvalid():
        _say('backup-invalid', l10n.backupInvalid);
      case PickTooNew():
        _say('backup-too-new', l10n.backupTooNew);
      case PickFailed():
        _say('backup-open-failed', l10n.backupOpenFailed);
      case PickedBackup(:final snapshot):
        if (!mounted || !await _confirm(snapshot)) return;
        if (await controller.confirmRestore(snapshot)) {
          _say('backup-restored', l10n.backupRestored);
        } else {
          _say('backup-restore-failed', l10n.backupRestoreFailed);
        }
    }
  });

  /// AC-4: the warning, the backup's date and how many dhikrs it holds.
  Future<bool> _confirm(BackupSnapshot snapshot) async {
    final l10n = AppLocalizations.of(context);
    final date = DateFormat(
      'd MMMM y HH:mm',
      'tr',
    ).format(snapshot.createdAt.toLocal());
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('backup-restore-dialog'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.backupRestoreWarning),
            const SizedBox(height: 12),
            Text(
              l10n.backupRestoreSummary(date, snapshot.data.dhikrs.length),
              key: const Key('backup-restore-summary'),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('backup-restore-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.backupCancel),
          ),
          TextButton(
            key: const Key('backup-restore-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.backupRestoreConfirm),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  void _say(String key, String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(key: Key(key), content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      key: const Key('backup-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Semantics(
            header: true,
            child: Text(l10n.settingsBackup, style: theme.textTheme.titleSmall),
          ),
        ),
        MergeSemantics(
          child: ListTile(
            key: const Key('backup-save'),
            title: Text(l10n.backupSave),
            subtitle: Text(l10n.backupSaveSubtitle),
            onTap: _backup,
          ),
        ),
        MergeSemantics(
          child: ListTile(
            key: const Key('backup-restore'),
            title: Text(l10n.backupRestore),
            subtitle: Text(l10n.backupRestoreSubtitle),
            onTap: _restore,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Text(
            l10n.backupUnencryptedNote,
            key: const Key('backup-note'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
