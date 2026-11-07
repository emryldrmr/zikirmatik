import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/composition.dart';
import 'app/database/app_database.dart';
import 'app/orientation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockPortrait();
  final db = AppDatabase.onDevice();
  runApp(
    ProviderScope(overrides: appOverrides(db), child: const ZikirmatikApp()),
  );
}
