import 'package:drift/drift.dart';

/// One row per calendar day with a count (spec 0014, Req. 7): `day` is the
/// local date as `YYYY-MM-DD`. No row means 0. Schema v9.
class DailyCounts extends Table {
  TextColumn get day => text()();

  IntColumn get count =>
      integer().check(const CustomExpression<bool>('count >= 0'))();

  @override
  Set<Column<Object>> get primaryKey => {day};
}
