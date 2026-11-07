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

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vibrationMeta = const VerificationMeta(
    'vibration',
  );
  @override
  late final GeneratedColumn<bool> vibration = GeneratedColumn<bool>(
    'vibration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration" IN (0, 1))',
    ),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    check: () =>
        const CustomExpression<bool>("theme IN ('light', 'dark', 'system')"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tapVibrationMeta = const VerificationMeta(
    'tapVibration',
  );
  @override
  late final GeneratedColumn<bool> tapVibration = GeneratedColumn<bool>(
    'tap_vibration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tap_vibration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, vibration, theme, tapVibration];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vibration')) {
      context.handle(
        _vibrationMeta,
        vibration.isAcceptableOrUnknown(data['vibration']!, _vibrationMeta),
      );
    } else if (isInserting) {
      context.missing(_vibrationMeta);
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    } else if (isInserting) {
      context.missing(_themeMeta);
    }
    if (data.containsKey('tap_vibration')) {
      context.handle(
        _tapVibrationMeta,
        tapVibration.isAcceptableOrUnknown(
          data['tap_vibration']!,
          _tapVibrationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vibration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      tapVibration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tap_vibration'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final bool vibration;
  final String theme;

  /// Spec 0009, schema v6. Rows kept from v5 get the default: off (AC-1).
  final bool tapVibration;
  const Setting({
    required this.id,
    required this.vibration,
    required this.theme,
    required this.tapVibration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vibration'] = Variable<bool>(vibration);
    map['theme'] = Variable<String>(theme);
    map['tap_vibration'] = Variable<bool>(tapVibration);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      vibration: Value(vibration),
      theme: Value(theme),
      tapVibration: Value(tapVibration),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      vibration: serializer.fromJson<bool>(json['vibration']),
      theme: serializer.fromJson<String>(json['theme']),
      tapVibration: serializer.fromJson<bool>(json['tapVibration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vibration': serializer.toJson<bool>(vibration),
      'theme': serializer.toJson<String>(theme),
      'tapVibration': serializer.toJson<bool>(tapVibration),
    };
  }

  Setting copyWith({
    int? id,
    bool? vibration,
    String? theme,
    bool? tapVibration,
  }) => Setting(
    id: id ?? this.id,
    vibration: vibration ?? this.vibration,
    theme: theme ?? this.theme,
    tapVibration: tapVibration ?? this.tapVibration,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      vibration: data.vibration.present ? data.vibration.value : this.vibration,
      theme: data.theme.present ? data.theme.value : this.theme,
      tapVibration: data.tapVibration.present
          ? data.tapVibration.value
          : this.tapVibration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('vibration: $vibration, ')
          ..write('theme: $theme, ')
          ..write('tapVibration: $tapVibration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vibration, theme, tapVibration);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.vibration == this.vibration &&
          other.theme == this.theme &&
          other.tapVibration == this.tapVibration);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<bool> vibration;
  final Value<String> theme;
  final Value<bool> tapVibration;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.vibration = const Value.absent(),
    this.theme = const Value.absent(),
    this.tapVibration = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required bool vibration,
    required String theme,
    this.tapVibration = const Value.absent(),
  }) : vibration = Value(vibration),
       theme = Value(theme);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<bool>? vibration,
    Expression<String>? theme,
    Expression<bool>? tapVibration,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vibration != null) 'vibration': vibration,
      if (theme != null) 'theme': theme,
      if (tapVibration != null) 'tap_vibration': tapVibration,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? vibration,
    Value<String>? theme,
    Value<bool>? tapVibration,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      vibration: vibration ?? this.vibration,
      theme: theme ?? this.theme,
      tapVibration: tapVibration ?? this.tapVibration,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vibration.present) {
      map['vibration'] = Variable<bool>(vibration.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (tapVibration.present) {
      map['tap_vibration'] = Variable<bool>(tapVibration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('vibration: $vibration, ')
          ..write('theme: $theme, ')
          ..write('tapVibration: $tapVibration')
          ..write(')'))
        .toString();
  }
}

class $TesbihatProgressTable extends TesbihatProgress
    with TableInfo<$TesbihatProgressTable, TesbihatProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TesbihatProgressTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('step >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _finishedMeta = const VerificationMeta(
    'finished',
  );
  @override
  late final GeneratedColumn<bool> finished = GeneratedColumn<bool>(
    'finished',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("finished" IN (0, 1))',
    ),
  );
  static const VerificationMeta _completionsMeta = const VerificationMeta(
    'completions',
  );
  @override
  late final GeneratedColumn<int> completions = GeneratedColumn<int>(
    'completions',
    aliasedName,
    false,
    check: () => const CustomExpression<bool>('completions >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedMeta = const VerificationMeta(
    'selected',
  );
  @override
  late final GeneratedColumn<bool> selected = GeneratedColumn<bool>(
    'selected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("selected" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    step,
    count,
    finished,
    completions,
    selected,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tesbihat_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<TesbihatProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    } else if (isInserting) {
      context.missing(_stepMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('finished')) {
      context.handle(
        _finishedMeta,
        finished.isAcceptableOrUnknown(data['finished']!, _finishedMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedMeta);
    }
    if (data.containsKey('completions')) {
      context.handle(
        _completionsMeta,
        completions.isAcceptableOrUnknown(
          data['completions']!,
          _completionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completionsMeta);
    }
    if (data.containsKey('selected')) {
      context.handle(
        _selectedMeta,
        selected.isAcceptableOrUnknown(data['selected']!, _selectedMeta),
      );
    } else if (isInserting) {
      context.missing(_selectedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TesbihatProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TesbihatProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      finished: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}finished'],
      )!,
      completions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completions'],
      )!,
      selected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}selected'],
      )!,
    );
  }

  @override
  $TesbihatProgressTable createAlias(String alias) {
    return $TesbihatProgressTable(attachedDatabase, alias);
  }
}

