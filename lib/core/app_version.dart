import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The installed app's version name, e.g. "1.0.0" (spec 0009, AC-8), or null
/// when it cannot be read — then the side menu shows no version row.
///
/// Defaults to null; the composition root (`lib/app/`) binds it to the
/// platform, tests to a fixed value.
final appVersionProvider = FutureProvider<String?>((ref) async => null);
