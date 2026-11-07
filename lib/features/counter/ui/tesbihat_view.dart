import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/tesbihat.dart';
import '../domain/tesbihat_state.dart';
import 'confirm_dialog.dart';
import 'device_parts.dart';
import 'dhikr_picker.dart';
import 'full_screen_view.dart';
import 'tesbihat_controller.dart';

/// "Zikirlerim" body while the tesbihat is selected (spec 0006): its name
/// (opens the picker) above the device, counting or finished.
class TesbihatView extends ConsumerWidget {
  const TesbihatView({super.key, required this.state});

  final TesbihatState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: l10n.dhikrPickerSemantics(l10n.tesbihatName),
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
                          l10n.tesbihatName,
                          key: const Key('tesbihat-name'),
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
              _TesbihatDevice(state: state),
              // Spec 0010, AC-1.
              const SizedBox(height: 16),
              const FullScreenButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TesbihatDevice extends ConsumerWidget {
  const _TesbihatDevice({required this.state});

  final TesbihatState state;

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      message: l10n.tesbihatResetConfirmMessage,
      confirmLabel: l10n.reset,
    );
    if (ok) await ref.read(tesbihatControllerProvider.notifier).restart();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(tesbihatControllerProvider.notifier);
    final theme = Theme.of(context);
    final steps = namazSonrasiTesbihat.steps;
    final step = steps[state.step];
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      color: deviceBodyText,
    );

    return DeviceBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AC-10: the step (or the finish) is announced when it changes.
          Semantics(
            liveRegion: true,
            label: state.finished
                ? l10n.tesbihatFinished
                : l10n.tesbihatStepAnnouncement(
                    step.text,
                    state.step + 1,
                    steps.length,
                  ),
            excludeSemantics: true,
            child: Text(
              // BR-12: the step's text exactly as stored, never shortened.
              state.finished ? l10n.tesbihatFinished : step.text,
              key: Key(state.finished ? 'tesbihat-finished' : 'tesbihat-text'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: deviceBodyText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          DeviceLcd(count: state.count.value),
          const SizedBox(height: 12),
          if (!state.finished) ...[
            Text(
              l10n.tesbihatStep(state.step + 1, steps.length),
              key: const Key('tesbihat-step'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: deviceBodyText,
              ),
            ),
            Text(
              l10n.tesbihatTarget(thousands.format(step.target.value)),
              key: const Key('tesbihat-target'),
              style: bodyStyle,
            ),
          ],
          Text(
            l10n.tesbihatCompletions(thousands.format(state.completions)),
            key: const Key('tesbihat-completions'),
            style: bodyStyle,
          ),
          const SizedBox(height: 8),
          if (state.finished)
            FilledButton(
              key: const Key('tesbihat-restart'),
              style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: controller.restart,
              child: Text(l10n.tesbihatRestart),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  key: const Key('tesbihat-undo'),
                  color: deviceBodyText,
                  disabledColor: deviceBodyText.withValues(alpha: 0.38),
                  icon: Icon(Icons.undo, semanticLabel: l10n.undo),
                  onPressed: state.count.value == 0 ? null : controller.undo,
                ),
                IconButton(
                  key: const Key('tesbihat-reset'),
                  color: deviceBodyText,
                  icon: Icon(Icons.restart_alt, semanticLabel: l10n.reset),
                  onPressed: () => _reset(context, ref),
                ),
              ],
            ),
          const SizedBox(height: 16),
          DeviceCountButton(
            semanticsLabel: state.finished
                ? l10n.tesbihatFinished
                : l10n.tesbihatStepSemantics(
                    step.text,
                    state.step + 1,
                    steps.length,
                    state.count.value,
                    step.target.value,
                  ),
            onTap: controller.tap,
            enabled: !state.finished,
          ),
        ],
      ),
    );
  }
}
