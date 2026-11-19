import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'counter_controller.dart';
import 'dhikr_list_controller.dart';
import 'last_counted.dart';
import 'tesbihat_controller.dart';

/// Reads Zikirlerim again from storage after it was replaced from outside
/// (spec 0018, Req. 4): the list, every counter and the tesbihat. The resume
/// point is forgotten, so no continue notification shows until the next
/// counting tap (spec 0018, AC-9).
void reloadCounter(Ref<Object?> ref) {
  ref
    ..invalidate(lastCountedProvider)
    ..invalidate(counterControllerProvider)
    ..invalidate(tesbihatControllerProvider)
    ..invalidate(dhikrListControllerProvider);
}
