import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hand_layout.dart';

/// Whether the count digits are shown larger (spec 0011, Req. 2). Defaults to
/// off; the composition root binds it to the user's setting, so the counter
/// need not import the settings feature (FD-2, plan 0011, R1).
final largeCountEnabledProvider = Provider<bool>((ref) => false);

/// Which hand the counter is laid out for (spec 0011, Req. 4–5). Defaults to
/// the centre, today's layout; bound like [largeCountEnabledProvider].
final handLayoutProvider = Provider<HandLayout>((ref) => HandLayout.center);
