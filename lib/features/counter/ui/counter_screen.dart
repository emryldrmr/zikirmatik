import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import 'counter_controller.dart';

/// "Zikirlerim" body of the walking skeleton: a single counter.
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(counterControllerProvider);

    return switch (state) {
      AsyncData(:final value) => _TapArea(
        count: value.value,
        semanticsLabel: l10n.counterSemantics(value.value),
        onTap: () => ref.read(counterControllerProvider.notifier).increment(),
      ),
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

class _TapArea extends StatelessWidget {
  const _TapArea({
    required this.count,
    required this.semanticsLabel,
    required this.onTap,
  });

  final int count;
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
      child: InkWell(
        key: const Key('counter-tap-area'),
        onTap: onTap,
        child: SizedBox.expand(
          child: Center(
            child: Text(
              '$count',
              key: const Key('counter-value'),
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
      ),
    );
  }
}
