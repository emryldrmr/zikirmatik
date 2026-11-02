import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Placeholder body for a section that has no content yet.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context).comingSoon,
        key: const Key('coming-soon'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
