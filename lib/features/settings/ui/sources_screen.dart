import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Kaynaklar (spec 0019): where the religious texts and the Arabic font come
/// from (BR-12), from bundled text only — no network (Req. 5).
///
/// The Esma and suggested texts are the very strings those screens show under
/// their lists (`esmaSource`, `suggestedSource`), so the two cannot drift
/// apart (Req. 3, plan R1). Spec 0020 adds the Kur'an section on top.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Req. 3: this order, each text exactly as in the spec.
    final sections = [
      (l10n.sourcesEsmaHeader, l10n.esmaSource),
      (l10n.sourcesSuggestedHeader, l10n.suggestedSource),
      (l10n.sourcesTesbihatHeader, l10n.sourcesTesbihat),
      (l10n.sourcesFontHeader, l10n.sourcesFont),
    ];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sourcesTitle)),
      body: ListView(
        key: const Key('sources-screen'),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final (i, (header, text)) in sections.indexed) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Semantics(
                header: true,
                child: Text(
                  header,
                  key: Key('sources-header-$i'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Req. 4: plain text — addresses open nothing. No maxLines or
            // overflow: long lines wrap (AC-8).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                text,
                key: Key('sources-text-$i'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
