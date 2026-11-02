import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Asks before a destructive action (BR-6). True only when the user confirms.
Future<bool> confirmAction(
  BuildContext context, {
  required String message,
  required String confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      key: const Key('confirm-dialog'),
      content: Text(message),
      actions: [
        TextButton(
          key: const Key('confirm-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('confirm-ok'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
