import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/display.dart';

// The hand-held counter's parts (spec 0002), shared by a dhikr's device and
// the tesbihat's (spec 0006). Original drawing of a generic counter; no
// brand's device is copied.
const deviceBodyColor = Color(0xFF37474F);
const _lcdBackground = Color(0xFF1B3A2A);
const _lcdDigits = Color(0xFFB9F6CA); // ~11:1 on _lcdBackground (WCAG AA)
const deviceBodyText = Color(0xFFECEFF1); // ~9:1 on deviceBodyColor
// The count button: the light theme's primary for the teal seed, fixed so the
// device looks the same in every theme (spec 0004, AC-4).
const _buttonColor = Color(0xFF006A60);

final thousands = NumberFormat.decimalPattern('tr');

/// The device's body around [child].
class DeviceBody extends StatelessWidget {
  const DeviceBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const Key('counter-device'),
    decoration: BoxDecoration(
      color: deviceBodyColor,
      borderRadius: BorderRadius.circular(48),
      boxShadow: const [
        BoxShadow(blurRadius: 16, offset: Offset(0, 8), color: Colors.black26),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
      child: child,
    ),
  );
}

/// How much larger the count is with "Büyük rakam" on (spec 0011, Req. 2).
const largeCountScale = 1.5;

class DeviceLcd extends ConsumerWidget {
  const DeviceLcd({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = Theme.of(context).textTheme.displayLarge;
    final large = ref.watch(largeCountEnabledProvider);
    return Container(
      key: const Key('counter-lcd'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _lcdBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54, width: 3),
      ),
      // Spec 0011, Req. 3: a count that does not fit shrinks, never cut. The
      // Align keeps the LCD's height that of the text (plan 0011, R2).
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$count',
            key: const Key('counter-value'),
            textAlign: TextAlign.right,
            maxLines: 1,
            style: style?.copyWith(
              color: _lcdDigits,
              fontSize: large && style.fontSize != null
                  ? style.fontSize! * largeCountScale
                  : null,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceCountButton extends StatelessWidget {
  const DeviceCountButton({
    super.key,
    required this.semanticsLabel,
    required this.onTap,
    this.enabled = true,
  });

  final String semanticsLabel;
  final VoidCallback onTap;

  /// False when a tap would change nothing (a finished tesbihat, spec 0006):
  /// a screen reader then hears a disabled button (review round 1, F-3).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: Material(
        color: _buttonColor,
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
