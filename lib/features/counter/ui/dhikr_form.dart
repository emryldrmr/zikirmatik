import 'package:flutter/material.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/dhikr_list.dart';
import '../domain/dhikr_name.dart';
import '../domain/target.dart';

/// What the add form returns.
final class NewDhikr {
  const NewDhikr(this.name, this.target);

  final DhikrName name;
  final Target? target;
}

/// What the edit form returns.
sealed class DhikrEdit {
  const DhikrEdit();
}

final class RenameDhikr extends DhikrEdit {
  const RenameDhikr(this.name);

  final DhikrName name;
}

final class DeleteDhikr extends DhikrEdit {
  const DeleteDhikr();
}

/// "Yeni zikir": name (BR-1) and optional target (BR-2). Null on cancel.
Future<NewDhikr?> showAddDhikrForm(BuildContext context) =>
    showDialog<NewDhikr>(
      context: context,
      builder: (_) => const _DhikrForm(entry: null),
    );

/// "Zikri düzenle": name only (spec 0003, G4) and "Sil". Null on cancel.
Future<DhikrEdit?> showEditDhikrForm(BuildContext context, DhikrEntry entry) =>
    showDialog<DhikrEdit>(
      context: context,
      builder: (_) => _DhikrForm(entry: entry),
    );

class _DhikrForm extends StatefulWidget {
  const _DhikrForm({required this.entry});

  /// Null: add form; otherwise the dhikr being edited.
  final DhikrEntry? entry;

  @override
  State<_DhikrForm> createState() => _DhikrFormState();
}

class _DhikrFormState extends State<_DhikrForm> {
  late final _name = TextEditingController(text: widget.entry?.name.value);
  final _target = TextEditingController();
  bool _nameTouched = false;

  bool get _isAdd => widget.entry == null;

  DhikrName? get _validName => switch (DhikrName.parse(_name.text)) {
    Ok(:final value) => value,
    Err() => null,
  };

  /// Empty means "no target"; anything else must be a valid target.
  ({bool valid, Target? target}) get _targetInput {
    if (_target.text.trim().isEmpty) return (valid: true, target: null);
    return switch (Target.parse(_target.text)) {
      Ok(:final value) => (valid: true, target: value),
      Err() => (valid: false, target: null),
    };
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  void _save() {
    final name = _validName;
    if (name == null) return;
    if (_isAdd) {
      final target = _targetInput;
      if (!target.valid) return;
      Navigator.of(context).pop(NewDhikr(name, target.target));
    } else {
      Navigator.of(context).pop(RenameDhikr(name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = _validName;
    final target = _targetInput;
    final canSave = name != null && (!_isAdd || target.valid);

    return AlertDialog(
      key: Key(_isAdd ? 'dhikr-add-form' : 'dhikr-edit-form'),
      title: Text(_isAdd ? l10n.newDhikr : l10n.editDhikr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('dhikr-name-field'),
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() => _nameTouched = true),
            decoration: InputDecoration(
              labelText: l10n.dhikrNameLabel,
              errorText: (_nameTouched || !_isAdd) && name == null
                  ? l10n.dhikrNameInvalid
                  : null,
            ),
          ),
          if (_isAdd)
            TextField(
              key: const Key('dhikr-target-field'),
              controller: _target,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.dhikrTargetLabel,
                errorText: target.valid ? null : l10n.customTargetInvalid,
              ),
            ),
        ],
      ),
      actions: [
        if (!_isAdd)
          TextButton(
            key: const Key('dhikr-delete'),
            onPressed: () => Navigator.of(context).pop(const DeleteDhikr()),
            child: Text(l10n.delete),
          ),
        TextButton(
          key: const Key('dhikr-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('dhikr-save'),
          onPressed: canSave ? _save : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
