import 'package:drift/drift.dart';

/// One row per counter. The walking skeleton has a single counter (id 1).
class Counters extends Table {
  IntColumn get id => integer()();

  IntColumn get count =>
      integer().check(const CustomExpression<bool>('count >= 0'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
