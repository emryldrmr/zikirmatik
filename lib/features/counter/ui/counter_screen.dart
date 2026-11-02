import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/counter_state.dart';
import 'confirm_dialog.dart';
import 'counter_controller.dart';
import 'target_picker.dart';

/// "Zikirlerim" body: a hand-held digital counter (spec 0002).
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(counterControllerProvider);

    return switch (state) {
      AsyncData(:final value) => _Device(state: value),
      AsyncError() => Center(
        child: Text(
          l10n.counterLoadFailed,
          key: const Key('counter-error'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      _ => Center(
        child: CircularProgressIndicator(
          key: const Key('counter-loading'),
          semanticsLabel: l10n.counterLoading,
        ),
      ),
    };
  }
}

// Original drawing of a generic counter; no brand's device is copied.
const _bodyColor = Color(0xFF37474F);
const _lcdBackground = Color(0xFF1B3A2A);
const _lcdDigits = Color(0xFFB9F6CA); // ~11:1 on _lcdBackground (WCAG AA)
const _bodyText = Color(0xFFECEFF1); // ~9:1 on _bodyColor

final _thousands = NumberFormat.decimalPattern('tr');

class _Device extends ConsumerWidget {
  const _Device({required this.state});

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
        .read(counterControllerProvider.notifier)
        .changeTarget(choice.target);
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      message: l10n.resetConfirmMessage,
      confirmLabel: l10n.reset,
    );
    if (ok) await ref.read(counterControllerProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(counterControllerProvider.notifier);
    final theme = Theme.of(context);
    final target = state.target;
    final targetText = target == null
        ? l10n.targetNone
        : l10n.targetAndRound(
            _thousands.format(target.value),
            _thousands.format(state.rounds),
          );
    final targetLabel = target == null
        ? l10n.targetSemanticsNone
        : l10n.targetSemantics(_thousands.format(target.value));

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: DecoratedBox(
            key: const Key('counter-device'),
            decoration: BoxDecoration(
              color: _bodyColor,
              borderRadius: BorderRadius.circular(48),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 16,
                  offset: Offset(0, 8),
                  color: Colors.black26,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Lcd(count: state.count.value),
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: targetLabel,
                    excludeSemantics: true,
                    child: TextButton(
                      key: const Key('counter-target'),
                      style: TextButton.styleFrom(
                        foregroundColor: _bodyText,
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: () => _pickTarget(context, ref),
                      child: Text(
                        targetText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _bodyText,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    l10n.totalLabel(_thousands.format(state.total)),
                    key: const Key('counter-total'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _bodyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        key: const Key('counter-undo'),
                        color: _bodyText,
                        disabledColor: _bodyText.withValues(alpha: 0.38),
                        icon: Icon(Icons.undo, semanticLabel: l10n.undo),
                        onPressed: state.count.value == 0
                            ? null
                            : controller.undo,
                      ),
                      IconButton(
                        key: const Key('counter-reset'),
                        color: _bodyText,
                        icon: Icon(
                          Icons.restart_alt,
                          semanticLabel: l10n.reset,
                        ),
                        onPressed: () => _reset(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CountButton(
                    semanticsLabel: l10n.counterSemantics(state.count.value),
                    onTap: controller.tap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Lcd extends StatelessWidget {
  const _Lcd({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('counter-lcd'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _lcdBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54, width: 3),
      ),
      child: Text(
        '$count',
        key: const Key('counter-value'),
        textAlign: TextAlign.right,
        maxLines: 1,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          color: _lcdDigits,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  const _CountButton({required this.semanticsLabel, required this.onTap});

  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        elevation: 6,
        child: InkWell(
          key: const Key('counter-tap-area'),
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox.square(dimension: 140),
        ),
      ),
    );
  }
}
