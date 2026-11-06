import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/counter/counter.dart';
import '../features/esma/esma.dart';
import '../features/settings/settings.dart';
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
  /// How long a second back press exits after the first (spec 0005, CB-2).
  static const _exitWindow = Duration(seconds: 2);

  AppSection _section = AppSection.myDhikrs;

  /// Running while a second back press would exit; measured with a timer, not
  /// the clock, so tests can advance it.
  Timer? _exitArmed;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _select(BuildContext context, AppSection section) {
    setState(() => _section = section);
    Navigator.of(context).pop(); // close the drawer
  }

  /// Spec 0005. Open sheets and dialogs are routes above this one and close
  /// first on their own (CB-4). The menu does not: with `canPop: false` the
  /// scope is asked before the drawer's own back step, so it is closed here
  /// (CB-3).
  void _onBack(bool didPop, Object? result) {
    if (didPop) return;
    final scaffold = _scaffoldKey.currentState;
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer(); // CB-3
      return;
    }
    if (_section != AppSection.myDhikrs) {
      setState(() => _section = AppSection.myDhikrs); // CB-1
      return;
    }
    if (_exitArmed?.isActive ?? false) {
      _exitArmed!.cancel();
      SystemNavigator.pop(); // CB-2: second press
      return;
    }
    _exitArmed = Timer(_exitWindow, () {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('exit-warning'),
          content: Text(AppLocalizations.of(context).pressBackAgainToExit),
          duration: _exitWindow,
        ),
      );
  }

  @override
  void dispose() {
    _exitArmed?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: _scaffold(context, l10n),
    );
  }

  Widget _scaffold(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      key: _scaffoldKey,
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
        AppSection.settings => const SettingsScreen(),
        // Spec 0007, AC-5: "Say" opens Zikirlerim with the added dhikr.
        AppSection.asma => EsmaScreen(
          onCount: () => setState(() => _section = AppSection.myDhikrs),
        ),
        _ => const ComingSoonScreen(),
      },
    );
  }
}