class TesbihatProgressData extends DataClass
    implements Insertable<TesbihatProgressData> {
  final int id;
  final int step;
  final int count;
  final bool finished;
  final int completions;
  final bool selected;
  const TesbihatProgressData({
    required this.id,
    required this.step,
    required this.count,
    required this.finished,
    required this.completions,
    required this.selected,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['step'] = Variable<int>(step);
    map['count'] = Variable<int>(count);
    map['finished'] = Variable<bool>(finished);
    map['completions'] = Variable<int>(completions);
    map['selected'] = Variable<bool>(selected);
    return map;
  }

  TesbihatProgressCompanion toCompanion(bool nullToAbsent) {
    return TesbihatProgressCompanion(
      id: Value(id),
      step: Value(step),
      count: Value(count),
      finished: Value(finished),
      completions: Value(completions),
      selected: Value(selected),
    );
  }

  factory TesbihatProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TesbihatProgressData(
      id: serializer.fromJson<int>(json['id']),
      step: serializer.fromJson<int>(json['step']),
      count: serializer.fromJson<int>(json['count']),
      finished: serializer.fromJson<bool>(json['finished']),
      completions: serializer.fromJson<int>(json['completions']),
      selected: serializer.fromJson<bool>(json['selected']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'step': serializer.toJson<int>(step),
      'count': serializer.toJson<int>(count),
      'finished': serializer.toJson<bool>(finished),
      'completions': serializer.toJson<int>(completions),
      'selected': serializer.toJson<bool>(selected),
    };
  }

  TesbihatProgressData copyWith({
    int? id,
    int? step,
    int? count,
    bool? finished,
    int? completions,
    bool? selected,
  }) => TesbihatProgressData(
    id: id ?? this.id,
    step: step ?? this.step,
    count: count ?? this.count,
    finished: finished ?? this.finished,
    completions: completions ?? this.completions,
    selected: selected ?? this.selected,
  );
  TesbihatProgressData copyWithCompanion(TesbihatProgressCompanion data) {
    return TesbihatProgressData(
      id: data.id.present ? data.id.value : this.id,
      step: data.step.present ? data.step.value : this.step,
      count: data.count.present ? data.count.value : this.count,
      finished: data.finished.present ? data.finished.value : this.finished,
      completions: data.completions.present
          ? data.completions.value
          : this.completions,
      selected: data.selected.present ? data.selected.value : this.selected,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TesbihatProgressData(')
          ..write('id: $id, ')
          ..write('step: $step, ')
          ..write('count: $count, ')
          ..write('finished: $finished, ')
          ..write('completions: $completions, ')
          ..write('selected: $selected')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, step, count, finished, completions, selected);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TesbihatProgressData &&
          other.id == this.id &&
          other.step == this.step &&
          other.count == this.count &&
          other.finished == this.finished &&
          other.completions == this.completions &&
          other.selected == this.selected);
}

class TesbihatProgressCompanion extends UpdateCompanion<TesbihatProgressData> {
  final Value<int> id;
  final Value<int> step;
  final Value<int> count;
  final Value<bool> finished;
  final Value<int> completions;
  final Value<bool> selected;
  const TesbihatProgressCompanion({
    this.id = const Value.absent(),
    this.step = const Value.absent(),
    this.count = const Value.absent(),
    this.finished = const Value.absent(),
    this.completions = const Value.absent(),
    this.selected = const Value.absent(),
  });
  TesbihatProgressCompanion.insert({
    this.id = const Value.absent(),
    required int step,
    required int count,
    required bool finished,
    required int completions,
    required bool selected,
  }) : step = Value(step),
       count = Value(count),
       finished = Value(finished),
       completions = Value(completions),
       selected = Value(selected);
  static Insertable<TesbihatProgressData> custom({
    Expression<int>? id,
    Expression<int>? step,
    Expression<int>? count,
    Expression<bool>? finished,
    Expression<int>? completions,
    Expression<bool>? selected,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (step != null) 'step': step,
      if (count != null) 'count': count,
      if (finished != null) 'finished': finished,
      if (completions != null) 'completions': completions,
      if (selected != null) 'selected': selected,
    });
  }

  TesbihatProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? step,
    Value<int>? count,
    Value<bool>? finished,
    Value<int>? completions,
    Value<bool>? selected,
  }) {
    return TesbihatProgressCompanion(
      id: id ?? this.id,
      step: step ?? this.step,
      count: count ?? this.count,
      finished: finished ?? this.finished,
      completions: completions ?? this.completions,
      selected: selected ?? this.selected,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (finished.present) {
      map['finished'] = Variable<bool>(finished.value);
    }
    if (completions.present) {
      map['completions'] = Variable<int>(completions.value);
    }
    if (selected.present) {
      map['selected'] = Variable<bool>(selected.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TesbihatProgressCompanion(')
          ..write('id: $id, ')
          ..write('step: $step, ')
          ..write('count: $count, ')
          ..write('finished: $finished, ')
          ..write('completions: $completions, ')
          ..write('selected: $selected')
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
  late final $SettingsTable settings = $SettingsTable(this);
  late final $TesbihatProgressTable tesbihatProgress = $TesbihatProgressTable(
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
    settings,
    tesbihatProgress,
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
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      required bool vibration,
      required String theme,
      Value<bool> tapVibration,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<bool> vibration,
      Value<String> theme,
      Value<bool> tapVibration,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<bool> get vibration => $composableBuilder(
    column: $table.vibration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tapVibration => $composableBuilder(
    column: $table.tapVibration,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get vibration => $composableBuilder(
    column: $table.vibration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tapVibration => $composableBuilder(
    column: $table.tapVibration,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get vibration =>
      $composableBuilder(column: $table.vibration, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<bool> get tapVibration => $composableBuilder(
    column: $table.tapVibration,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> vibration = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<bool> tapVibration = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                vibration: vibration,
                theme: theme,
                tapVibration: tapVibration,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool vibration,
                required String theme,
                Value<bool> tapVibration = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                vibration: vibration,
                theme: theme,
                tapVibration: tapVibration,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$TesbihatProgressTableCreateCompanionBuilder =
    TesbihatProgressCompanion Function({
      Value<int> id,
      required int step,
      required int count,
      required bool finished,
      required int completions,
      required bool selected,
    });
typedef $$TesbihatProgressTableUpdateCompanionBuilder =
    TesbihatProgressCompanion Function({
      Value<int> id,
      Value<int> step,
      Value<int> count,
      Value<bool> finished,
      Value<int> completions,
      Value<bool> selected,
    });

class $$TesbihatProgressTableFilterComposer
    extends Composer<_$AppDatabase, $TesbihatProgressTable> {
  $$TesbihatProgressTableFilterComposer({
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

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get finished => $composableBuilder(
    column: $table.finished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completions => $composableBuilder(
    column: $table.completions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get selected => $composableBuilder(
    column: $table.selected,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TesbihatProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $TesbihatProgressTable> {
  $$TesbihatProgressTableOrderingComposer({
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

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get finished => $composableBuilder(
    column: $table.finished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completions => $composableBuilder(
    column: $table.completions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get selected => $composableBuilder(
    column: $table.selected,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TesbihatProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $TesbihatProgressTable> {
  $$TesbihatProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<bool> get finished =>
      $composableBuilder(column: $table.finished, builder: (column) => column);

  GeneratedColumn<int> get completions => $composableBuilder(
    column: $table.completions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get selected =>
      $composableBuilder(column: $table.selected, builder: (column) => column);
}

class $$TesbihatProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TesbihatProgressTable,
          TesbihatProgressData,
          $$TesbihatProgressTableFilterComposer,
          $$TesbihatProgressTableOrderingComposer,
          $$TesbihatProgressTableAnnotationComposer,
          $$TesbihatProgressTableCreateCompanionBuilder,
          $$TesbihatProgressTableUpdateCompanionBuilder,
          (
            TesbihatProgressData,
            BaseReferences<
              _$AppDatabase,
              $TesbihatProgressTable,
              TesbihatProgressData
            >,
          ),
          TesbihatProgressData,
          PrefetchHooks Function()
        > {
  $$TesbihatProgressTableTableManager(
    _$AppDatabase db,
    $TesbihatProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TesbihatProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TesbihatProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TesbihatProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> step = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<bool> finished = const Value.absent(),
                Value<int> completions = const Value.absent(),
                Value<bool> selected = const Value.absent(),
              }) => TesbihatProgressCompanion(
                id: id,
                step: step,
                count: count,
                finished: finished,
                completions: completions,
                selected: selected,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int step,
                required int count,
                required bool finished,
                required int completions,
                required bool selected,
              }) => TesbihatProgressCompanion.insert(
                id: id,
                step: step,
                count: count,
                finished: finished,
                completions: completions,
                selected: selected,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TesbihatProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TesbihatProgressTable,
      TesbihatProgressData,
      $$TesbihatProgressTableFilterComposer,
      $$TesbihatProgressTableOrderingComposer,
      $$TesbihatProgressTableAnnotationComposer,
      $$TesbihatProgressTableCreateCompanionBuilder,
      $$TesbihatProgressTableUpdateCompanionBuilder,
      (
        TesbihatProgressData,
        BaseReferences<
          _$AppDatabase,
          $TesbihatProgressTable,
          TesbihatProgressData
        >,
      ),
      TesbihatProgressData,
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
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$TesbihatProgressTableTableManager get tesbihatProgress =>
      $$TesbihatProgressTableTableManager(_db, _db.tesbihatProgress);
}
