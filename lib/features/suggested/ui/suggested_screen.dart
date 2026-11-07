import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../counter/counter.dart';
import '../domain/suggested_dhikr.dart';
import 'suggested_providers.dart';

/// "Önerilen Zikirler" body (spec 0008): the 7 dhikrs in order, each with its
/// meaning, target, hadith reference and an "Ekle" button that adds it to the
/// user's dhikrs, and the source line.
///
/// The text is shown exactly as stored (BR-12): no trimming, no ellipsis —
/// long lines wrap.
class SuggestedScreen extends ConsumerWidget {
  const SuggestedScreen({required this.onCount, super.key});

  /// Shows "Zikirlerim" (the shell owns the sections); called by the
  /// snackbar's "Say" once the added dhikr is selected (AC-6).
  final VoidCallback onCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (ref.watch(suggestedDhikrsProvider)) {
      AsyncData(:final value) => ListView.builder(
        key: const Key('suggested-list'),
        itemCount: value.length + 1,
        itemBuilder: (context, i) => i < value.length
            ? _DhikrRow(
                dhikr: value[i],
                onAdd: () => _add(context, ref, value[i]),
              )
            : const _SourceLine(),
      ),
      AsyncError() => Center(
        child: Text(
          l10n.suggestedLoadFailed,
          key: const Key('suggested-error'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      _ => Center(
        child: CircularProgressIndicator(
          key: const Key('suggested-loading'),
          semanticsLabel: l10n.suggestedLoading,
        ),
      ),
    };
  }

  /// AC-4, AC-6: adds the dhikr with its table target (or none) without
  /// selecting it. The snackbar appears only when it was stored (write
  /// errors: B-2).
  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    SuggestedDhikr dhikr,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Kept, not re-read: "Say" may run after this screen is gone.
    final dhikrs = ref.read(dhikrListControllerProvider.notifier);
    try {
      await ref.read(dhikrListControllerProvider.future);
    } on Object catch (_) {
      return; // The list could not be read; Zikirlerim shows its own error.
    }
    final target = dhikr.target;
    final id = await dhikrs.append(
      DhikrName.stored(dhikr.reading),
      target: target == null ? null : Target.of(target),
    );
    if (id == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('suggested-added'),
          content: Text(l10n.suggestedAdded),
          action: SnackBarAction(
            key: const Key('suggested-count'),
            label: l10n.suggestedCount,
            onPressed: () async {
              await dhikrs.show(id);
              onCount();
            },
          ),
        ),
      );
  }
}

class _DhikrRow extends StatelessWidget {
  const _DhikrRow({required this.dhikr, required this.onAdd});

  final SuggestedDhikr dhikr;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final n = dhikr.number;
    final target = dhikr.target;
    final targetText = target == null
        ? l10n.suggestedNoTarget
        : l10n.suggestedTarget('$target');
    return Padding(
      key: Key('suggested-row-$n'),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AC-9: one label for reading, meaning and target.
                Semantics(
                  container: true,
                  label: l10n.suggestedRowSemantics(
                    dhikr.reading,
                    dhikr.meaning,
                    targetText,
                  ),
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          dhikr.reading,
                          key: Key('suggested-reading-$n'),
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          dhikr.meaning,
                          key: Key('suggested-meaning-$n'),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          targetText,
                          key: Key('suggested-target-$n'),
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                // Read on its own, after the row label.
                Text(
                  dhikr.reference,
                  key: Key('suggested-reference-$n'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            key: Key('suggested-add-$n'),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: onAdd,
            child: Text(
              l10n.suggestedAdd,
              semanticsLabel: l10n.suggestedAddSemantics(dhikr.reading),
            ),
          ),
        ],
      ),
    );
  }
}

/// AC-8: where the content comes from (BR-12).
class _SourceLine extends StatelessWidget {
  const _SourceLine();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    child: Text(
      AppLocalizations.of(context).suggestedSource,
      key: const Key('suggested-source'),
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}
