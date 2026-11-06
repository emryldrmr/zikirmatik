import 'package:drift/drift.dart';

/// A single row (id 1) holding the tesbihat's progress and whether it is the
/// selection on Zikirlerim (spec 0006, AC-7). No row means the first step at
/// count 0, never finished, not selected. Schema v5.
class TesbihatProgress extends Table {
  IntColumn get id => integer().check(const CustomExpression<bool>('id = 1'))();

  IntColumn get step =>
      integer().check(const CustomExpression<bool>('step >= 0'))();

  IntColumn get count =>
      integer().check(const CustomExpression<bool>('count >= 0'))();

  BoolColumn get finished => boolean()();

  IntColumn get completions =>
      integer().check(const CustomExpression<bool>('completions >= 0'))();

  BoolColumn get selected => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
