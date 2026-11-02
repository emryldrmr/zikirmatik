import 'package:flutter/material.dart';

import '../features/counter/counter.dart';
import '../l10n/app_localizations.dart';
import 'app_section.dart';
import 'coming_soon_screen.dart';

/// App frame: title bar, side menu (Drawer) and the selected section's body.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  AppSection _section = AppSection.myDhikrs;

  void _select(BuildContext context, AppSection section) {
    setState(() => _section = section);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_section.label(l10n)),
        leading: Builder(
          builder: (context) => IconButton(
            key: const Key('open-menu'),
            icon: const Icon(Icons.menu),
            tooltip: l10n.openMenu,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              for (final section in AppSection.values)
                ListTile(
                  key: Key('section-${section.name}'),
                  title: Text(section.label(l10n)),
                  selected: section == _section,
                  onTap: () => _select(context, section),
                ),
            ],
          ),
        ),
      ),
      body: switch (_section) {
        AppSection.myDhikrs => const CounterScreen(),
        _ => const ComingSoonScreen(),
      },
    );
  }
}
