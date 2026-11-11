import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../counter/counter.dart';
import '../domain/asma_name.dart';
import 'esma_providers.dart';

/// The font family of the Arabic text; `pubspec.yaml` binds it to
/// `assets/fonts/AmiriQuran-Regular.ttf` (spec 0007, AC-3).
const String arabicFontFamily = 'AmiriQuran';

/// "Esmaü'l-Hüsna" body (spec 0007): the 99 names in order, each with an
/// "Ekle" button that adds it to the user's dhikrs, and the source line.
///
/// The text is shown exactly as stored (BR-12): no trimming, no ellipsis —
/// long lines wrap.
class EsmaScreen extends ConsumerWidget {
  const EsmaScreen({required this.onCount, super.key});

  /// Shows "Zikirlerim" (the shell owns the sections); called by the
  /// snackbar's "Say" once the added dhikr is selected (AC-5).
  final VoidCallback onCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (ref.watch(esmaNamesProvider)) {
      AsyncData(:final value) => ListView.builder(
        key: const Key('esma-list'),
        itemCount: value.length + 1,
        itemBuilder: (context, i) => i < value.length
            ? _NameRow(
                name: value[i],
                onAdd: () => _add(context, ref, value[i]),
              )
            : const _SourceLine(),
      ),
      AsyncError() => Center(
        child: Text(
          l10n.esmaLoadFailed,
          key: const Key('esma-error'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      _ => Center(
        child: CircularProgressIndicator(
          key: const Key('esma-loading'),
          semanticsLabel: l10n.esmaLoading,
        ),
      ),
    };
  }

  /// AC-4, AC-6: adds the name as an untargeted dhikr without selecting it.
  /// The snackbar appears only when it was stored; otherwise the list
  /// controller says it was not saved (spec 0015, AC-7).
  Future<void> _add(BuildContext context, WidgetRef ref, AsmaName name) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Kept, not re-read: "Say" may run after this screen is gone.
    final dhikrs = ref.read(dhikrListControllerProvider.notifier);
    try {
      await ref.read(dhikrListControllerProvider.future);
    } on Object catch (_) {
      return; // The list could not be read; Zikirlerim shows its own error.
    }
    final id = await dhikrs.append(DhikrName.stored(name.reading));
    if (id == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('esma-added'),
          content: Text(l10n.esmaAdded),
          action: SnackBarAction(
            key: const Key('esma-count'),
            label: l10n.esmaCount,
            onPressed: () async {
              await dhikrs.show(id);
              onCount();
            },
          ),
        ),
      );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.name, required this.onAdd});

  final AsmaName name;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final n = name.number;
    return Padding(
      key: Key('esma-row-$n'),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // AC-9: one label for the row; the Arabic is not read out (a
            // Turkish voice garbles it).
            child: Semantics(
              container: true,
              label: l10n.esmaRowSemantics(n, name.reading, name.meaning),
              child: ExcludeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grows with the text size: the number never breaks
                    // (review round 1, F-2).
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 32),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: Text(
                          '$n',
                          key: Key('esma-number-$n'),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Arabic: right to left, Amiri Quran (Known traps).
                          Text(
                            name.arabic,
                            key: Key('esma-arabic-$n'),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: arabicFontFamily,
                              fontSize: 26,
                              height: 1.8,
                            ),
                          ),
                          Text(
                            name.reading,
                            key: Key('esma-reading-$n'),
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            name.meaning,
                            key: Key('esma-meaning-$n'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextButton(
            key: Key('esma-add-$n'),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: onAdd,
            child: Text(
              l10n.esmaAdd,
              semanticsLabel: l10n.esmaAddSemantics(name.reading),
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
      AppLocalizations.of(context).esmaSource,
      key: const Key('esma-source'),
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}
