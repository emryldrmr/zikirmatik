import 'package:drift/drift.dart';

/// One row per counter. Until spec 0003 there is a single counter (id 1).
///
/// Schema history: v1 (spec 0001) had `id`, `count`; v2 (spec 0002) adds
/// `rounds`, `total`, `target` — see `AppDatabase.migration`.
class Counters extends Table {
  IntColumn get id => integer()();

  IntColumn get count =>
      integer().check(const CustomExpression<bool>('count >= 0'))();

  IntColumn get rounds => integer()
      .withDefault(const Constant(0))
      .check(const CustomExpression<bool>('rounds >= 0'))();

  IntColumn get total => integer()
      .withDefault(const Constant(0))
      .check(const CustomExpression<bool>('total >= 0'))();

  IntColumn get target => integer().nullable().check(
    const CustomExpression<bool>(
      'target IS NULL OR target BETWEEN 1 AND 100000',
    ),
  )();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
