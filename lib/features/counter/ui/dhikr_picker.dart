import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/dhikr_list.dart';
import 'confirm_dialog.dart';
import 'dhikr_form.dart';
import 'dhikr_list_controller.dart';
import 'tesbihat_controller.dart';

/// Opens the add form and stores the new dhikr (AC-3, AC-7). True when a
/// dhikr was added (it is then selected, also over the tesbihat: spec 0006,
/// AC-9).
Future<bool> addDhikr(BuildContext context, WidgetRef ref) async {
  final created = await showAddDhikrForm(context);
  if (created == null) return false;
  final added = await ref
      .read(dhikrListControllerProvider.notifier)
      .add(created.name, created.target);
  if (added) await ref.read(tesbihatControllerProvider.notifier).select(false);
  return added;
}

/// Opens the edit form; renames, or asks and deletes (AC-5, AC-6).
Future<void> editDhikr(
  BuildContext context,
  WidgetRef ref,
  DhikrEntry entry,
) async {
  final l10n = AppLocalizations.of(context);
  final controller = ref.read(dhikrListControllerProvider.notifier);
  final edit = await showEditDhikrForm(context, entry);
  if (edit == null || !context.mounted) return;
  switch (edit) {
    case RenameDhikr(:final name):
      if (name != entry.name) await controller.rename(entry.id, name);
    case DeleteDhikr():
      final ok = await confirmAction(
        context,
        message: l10n.deleteDhikrConfirmMessage(entry.name.value),
        confirmLabel: l10n.delete,
      );
      if (ok) await controller.delete(entry.id);
  }
}

/// Bottom sheet with the tesbihat first (spec 0006, AC-1), then every dhikr in
/// creation order (AC-2) with an edit button per row, and "Yeni zikir". Follows the list live while open.
Future<void> showDhikrPicker(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _DhikrPickerSheet(),
    );

class _DhikrPickerSheet extends ConsumerWidget {
  const _DhikrPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(dhikrListControllerProvider).valueOrNull;
    final entries = list?.entries ?? const <DhikrEntry>[];
    final tesbihatSelected =
        ref.watch(tesbihatControllerProvider).valueOrNull?.selected ?? false;
    bool isSelected(DhikrEntry e) =>
        !tesbihatSelected && e.id == list?.selectedId;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          key: const Key('dhikr-picker'),
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l10n.dhikrPickerTitle)),
            ListTile(
              key: const Key('tesbihat-row'),
              selected: tesbihatSelected,
              leading: Icon(
                tesbihatSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(l10n.tesbihatName),
              onTap: () async {
                await ref
                    .read(tesbihatControllerProvider.notifier)
                    .select(true);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            const Divider(),
            for (final entry in entries)
              ListTile(
                key: Key('dhikr-row-${entry.id}'),
                selected: isSelected(entry),
                leading: Icon(
                  isSelected(entry)
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(entry.name.value),
                onTap: () async {
                  await ref
                      .read(dhikrListControllerProvider.notifier)
                      .select(entry.id);
                  await ref
                      .read(tesbihatControllerProvider.notifier)
                      .select(false);
                  if (context.mounted) Navigator.of(context).pop();
                },
                trailing: IconButton(
                  key: Key('dhikr-edit-${entry.id}'),
                  icon: Icon(
                    Icons.edit_outlined,
                    semanticLabel: l10n.dhikrEditSemantics(entry.name.value),
                  ),
                  onPressed: () => editDhikr(context, ref, entry),
                ),
              ),
            ListTile(
              key: const Key('dhikr-add'),
              leading: const Icon(Icons.add),
              title: Text(l10n.newDhikr),
              onTap: () async {
                // Like selecting a row: the new dhikr is selected, so the
                // sheet closes and the device is ready to count (spec Flow).
                final added = await addDhikr(context, ref);
                if (added && context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
