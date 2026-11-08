import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current local time, behind a provider so tests can fix it
/// (docs/testing.md, Determinism). Spec 0014: the calendar day of a tap is
/// taken from here at the moment it happens.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
