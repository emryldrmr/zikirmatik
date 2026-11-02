import 'package:flutter/material.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/target.dart';

/// What the user picked: a target, or explicitly no target.
final class TargetChoice {
  const TargetChoice(this.target);

  final Target? target;
}

/// Bottom sheet with "Hedef yok", the presets and "Özel…" (spec 0002, G3).
/// Returns null when the user dismisses it.
Future<TargetChoice?> showTargetPicker(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<TargetChoice>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        key: const Key('target-picker'),
        shrinkWrap: true,
        children: [
          ListTile(title: Text(l10n.targetPickerTitle)),
          ListTile(
            key: const Key('target-option-none'),
            title: Text(l10n.targetNone),
            onTap: () =>
                Navigator.of(sheetContext).pop(const TargetChoice(null)),
          ),
          for (final preset in Target.presets)
            ListTile(
              key: Key('target-option-${preset.value}'),
              title: Text('${preset.value}'),
              onTap: () => Navigator.of(sheetContext).pop(TargetChoice(preset)),
            ),
          ListTile(
            key: const Key('target-option-custom'),
            title: Text(l10n.targetCustom),
            onTap: () async {
              final custom = await showDialog<Target>(
                context: sheetContext,
                builder: (_) => const _CustomTargetDialog(),
              );
              if (custom != null && sheetContext.mounted) {
                Navigator.of(sheetContext).pop(TargetChoice(custom));
              }
            },
          ),
        ],
      ),
    ),
  );
}

class _CustomTargetDialog extends StatefulWidget {
  const _CustomTargetDialog();

  @override
  State<_CustomTargetDialog> createState() => _CustomTargetDialogState();
}

class _CustomTargetDialogState extends State<_CustomTargetDialog> {
  final _controller = TextEditingController();
  Target? _valid;
  bool _touched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    setState(() {
      _touched = true;
      _valid = switch (Target.parse(text)) {
        Ok(:final value) => value,
        Err() => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = _valid;
    return AlertDialog(
      key: const Key('custom-target-dialog'),
      title: Text(l10n.customTargetTitle),
      content: TextField(
        key: const Key('custom-target-field'),
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        onChanged: _onChanged,
        decoration: InputDecoration(
          errorText: _touched && valid == null
              ? l10n.customTargetInvalid
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('custom-target-save'),
          onPressed: valid == null
              ? null
              : () => Navigator.of(context).pop(valid),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
