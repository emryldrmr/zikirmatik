import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/counter_state.dart';
import '../domain/dhikr_list.dart';
import 'confirm_dialog.dart';
import 'counter_controller.dart';
import 'dhikr_list_controller.dart';
import 'device_parts.dart';
import 'keep_screen_awake.dart';
import 'dhikr_picker.dart';
import 'full_screen_view.dart';
import 'target_picker.dart';
import 'tesbihat_controller.dart';
import 'tesbihat_view.dart';

/// "Zikirlerim" body: the selected dhikr's name and its hand-held digital
/// counter (specs 0002, 0003), the tesbihat when it is selected (spec 0006),
/// or the empty state.
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      // Spec 0010, AC-9: in every state of Zikirlerim.
      const KeepScreenAwake(child: _CounterBody());
}

class _CounterBody extends ConsumerWidget {
  const _CounterBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(dhikrListControllerProvider);
    final tesbihat = ref.watch(tesbihatControllerProvider);

    // A tesbihat that cannot be read is treated as not selected, so the
    // dhikrs stay usable (behaviour on storage errors: B-2).
    if (tesbihat case AsyncData(:final value) when value.selected) {
      return TesbihatView(state: value);
    }
    if (tesbihat.isLoading) return const Center(child: _Loading());

    return switch (list) {
      AsyncData(:final value) => switch (value.selected) {
        final DhikrEntry entry => _SelectedDhikr(entry: entry),
        null => const _NoDhikrs(),
      },
      AsyncError() => const Center(child: _LoadFailed()),
      _ => const Center(child: _Loading()),
    };
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
    key: const Key('counter-loading'),
    semanticsLabel: AppLocalizations.of(context).counterLoading,
  );
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed();

  @override
  Widget build(BuildContext context) => Text(
    AppLocalizations.of(context).counterLoadFailed,
    key: const Key('counter-error'),
    style: Theme.of(context).textTheme.titleMedium,
  );
}

/// AC-7: no dhikr left.
class _NoDhikrs extends ConsumerWidget {
  const _NoDhikrs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.noDhikrs,
            key: const Key('dhikr-empty'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('dhikr-empty-add'),
            icon: const Icon(Icons.add),
            label: Text(l10n.addDhikr),
            onPressed: () => addDhikr(context, ref),
          ),
          const SizedBox(height: 8),
          // Spec 0006, AC-9.
          OutlinedButton(
            key: const Key('tesbihat-empty-open'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () =>
                ref.read(tesbihatControllerProvider.notifier).select(true),
            child: Text(l10n.tesbihatOpen),
          ),
        ],
      ),
    );
  }
}

/// The selected dhikr's name (opens the picker) above its counter.
class _SelectedDhikr extends ConsumerWidget {
  const _SelectedDhikr({required this.entry});

  final DhikrEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final counter = ref.watch(counterControllerProvider(entry.id));

    // Spec 0011, Req. 4: near the chosen hand's edge.
    return HandAlign(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: l10n.dhikrPickerSemantics(entry.name.value),
                excludeSemantics: true,
                child: TextButton(
                  key: const Key('dhikr-picker-button'),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => showDhikrPicker(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          entry.name.value,
                          key: const Key('dhikr-name'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              switch (counter) {
                AsyncData(:final value) => _Device(
                  dhikrId: entry.id,
                  state: value,
                ),
                AsyncError() => const _LoadFailed(),
                _ => const _Loading(),
              },
              // Spec 0010, AC-1: only with a loaded counter.
              if (counter case AsyncData()) ...[
                const SizedBox(height: 16),
                FullScreenButton(entry: entry),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Device extends ConsumerWidget {
  const _Device({required this.dhikrId, required this.state});

  final int dhikrId;

  final CounterState state;

  Future<void> _pickTarget(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showTargetPicker(context);
    if (choice == null || !context.mounted) return;
    if (choice.target == state.target) return; // nothing would change
    if (state.hasProgress) {
      final ok = await confirmAction(
        context,
        message: l10n.targetChangeConfirmMessage,
        confirmLabel: l10n.targetChangeConfirm,
      );
      if (!ok) return;
    }
    await ref
        .read(counterControllerProvider(dhikrId).notifier)
        .changeTarget(choice.target);
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      message: l10n.resetConfirmMessage,
      confirmLabel: l10n.reset,
    );
    if (ok) await ref.read(counterControllerProvider(dhikrId).notifier).reset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(counterControllerProvider(dhikrId).notifier);
    final theme = Theme.of(context);
    final target = state.target;
    final targetText = target == null
        ? l10n.targetNone
        : l10n.targetAndRound(
            thousands.format(target.value),
            thousands.format(state.rounds),
          );
    final targetLabel = target == null
        ? l10n.targetSemanticsNone
        : l10n.targetSemantics(thousands.format(target.value));

    // Centering, scrolling and width come from _SelectedDhikr.
    return DeviceBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DeviceLcd(count: state.count.value),
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: targetLabel,
            excludeSemantics: true,
            child: TextButton(
              key: const Key('counter-target'),
              style: TextButton.styleFrom(
                foregroundColor: deviceBodyText,
                minimumSize: const Size(48, 48),
              ),
              onPressed: () => _pickTarget(context, ref),
              child: Text(
                targetText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: deviceBodyText,
                ),
              ),
            ),
          ),
          Text(
            l10n.totalLabel(thousands.format(state.total)),
            key: const Key('counter-total'),
            style: theme.textTheme.bodyLarge?.copyWith(color: deviceBodyText),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                key: const Key('counter-undo'),
                color: deviceBodyText,
                disabledColor: deviceBodyText.withValues(alpha: 0.38),
                icon: Icon(Icons.undo, semanticLabel: l10n.undo),
                onPressed: state.count.value == 0 ? null : controller.undo,
              ),
              IconButton(
                key: const Key('counter-reset'),
                color: deviceBodyText,
                icon: Icon(Icons.restart_alt, semanticLabel: l10n.reset),
                onPressed: () => _reset(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DeviceCountButton(
            semanticsLabel: l10n.counterSemantics(state.count.value),
            onTap: controller.tap,
          ),
        ],
      ),
    );
  }
}
