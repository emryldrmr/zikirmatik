// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CountersTable extends Counters with TableInfo<$CountersTable, Counter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('count >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('rounds >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('total >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    true,
    check: () => const CustomExpression<bool>(
      'target IS NULL OR target BETWEEN 1 AND 100000',
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, count, rounds, total, target];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Counter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Counter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Counter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      ),
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }
}

class Counter extends DataClass implements Insertable<Counter> {
  final int id;
  final int count;
  final int rounds;
  final int total;
  final int? target;
  const Counter({
    required this.id,
    required this.count,
    required this.rounds,
    required this.total,
    this.target,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['count'] = Variable<int>(count);
    map['rounds'] = Variable<int>(rounds);
    map['total'] = Variable<int>(total);
    if (!nullToAbsent || target != null) {
      map['target'] = Variable<int>(target);
    }
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(
      id: Value(id),
      count: Value(count),
      rounds: Value(rounds),
      total: Value(total),
      target: target == null && nullToAbsent
          ? const Value.absent()
          : Value(target),
    );
  }

  factory Counter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Counter(
      id: serializer.fromJson<int>(json['id']),
      count: serializer.fromJson<int>(json['count']),
      rounds: serializer.fromJson<int>(json['rounds']),
      total: serializer.fromJson<int>(json['total']),
      target: serializer.fromJson<int?>(json['target']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'count': serializer.toJson<int>(count),
      'rounds': serializer.toJson<int>(rounds),
      'total': serializer.toJson<int>(total),
      'target': serializer.toJson<int?>(target),
    };
  }

  Counter copyWith({
    int? id,
    int? count,
    int? rounds,
    int? total,
    Value<int?> target = const Value.absent(),
  }) => Counter(
    id: id ?? this.id,
    count: count ?? this.count,
    rounds: rounds ?? this.rounds,
    total: total ?? this.total,
    target: target.present ? target.value : this.target,
  );
  Counter copyWithCompanion(CountersCompanion data) {
    return Counter(
      id: data.id.present ? data.id.value : this.id,
      count: data.count.present ? data.count.value : this.count,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      total: data.total.present ? data.total.value : this.total,
      target: data.target.present ? data.target.value : this.target,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Counter(')
          ..write('id: $id, ')
          ..write('count: $count, ')
          ..write('rounds: $rounds, ')
          ..write('total: $total, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, count, rounds, total, target);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Counter &&
          other.id == this.id &&
          other.count == this.count &&
          other.rounds == this.rounds &&
          other.total == this.total &&
          other.target == this.target);
}

class CountersCompanion extends UpdateCompanion<Counter> {
  final Value<int> id;
  final Value<int> count;
  final Value<int> rounds;
  final Value<int> total;
  final Value<int?> target;
  const CountersCompanion({
    this.id = const Value.absent(),
    this.count = const Value.absent(),
    this.rounds = const Value.absent(),
    this.total = const Value.absent(),
    this.target = const Value.absent(),
  });
  CountersCompanion.insert({
    this.id = const Value.absent(),
    required int count,
    this.rounds = const Value.absent(),
    this.total = const Value.absent(),
    this.target = const Value.absent(),
  }) : count = Value(count);
  static Insertable<Counter> custom({
    Expression<int>? id,
    Expression<int>? count,
    Expression<int>? rounds,
    Expression<int>? total,
    Expression<int>? target,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (count != null) 'count': count,
      if (rounds != null) 'rounds': rounds,
      if (total != null) 'total': total,
      if (target != null) 'target': target,
    });
  }

  CountersCompanion copyWith({
    Value<int>? id,
    Value<int>? count,
    Value<int>? rounds,
    Value<int>? total,
    Value<int?>? target,
  }) {
    return CountersCompanion(
      id: id ?? this.id,
      count: count ?? this.count,
      rounds: rounds ?? this.rounds,
      total: total ?? this.total,
      target: target ?? this.target,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('id: $id, ')
          ..write('count: $count, ')
          ..write('rounds: $rounds, ')
          ..write('total: $total, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }
}

class $DhikrsTable extends Dhikrs with TableInfo<$DhikrsTable, Dhikr> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DhikrsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('length(name) BETWEEN 1 AND 50'),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dhikrs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dhikr> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dhikr map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dhikr(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $DhikrsTable createAlias(String alias) {
    return $DhikrsTable(attachedDatabase, alias);
  }
}

class Dhikr extends DataClass implements Insertable<Dhikr> {
  final int id;
  final String name;
  const Dhikr({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  DhikrsCompanion toCompanion(bool nullToAbsent) {
    return DhikrsCompanion(id: Value(id), name: Value(name));
  }

  factory Dhikr.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dhikr(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Dhikr copyWith({int? id, String? name}) =>
      Dhikr(id: id ?? this.id, name: name ?? this.name);
  Dhikr copyWithCompanion(DhikrsCompanion data) {
    return Dhikr(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dhikr(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dhikr && other.id == this.id && other.name == this.name);
}

class DhikrsCompanion extends UpdateCompanion<Dhikr> {
  final Value<int> id;
  final Value<String> name;
  const DhikrsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  DhikrsCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<Dhikr> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  DhikrsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return DhikrsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DhikrsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $DhikrSelectionsTable extends DhikrSelections
    with TableInfo<$DhikrSelectionsTable, DhikrSelection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DhikrSelectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('id = 1'),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dhikrIdMeta = const VerificationMeta(
    'dhikrId',
  );
  @override
  late final GeneratedColumn<int> dhikrId = GeneratedColumn<int>(
    'dhikr_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, dhikrId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dhikr_selections';
  @override
  VerificationContext validateIntegrity(
    Insertable<DhikrSelection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dhikr_id')) {
      context.handle(
        _dhikrIdMeta,
        dhikrId.isAcceptableOrUnknown(data['dhikr_id']!, _dhikrIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DhikrSelection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DhikrSelection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dhikrId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dhikr_id'],
      ),
    );
  }

  @override
  $DhikrSelectionsTable createAlias(String alias) {
    return $DhikrSelectionsTable(attachedDatabase, alias);
  }
}

class DhikrSelection extends DataClass implements Insertable<DhikrSelection> {
  final int id;
  final int? dhikrId;
  const DhikrSelection({required this.id, this.dhikrId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || dhikrId != null) {
      map['dhikr_id'] = Variable<int>(dhikrId);
    }
    return map;
  }

  DhikrSelectionsCompanion toCompanion(bool nullToAbsent) {
    return DhikrSelectionsCompanion(
      id: Value(id),
      dhikrId: dhikrId == null && nullToAbsent
          ? const Value.absent()
          : Value(dhikrId),
    );
  }

  factory DhikrSelection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DhikrSelection(
      id: serializer.fromJson<int>(json['id']),
      dhikrId: serializer.fromJson<int?>(json['dhikrId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dhikrId': serializer.toJson<int?>(dhikrId),
    };
  }

  DhikrSelection copyWith({
    int? id,
    Value<int?> dhikrId = const Value.absent(),
  }) => DhikrSelection(
    id: id ?? this.id,
    dhikrId: dhikrId.present ? dhikrId.value : this.dhikrId,
  );
  DhikrSelection copyWithCompanion(DhikrSelectionsCompanion data) {
    return DhikrSelection(
      id: data.id.present ? data.id.value : this.id,
      dhikrId: data.dhikrId.present ? data.dhikrId.value : this.dhikrId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DhikrSelection(')
          ..write('id: $id, ')
          ..write('dhikrId: $dhikrId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dhikrId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DhikrSelection &&
          other.id == this.id &&
          other.dhikrId == this.dhikrId);
}

class DhikrSelectionsCompanion extends UpdateCompanion<DhikrSelection> {
  final Value<int> id;
  final Value<int?> dhikrId;
  const DhikrSelectionsCompanion({
    this.id = const Value.absent(),
    this.dhikrId = const Value.absent(),
  });
  DhikrSelectionsCompanion.insert({
    this.id = const Value.absent(),
    this.dhikrId = const Value.absent(),
  });
  static Insertable<DhikrSelection> custom({
    Expression<int>? id,
    Expression<int>? dhikrId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dhikrId != null) 'dhikr_id': dhikrId,
    });
  }

  DhikrSelectionsCompanion copyWith({Value<int>? id, Value<int?>? dhikrId}) {
    return DhikrSelectionsCompanion(
      id: id ?? this.id,
      dhikrId: dhikrId ?? this.dhikrId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dhikrId.present) {
      map['dhikr_id'] = Variable<int>(dhikrId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DhikrSelectionsCompanion(')
          ..write('id: $id, ')
          ..write('dhikrId: $dhikrId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CountersTable counters = $CountersTable(this);
  late final $DhikrsTable dhikrs = $DhikrsTable(this);
  late final $DhikrSelectionsTable dhikrSelections = $DhikrSelectionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    counters,
    dhikrs,
    dhikrSelections,
  ];
}

typedef $$CountersTableCreateCompanionBuilder =
    CountersCompanion Function({
      Value<int> id,
      required int count,
      Value<int> rounds,
      Value<int> total,
      Value<int?> target,
    });
typedef $$CountersTableUpdateCompanionBuilder =
    CountersCompanion Function({
      Value<int> id,
      Value<int> count,
      Value<int> rounds,
      Value<int> total,
      Value<int?> target,
    });

class $$CountersTableFilterComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);
}

class $$CountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountersTable,
          Counter,
          $$CountersTableFilterComposer,
          $$CountersTableOrderingComposer,
          $$CountersTableAnnotationComposer,
          $$CountersTableCreateCompanionBuilder,
          $$CountersTableUpdateCompanionBuilder,
          (Counter, BaseReferences<_$AppDatabase, $CountersTable, Counter>),
          Counter,
          PrefetchHooks Function()
        > {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int?> target = const Value.absent(),
              }) => CountersCompanion(
                id: id,
                count: count,
                rounds: rounds,
                total: total,
                target: target,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int count,
                Value<int> rounds = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int?> target = const Value.absent(),
              }) => CountersCompanion.insert(
                id: id,
                count: count,
                rounds: rounds,
                total: total,
                target: target,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountersTable,
      Counter,
      $$CountersTableFilterComposer,
      $$CountersTableOrderingComposer,
      $$CountersTableAnnotationComposer,
      $$CountersTableCreateCompanionBuilder,
      $$CountersTableUpdateCompanionBuilder,
      (Counter, BaseReferences<_$AppDatabase, $CountersTable, Counter>),
      Counter,
      PrefetchHooks Function()
    >;
typedef $$DhikrsTableCreateCompanionBuilder =
    DhikrsCompanion Function({Value<int> id, required String name});
typedef $$DhikrsTableUpdateCompanionBuilder =
    DhikrsCompanion Function({Value<int> id, Value<String> name});

class $$DhikrsTableFilterComposer
    extends Composer<_$AppDatabase, $DhikrsTable> {
  $$DhikrsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DhikrsTableOrderingComposer
    extends Composer<_$AppDatabase, $DhikrsTable> {
  $$DhikrsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DhikrsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DhikrsTable> {
  $$DhikrsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$DhikrsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DhikrsTable,
          Dhikr,
          $$DhikrsTableFilterComposer,
          $$DhikrsTableOrderingComposer,
          $$DhikrsTableAnnotationComposer,
          $$DhikrsTableCreateCompanionBuilder,
          $$DhikrsTableUpdateCompanionBuilder,
          (Dhikr, BaseReferences<_$AppDatabase, $DhikrsTable, Dhikr>),
          Dhikr,
          PrefetchHooks Function()
        > {
  $$DhikrsTableTableManager(_$AppDatabase db, $DhikrsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DhikrsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DhikrsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DhikrsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => DhikrsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  DhikrsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DhikrsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DhikrsTable,
      Dhikr,
      $$DhikrsTableFilterComposer,
      $$DhikrsTableOrderingComposer,
      $$DhikrsTableAnnotationComposer,
      $$DhikrsTableCreateCompanionBuilder,
      $$DhikrsTableUpdateCompanionBuilder,
      (Dhikr, BaseReferences<_$AppDatabase, $DhikrsTable, Dhikr>),
      Dhikr,
      PrefetchHooks Function()
    >;
typedef $$DhikrSelectionsTableCreateCompanionBuilder =
    DhikrSelectionsCompanion Function({Value<int> id, Value<int?> dhikrId});
typedef $$DhikrSelectionsTableUpdateCompanionBuilder =
    DhikrSelectionsCompanion Function({Value<int> id, Value<int?> dhikrId});

class $$DhikrSelectionsTableFilterComposer
    extends Composer<_$AppDatabase, $DhikrSelectionsTable> {
  $$DhikrSelectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dhikrId => $composableBuilder(
    column: $table.dhikrId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DhikrSelectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DhikrSelectionsTable> {
  $$DhikrSelectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dhikrId => $composableBuilder(
    column: $table.dhikrId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DhikrSelectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DhikrSelectionsTable> {
  $$DhikrSelectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dhikrId =>
      $composableBuilder(column: $table.dhikrId, builder: (column) => column);
}

class $$DhikrSelectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DhikrSelectionsTable,
          DhikrSelection,
          $$DhikrSelectionsTableFilterComposer,
          $$DhikrSelectionsTableOrderingComposer,
          $$DhikrSelectionsTableAnnotationComposer,
          $$DhikrSelectionsTableCreateCompanionBuilder,
          $$DhikrSelectionsTableUpdateCompanionBuilder,
          (
            DhikrSelection,
            BaseReferences<
              _$AppDatabase,
              $DhikrSelectionsTable,
              DhikrSelection
            >,
          ),
          DhikrSelection,
          PrefetchHooks Function()
        > {
  $$DhikrSelectionsTableTableManager(
    _$AppDatabase db,
    $DhikrSelectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DhikrSelectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DhikrSelectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DhikrSelectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> dhikrId = const Value.absent(),
              }) => DhikrSelectionsCompanion(id: id, dhikrId: dhikrId),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> dhikrId = const Value.absent(),
              }) => DhikrSelectionsCompanion.insert(id: id, dhikrId: dhikrId),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DhikrSelectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DhikrSelectionsTable,
      DhikrSelection,
      $$DhikrSelectionsTableFilterComposer,
      $$DhikrSelectionsTableOrderingComposer,
      $$DhikrSelectionsTableAnnotationComposer,
      $$DhikrSelectionsTableCreateCompanionBuilder,
      $$DhikrSelectionsTableUpdateCompanionBuilder,
      (
        DhikrSelection,
        BaseReferences<_$AppDatabase, $DhikrSelectionsTable, DhikrSelection>,
      ),
      DhikrSelection,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
  $$DhikrsTableTableManager get dhikrs =>
      $$DhikrsTableTableManager(_db, _db.dhikrs);
  $$DhikrSelectionsTableTableManager get dhikrSelections =>
      $$DhikrSelectionsTableTableManager(_db, _db.dhikrSelections);
}
