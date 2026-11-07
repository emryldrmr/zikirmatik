import 'package:drift/drift.dart';

/// A single row (id 1) holding the user's preferences (spec 0004). No row
/// means the defaults (vibration on, system theme, no vibration per count).
class Settings extends Table {
  IntColumn get id => integer().check(const CustomExpression<bool>('id = 1'))();

  BoolColumn get vibration => boolean()();

  TextColumn get theme => text().check(
    const CustomExpression<bool>("theme IN ('light', 'dark', 'system')"),
  )();

  /// Spec 0009, schema v6. Rows kept from v5 get the default: off (AC-1).
  BoolColumn get tapVibration =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
