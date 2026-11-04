import 'package:drift/drift.dart';

/// The user's dhikrs (spec 0003). The id is shared with the dhikr's row in
/// `counters`; ids grow with creation order (AUTOINCREMENT, never reused).
class Dhikrs extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().check(
    const CustomExpression<bool>('length(name) BETWEEN 1 AND 50'),
  )();
}

/// A single row (id 1) holding the selected dhikr; null when the list is empty.
class DhikrSelections extends Table {
  IntColumn get id => integer().check(const CustomExpression<bool>('id = 1'))();

  IntColumn get dhikrId => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
