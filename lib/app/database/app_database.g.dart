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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CountersTable counters = $CountersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [counters];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
}
