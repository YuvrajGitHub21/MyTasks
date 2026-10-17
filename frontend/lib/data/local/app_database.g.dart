// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, ProfileRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileTypeMeta = const VerificationMeta(
    'profileType',
  );
  @override
  late final GeneratedColumn<String> profileType = GeneratedColumn<String>(
    'profile_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GUEST'),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileType,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_type')) {
      context.handle(
        _profileTypeMeta,
        profileType.isAcceptableOrUnknown(
          data['profile_type']!,
          _profileTypeMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_type'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRecord extends DataClass implements Insertable<ProfileRecord> {
  final String id;
  final String profileType;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const ProfileRecord({
    required this.id,
    required this.profileType,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_type'] = Variable<String>(profileType);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(
      id: Value(id),
      profileType: Value(profileType),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ProfileRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRecord(
      id: serializer.fromJson<String>(json['id']),
      profileType: serializer.fromJson<String>(json['profileType']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileType': serializer.toJson<String>(profileType),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  ProfileRecord copyWith({
    String? id,
    String? profileType,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => ProfileRecord(
    id: id ?? this.id,
    profileType: profileType ?? this.profileType,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ProfileRecord copyWithCompanion(LocalProfilesCompanion data) {
    return ProfileRecord(
      id: data.id.present ? data.id.value : this.id,
      profileType: data.profileType.present
          ? data.profileType.value
          : this.profileType,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRecord(')
          ..write('id: $id, ')
          ..write('profileType: $profileType, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profileType, createdAtUtc, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRecord &&
          other.id == this.id &&
          other.profileType == this.profileType &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class LocalProfilesCompanion extends UpdateCompanion<ProfileRecord> {
  final Value<String> id;
  final Value<String> profileType;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const LocalProfilesCompanion({
    this.id = const Value.absent(),
    this.profileType = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    required String id,
    this.profileType = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ProfileRecord> custom({
    Expression<String>? id,
    Expression<String>? profileType,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileType != null) 'profile_type': profileType,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileType,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return LocalProfilesCompanion(
      id: id ?? this.id,
      profileType: profileType ?? this.profileType,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileType.present) {
      map['profile_type'] = Variable<String>(profileType.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('id: $id, ')
          ..write('profileType: $profileType, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTasksTable extends LocalTasks
    with TableInfo<$LocalTasksTable, TaskRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtopicMeta = const VerificationMeta(
    'subtopic',
  );
  @override
  late final GeneratedColumn<String> subtopic = GeneratedColumn<String>(
    'subtopic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedEndDateMeta = const VerificationMeta(
    'plannedEndDate',
  );
  @override
  late final GeneratedColumn<String> plannedEndDate = GeneratedColumn<String>(
    'planned_end_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maximumEndDateMeta = const VerificationMeta(
    'maximumEndDate',
  );
  @override
  late final GeneratedColumn<String> maximumEndDate = GeneratedColumn<String>(
    'maximum_end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effortHundredthsMeta = const VerificationMeta(
    'effortHundredths',
  );
  @override
  late final GeneratedColumn<int> effortHundredths = GeneratedColumn<int>(
    'effort_hundredths',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OPEN'),
  );
  static const VerificationMeta _completedAtUtcMeta = const VerificationMeta(
    'completedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> completedAtUtc =
      GeneratedColumn<DateTime>(
        'completed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    topic,
    subtopic,
    description,
    startDate,
    plannedEndDate,
    maximumEndDate,
    effortHundredths,
    status,
    completedAtUtc,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('subtopic')) {
      context.handle(
        _subtopicMeta,
        subtopic.isAcceptableOrUnknown(data['subtopic']!, _subtopicMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('planned_end_date')) {
      context.handle(
        _plannedEndDateMeta,
        plannedEndDate.isAcceptableOrUnknown(
          data['planned_end_date']!,
          _plannedEndDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedEndDateMeta);
    }
    if (data.containsKey('maximum_end_date')) {
      context.handle(
        _maximumEndDateMeta,
        maximumEndDate.isAcceptableOrUnknown(
          data['maximum_end_date']!,
          _maximumEndDateMeta,
        ),
      );
    }
    if (data.containsKey('effort_hundredths')) {
      context.handle(
        _effortHundredthsMeta,
        effortHundredths.isAcceptableOrUnknown(
          data['effort_hundredths']!,
          _effortHundredthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effortHundredthsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at_utc')) {
      context.handle(
        _completedAtUtcMeta,
        completedAtUtc.isAcceptableOrUnknown(
          data['completed_at_utc']!,
          _completedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, profileId},
  ];
  @override
  TaskRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      subtopic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtopic'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      plannedEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_end_date'],
      )!,
      maximumEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maximum_end_date'],
      ),
      effortHundredths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effort_hundredths'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at_utc'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $LocalTasksTable createAlias(String alias) {
    return $LocalTasksTable(attachedDatabase, alias);
  }
}

class TaskRecord extends DataClass implements Insertable<TaskRecord> {
  final String id;
  final String profileId;
  final String topic;
  final String? subtopic;
  final String? description;
  final String startDate;
  final String plannedEndDate;
  final String? maximumEndDate;
  final int effortHundredths;
  final String status;
  final DateTime? completedAtUtc;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const TaskRecord({
    required this.id,
    required this.profileId,
    required this.topic,
    this.subtopic,
    this.description,
    required this.startDate,
    required this.plannedEndDate,
    this.maximumEndDate,
    required this.effortHundredths,
    required this.status,
    this.completedAtUtc,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['topic'] = Variable<String>(topic);
    if (!nullToAbsent || subtopic != null) {
      map['subtopic'] = Variable<String>(subtopic);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_date'] = Variable<String>(startDate);
    map['planned_end_date'] = Variable<String>(plannedEndDate);
    if (!nullToAbsent || maximumEndDate != null) {
      map['maximum_end_date'] = Variable<String>(maximumEndDate);
    }
    map['effort_hundredths'] = Variable<int>(effortHundredths);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  LocalTasksCompanion toCompanion(bool nullToAbsent) {
    return LocalTasksCompanion(
      id: Value(id),
      profileId: Value(profileId),
      topic: Value(topic),
      subtopic: subtopic == null && nullToAbsent
          ? const Value.absent()
          : Value(subtopic),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDate: Value(startDate),
      plannedEndDate: Value(plannedEndDate),
      maximumEndDate: maximumEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(maximumEndDate),
      effortHundredths: Value(effortHundredths),
      status: Value(status),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory TaskRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRecord(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      topic: serializer.fromJson<String>(json['topic']),
      subtopic: serializer.fromJson<String?>(json['subtopic']),
      description: serializer.fromJson<String?>(json['description']),
      startDate: serializer.fromJson<String>(json['startDate']),
      plannedEndDate: serializer.fromJson<String>(json['plannedEndDate']),
      maximumEndDate: serializer.fromJson<String?>(json['maximumEndDate']),
      effortHundredths: serializer.fromJson<int>(json['effortHundredths']),
      status: serializer.fromJson<String>(json['status']),
      completedAtUtc: serializer.fromJson<DateTime?>(json['completedAtUtc']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'topic': serializer.toJson<String>(topic),
      'subtopic': serializer.toJson<String?>(subtopic),
      'description': serializer.toJson<String?>(description),
      'startDate': serializer.toJson<String>(startDate),
      'plannedEndDate': serializer.toJson<String>(plannedEndDate),
      'maximumEndDate': serializer.toJson<String?>(maximumEndDate),
      'effortHundredths': serializer.toJson<int>(effortHundredths),
      'status': serializer.toJson<String>(status),
      'completedAtUtc': serializer.toJson<DateTime?>(completedAtUtc),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  TaskRecord copyWith({
    String? id,
    String? profileId,
    String? topic,
    Value<String?> subtopic = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? startDate,
    String? plannedEndDate,
    Value<String?> maximumEndDate = const Value.absent(),
    int? effortHundredths,
    String? status,
    Value<DateTime?> completedAtUtc = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => TaskRecord(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    topic: topic ?? this.topic,
    subtopic: subtopic.present ? subtopic.value : this.subtopic,
    description: description.present ? description.value : this.description,
    startDate: startDate ?? this.startDate,
    plannedEndDate: plannedEndDate ?? this.plannedEndDate,
    maximumEndDate: maximumEndDate.present
        ? maximumEndDate.value
        : this.maximumEndDate,
    effortHundredths: effortHundredths ?? this.effortHundredths,
    status: status ?? this.status,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  TaskRecord copyWithCompanion(LocalTasksCompanion data) {
    return TaskRecord(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      topic: data.topic.present ? data.topic.value : this.topic,
      subtopic: data.subtopic.present ? data.subtopic.value : this.subtopic,
      description: data.description.present
          ? data.description.value
          : this.description,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      plannedEndDate: data.plannedEndDate.present
          ? data.plannedEndDate.value
          : this.plannedEndDate,
      maximumEndDate: data.maximumEndDate.present
          ? data.maximumEndDate.value
          : this.maximumEndDate,
      effortHundredths: data.effortHundredths.present
          ? data.effortHundredths.value
          : this.effortHundredths,
      status: data.status.present ? data.status.value : this.status,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRecord(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('topic: $topic, ')
          ..write('subtopic: $subtopic, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('plannedEndDate: $plannedEndDate, ')
          ..write('maximumEndDate: $maximumEndDate, ')
          ..write('effortHundredths: $effortHundredths, ')
          ..write('status: $status, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    topic,
    subtopic,
    description,
    startDate,
    plannedEndDate,
    maximumEndDate,
    effortHundredths,
    status,
    completedAtUtc,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRecord &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.topic == this.topic &&
          other.subtopic == this.subtopic &&
          other.description == this.description &&
          other.startDate == this.startDate &&
          other.plannedEndDate == this.plannedEndDate &&
          other.maximumEndDate == this.maximumEndDate &&
          other.effortHundredths == this.effortHundredths &&
          other.status == this.status &&
          other.completedAtUtc == this.completedAtUtc &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class LocalTasksCompanion extends UpdateCompanion<TaskRecord> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> topic;
  final Value<String?> subtopic;
  final Value<String?> description;
  final Value<String> startDate;
  final Value<String> plannedEndDate;
  final Value<String?> maximumEndDate;
  final Value<int> effortHundredths;
  final Value<String> status;
  final Value<DateTime?> completedAtUtc;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const LocalTasksCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.topic = const Value.absent(),
    this.subtopic = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.plannedEndDate = const Value.absent(),
    this.maximumEndDate = const Value.absent(),
    this.effortHundredths = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTasksCompanion.insert({
    required String id,
    required String profileId,
    required String topic,
    this.subtopic = const Value.absent(),
    this.description = const Value.absent(),
    required String startDate,
    required String plannedEndDate,
    this.maximumEndDate = const Value.absent(),
    required int effortHundredths,
    this.status = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       topic = Value(topic),
       startDate = Value(startDate),
       plannedEndDate = Value(plannedEndDate),
       effortHundredths = Value(effortHundredths),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<TaskRecord> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? topic,
    Expression<String>? subtopic,
    Expression<String>? description,
    Expression<String>? startDate,
    Expression<String>? plannedEndDate,
    Expression<String>? maximumEndDate,
    Expression<int>? effortHundredths,
    Expression<String>? status,
    Expression<DateTime>? completedAtUtc,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (topic != null) 'topic': topic,
      if (subtopic != null) 'subtopic': subtopic,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (plannedEndDate != null) 'planned_end_date': plannedEndDate,
      if (maximumEndDate != null) 'maximum_end_date': maximumEndDate,
      if (effortHundredths != null) 'effort_hundredths': effortHundredths,
      if (status != null) 'status': status,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? topic,
    Value<String?>? subtopic,
    Value<String?>? description,
    Value<String>? startDate,
    Value<String>? plannedEndDate,
    Value<String?>? maximumEndDate,
    Value<int>? effortHundredths,
    Value<String>? status,
    Value<DateTime?>? completedAtUtc,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return LocalTasksCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      topic: topic ?? this.topic,
      subtopic: subtopic ?? this.subtopic,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      plannedEndDate: plannedEndDate ?? this.plannedEndDate,
      maximumEndDate: maximumEndDate ?? this.maximumEndDate,
      effortHundredths: effortHundredths ?? this.effortHundredths,
      status: status ?? this.status,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (subtopic.present) {
      map['subtopic'] = Variable<String>(subtopic.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (plannedEndDate.present) {
      map['planned_end_date'] = Variable<String>(plannedEndDate.value);
    }
    if (maximumEndDate.present) {
      map['maximum_end_date'] = Variable<String>(maximumEndDate.value);
    }
    if (effortHundredths.present) {
      map['effort_hundredths'] = Variable<int>(effortHundredths.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTasksCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('topic: $topic, ')
          ..write('subtopic: $subtopic, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('plannedEndDate: $plannedEndDate, ')
          ..write('maximumEndDate: $maximumEndDate, ')
          ..write('effortHundredths: $effortHundredths, ')
          ..write('status: $status, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProgressEntriesTable extends LocalProgressEntries
    with TableInfo<$LocalProgressEntriesTable, ProgressEntryRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _percentCompleteMeta = const VerificationMeta(
    'percentComplete',
  );
  @override
  late final GeneratedColumn<int> percentComplete = GeneratedColumn<int>(
    'percent_complete',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedUnitsMeta = const VerificationMeta(
    'completedUnits',
  );
  @override
  late final GeneratedColumn<int> completedUnits = GeneratedColumn<int>(
    'completed_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalUnitsMeta = const VerificationMeta(
    'totalUnits',
  );
  @override
  late final GeneratedColumn<int> totalUnits = GeneratedColumn<int>(
    'total_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    taskId,
    method,
    percentComplete,
    completedUnits,
    totalUnits,
    note,
    occurredAtUtc,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressEntryRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('percent_complete')) {
      context.handle(
        _percentCompleteMeta,
        percentComplete.isAcceptableOrUnknown(
          data['percent_complete']!,
          _percentCompleteMeta,
        ),
      );
    }
    if (data.containsKey('completed_units')) {
      context.handle(
        _completedUnitsMeta,
        completedUnits.isAcceptableOrUnknown(
          data['completed_units']!,
          _completedUnitsMeta,
        ),
      );
    }
    if (data.containsKey('total_units')) {
      context.handle(
        _totalUnitsMeta,
        totalUnits.isAcceptableOrUnknown(data['total_units']!, _totalUnitsMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressEntryRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressEntryRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      percentComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percent_complete'],
      ),
      completedUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_units'],
      ),
      totalUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_units'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $LocalProgressEntriesTable createAlias(String alias) {
    return $LocalProgressEntriesTable(attachedDatabase, alias);
  }
}

class ProgressEntryRecord extends DataClass
    implements Insertable<ProgressEntryRecord> {
  final String id;
  final String profileId;
  final String taskId;
  final String method;
  final int? percentComplete;
  final int? completedUnits;
  final int? totalUnits;
  final String? note;
  final DateTime occurredAtUtc;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const ProgressEntryRecord({
    required this.id,
    required this.profileId,
    required this.taskId,
    required this.method,
    this.percentComplete,
    this.completedUnits,
    this.totalUnits,
    this.note,
    required this.occurredAtUtc,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['task_id'] = Variable<String>(taskId);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || percentComplete != null) {
      map['percent_complete'] = Variable<int>(percentComplete);
    }
    if (!nullToAbsent || completedUnits != null) {
      map['completed_units'] = Variable<int>(completedUnits);
    }
    if (!nullToAbsent || totalUnits != null) {
      map['total_units'] = Variable<int>(totalUnits);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  LocalProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalProgressEntriesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      taskId: Value(taskId),
      method: Value(method),
      percentComplete: percentComplete == null && nullToAbsent
          ? const Value.absent()
          : Value(percentComplete),
      completedUnits: completedUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(completedUnits),
      totalUnits: totalUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(totalUnits),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      occurredAtUtc: Value(occurredAtUtc),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ProgressEntryRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressEntryRecord(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      method: serializer.fromJson<String>(json['method']),
      percentComplete: serializer.fromJson<int?>(json['percentComplete']),
      completedUnits: serializer.fromJson<int?>(json['completedUnits']),
      totalUnits: serializer.fromJson<int?>(json['totalUnits']),
      note: serializer.fromJson<String?>(json['note']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'taskId': serializer.toJson<String>(taskId),
      'method': serializer.toJson<String>(method),
      'percentComplete': serializer.toJson<int?>(percentComplete),
      'completedUnits': serializer.toJson<int?>(completedUnits),
      'totalUnits': serializer.toJson<int?>(totalUnits),
      'note': serializer.toJson<String?>(note),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  ProgressEntryRecord copyWith({
    String? id,
    String? profileId,
    String? taskId,
    String? method,
    Value<int?> percentComplete = const Value.absent(),
    Value<int?> completedUnits = const Value.absent(),
    Value<int?> totalUnits = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? occurredAtUtc,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => ProgressEntryRecord(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    taskId: taskId ?? this.taskId,
    method: method ?? this.method,
    percentComplete: percentComplete.present
        ? percentComplete.value
        : this.percentComplete,
    completedUnits: completedUnits.present
        ? completedUnits.value
        : this.completedUnits,
    totalUnits: totalUnits.present ? totalUnits.value : this.totalUnits,
    note: note.present ? note.value : this.note,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ProgressEntryRecord copyWithCompanion(LocalProgressEntriesCompanion data) {
    return ProgressEntryRecord(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      method: data.method.present ? data.method.value : this.method,
      percentComplete: data.percentComplete.present
          ? data.percentComplete.value
          : this.percentComplete,
      completedUnits: data.completedUnits.present
          ? data.completedUnits.value
          : this.completedUnits,
      totalUnits: data.totalUnits.present
          ? data.totalUnits.value
          : this.totalUnits,
      note: data.note.present ? data.note.value : this.note,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressEntryRecord(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('taskId: $taskId, ')
          ..write('method: $method, ')
          ..write('percentComplete: $percentComplete, ')
          ..write('completedUnits: $completedUnits, ')
          ..write('totalUnits: $totalUnits, ')
          ..write('note: $note, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    taskId,
    method,
    percentComplete,
    completedUnits,
    totalUnits,
    note,
    occurredAtUtc,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressEntryRecord &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.taskId == this.taskId &&
          other.method == this.method &&
          other.percentComplete == this.percentComplete &&
          other.completedUnits == this.completedUnits &&
          other.totalUnits == this.totalUnits &&
          other.note == this.note &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class LocalProgressEntriesCompanion
    extends UpdateCompanion<ProgressEntryRecord> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> taskId;
  final Value<String> method;
  final Value<int?> percentComplete;
  final Value<int?> completedUnits;
  final Value<int?> totalUnits;
  final Value<String?> note;
  final Value<DateTime> occurredAtUtc;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const LocalProgressEntriesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.method = const Value.absent(),
    this.percentComplete = const Value.absent(),
    this.completedUnits = const Value.absent(),
    this.totalUnits = const Value.absent(),
    this.note = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProgressEntriesCompanion.insert({
    required String id,
    required String profileId,
    required String taskId,
    required String method,
    this.percentComplete = const Value.absent(),
    this.completedUnits = const Value.absent(),
    this.totalUnits = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime occurredAtUtc,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       taskId = Value(taskId),
       method = Value(method),
       occurredAtUtc = Value(occurredAtUtc),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ProgressEntryRecord> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? taskId,
    Expression<String>? method,
    Expression<int>? percentComplete,
    Expression<int>? completedUnits,
    Expression<int>? totalUnits,
    Expression<String>? note,
    Expression<DateTime>? occurredAtUtc,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (taskId != null) 'task_id': taskId,
      if (method != null) 'method': method,
      if (percentComplete != null) 'percent_complete': percentComplete,
      if (completedUnits != null) 'completed_units': completedUnits,
      if (totalUnits != null) 'total_units': totalUnits,
      if (note != null) 'note': note,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProgressEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? taskId,
    Value<String>? method,
    Value<int?>? percentComplete,
    Value<int?>? completedUnits,
    Value<int?>? totalUnits,
    Value<String?>? note,
    Value<DateTime>? occurredAtUtc,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return LocalProgressEntriesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      taskId: taskId ?? this.taskId,
      method: method ?? this.method,
      percentComplete: percentComplete ?? this.percentComplete,
      completedUnits: completedUnits ?? this.completedUnits,
      totalUnits: totalUnits ?? this.totalUnits,
      note: note ?? this.note,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (percentComplete.present) {
      map['percent_complete'] = Variable<int>(percentComplete.value);
    }
    if (completedUnits.present) {
      map['completed_units'] = Variable<int>(completedUnits.value);
    }
    if (totalUnits.present) {
      map['total_units'] = Variable<int>(totalUnits.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProgressEntriesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('taskId: $taskId, ')
          ..write('method: $method, ')
          ..write('percentComplete: $percentComplete, ')
          ..write('completedUnits: $completedUnits, ')
          ..write('totalUnits: $totalUnits, ')
          ..write('note: $note, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLifecycleEventsTable extends LocalLifecycleEvents
    with TableInfo<$LocalLifecycleEventsTable, LifecycleEventRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLifecycleEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    taskId,
    eventType,
    occurredAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_lifecycle_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LifecycleEventRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LifecycleEventRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LifecycleEventRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
    );
  }

  @override
  $LocalLifecycleEventsTable createAlias(String alias) {
    return $LocalLifecycleEventsTable(attachedDatabase, alias);
  }
}

class LifecycleEventRecord extends DataClass
    implements Insertable<LifecycleEventRecord> {
  final String id;
  final String profileId;
  final String taskId;
  final String eventType;
  final DateTime occurredAtUtc;
  const LifecycleEventRecord({
    required this.id,
    required this.profileId,
    required this.taskId,
    required this.eventType,
    required this.occurredAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['task_id'] = Variable<String>(taskId);
    map['event_type'] = Variable<String>(eventType);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    return map;
  }

  LocalLifecycleEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalLifecycleEventsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      taskId: Value(taskId),
      eventType: Value(eventType),
      occurredAtUtc: Value(occurredAtUtc),
    );
  }

  factory LifecycleEventRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LifecycleEventRecord(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'taskId': serializer.toJson<String>(taskId),
      'eventType': serializer.toJson<String>(eventType),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
    };
  }

  LifecycleEventRecord copyWith({
    String? id,
    String? profileId,
    String? taskId,
    String? eventType,
    DateTime? occurredAtUtc,
  }) => LifecycleEventRecord(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    taskId: taskId ?? this.taskId,
    eventType: eventType ?? this.eventType,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
  );
  LifecycleEventRecord copyWithCompanion(LocalLifecycleEventsCompanion data) {
    return LifecycleEventRecord(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LifecycleEventRecord(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('taskId: $taskId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAtUtc: $occurredAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, taskId, eventType, occurredAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LifecycleEventRecord &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.taskId == this.taskId &&
          other.eventType == this.eventType &&
          other.occurredAtUtc == this.occurredAtUtc);
}

class LocalLifecycleEventsCompanion
    extends UpdateCompanion<LifecycleEventRecord> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> taskId;
  final Value<String> eventType;
  final Value<DateTime> occurredAtUtc;
  final Value<int> rowid;
  const LocalLifecycleEventsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLifecycleEventsCompanion.insert({
    required String id,
    required String profileId,
    required String taskId,
    required String eventType,
    required DateTime occurredAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       taskId = Value(taskId),
       eventType = Value(eventType),
       occurredAtUtc = Value(occurredAtUtc);
  static Insertable<LifecycleEventRecord> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? taskId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (taskId != null) 'task_id': taskId,
      if (eventType != null) 'event_type': eventType,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLifecycleEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? taskId,
    Value<String>? eventType,
    Value<DateTime>? occurredAtUtc,
    Value<int>? rowid,
  }) {
    return LocalLifecycleEventsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      taskId: taskId ?? this.taskId,
      eventType: eventType ?? this.eventType,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLifecycleEventsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('taskId: $taskId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderPreferencesTable extends ReminderPreferences
    with TableInfo<$ReminderPreferencesTable, ReminderPreferenceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _morningTimeMinutesMeta =
      const VerificationMeta('morningTimeMinutes');
  @override
  late final GeneratedColumn<int> morningTimeMinutes = GeneratedColumn<int>(
    'morning_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _middayTimeMinutesMeta = const VerificationMeta(
    'middayTimeMinutes',
  );
  @override
  late final GeneratedColumn<int> middayTimeMinutes = GeneratedColumn<int>(
    'midday_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endOfDayTimeMinutesMeta =
      const VerificationMeta('endOfDayTimeMinutes');
  @override
  late final GeneratedColumn<int> endOfDayTimeMinutes = GeneratedColumn<int>(
    'end_of_day_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quietHoursStartMinutesMeta =
      const VerificationMeta('quietHoursStartMinutes');
  @override
  late final GeneratedColumn<int> quietHoursStartMinutes = GeneratedColumn<int>(
    'quiet_hours_start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quietHoursEndMinutesMeta =
      const VerificationMeta('quietHoursEndMinutes');
  @override
  late final GeneratedColumn<int> quietHoursEndMinutes = GeneratedColumn<int>(
    'quiet_hours_end_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vibrationEnabledMeta = const VerificationMeta(
    'vibrationEnabled',
  );
  @override
  late final GeneratedColumn<bool> vibrationEnabled = GeneratedColumn<bool>(
    'vibration_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    enabled,
    morningTimeMinutes,
    middayTimeMinutes,
    endOfDayTimeMinutes,
    quietHoursStartMinutes,
    quietHoursEndMinutes,
    soundEnabled,
    vibrationEnabled,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderPreferenceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('morning_time_minutes')) {
      context.handle(
        _morningTimeMinutesMeta,
        morningTimeMinutes.isAcceptableOrUnknown(
          data['morning_time_minutes']!,
          _morningTimeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_morningTimeMinutesMeta);
    }
    if (data.containsKey('midday_time_minutes')) {
      context.handle(
        _middayTimeMinutesMeta,
        middayTimeMinutes.isAcceptableOrUnknown(
          data['midday_time_minutes']!,
          _middayTimeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_middayTimeMinutesMeta);
    }
    if (data.containsKey('end_of_day_time_minutes')) {
      context.handle(
        _endOfDayTimeMinutesMeta,
        endOfDayTimeMinutes.isAcceptableOrUnknown(
          data['end_of_day_time_minutes']!,
          _endOfDayTimeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endOfDayTimeMinutesMeta);
    }
    if (data.containsKey('quiet_hours_start_minutes')) {
      context.handle(
        _quietHoursStartMinutesMeta,
        quietHoursStartMinutes.isAcceptableOrUnknown(
          data['quiet_hours_start_minutes']!,
          _quietHoursStartMinutesMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_end_minutes')) {
      context.handle(
        _quietHoursEndMinutesMeta,
        quietHoursEndMinutes.isAcceptableOrUnknown(
          data['quiet_hours_end_minutes']!,
          _quietHoursEndMinutesMeta,
        ),
      );
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    }
    if (data.containsKey('vibration_enabled')) {
      context.handle(
        _vibrationEnabledMeta,
        vibrationEnabled.isAcceptableOrUnknown(
          data['vibration_enabled']!,
          _vibrationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ReminderPreferenceRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderPreferenceRecord(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      morningTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}morning_time_minutes'],
      )!,
      middayTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}midday_time_minutes'],
      )!,
      endOfDayTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_of_day_time_minutes'],
      )!,
      quietHoursStartMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_hours_start_minutes'],
      ),
      quietHoursEndMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_hours_end_minutes'],
      ),
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
      vibrationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration_enabled'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ReminderPreferencesTable createAlias(String alias) {
    return $ReminderPreferencesTable(attachedDatabase, alias);
  }
}

class ReminderPreferenceRecord extends DataClass
    implements Insertable<ReminderPreferenceRecord> {
  final String profileId;
  final bool enabled;
  final int morningTimeMinutes;
  final int middayTimeMinutes;
  final int endOfDayTimeMinutes;
  final int? quietHoursStartMinutes;
  final int? quietHoursEndMinutes;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DateTime updatedAtUtc;
  const ReminderPreferenceRecord({
    required this.profileId,
    required this.enabled,
    required this.morningTimeMinutes,
    required this.middayTimeMinutes,
    required this.endOfDayTimeMinutes,
    this.quietHoursStartMinutes,
    this.quietHoursEndMinutes,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['enabled'] = Variable<bool>(enabled);
    map['morning_time_minutes'] = Variable<int>(morningTimeMinutes);
    map['midday_time_minutes'] = Variable<int>(middayTimeMinutes);
    map['end_of_day_time_minutes'] = Variable<int>(endOfDayTimeMinutes);
    if (!nullToAbsent || quietHoursStartMinutes != null) {
      map['quiet_hours_start_minutes'] = Variable<int>(quietHoursStartMinutes);
    }
    if (!nullToAbsent || quietHoursEndMinutes != null) {
      map['quiet_hours_end_minutes'] = Variable<int>(quietHoursEndMinutes);
    }
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['vibration_enabled'] = Variable<bool>(vibrationEnabled);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  ReminderPreferencesCompanion toCompanion(bool nullToAbsent) {
    return ReminderPreferencesCompanion(
      profileId: Value(profileId),
      enabled: Value(enabled),
      morningTimeMinutes: Value(morningTimeMinutes),
      middayTimeMinutes: Value(middayTimeMinutes),
      endOfDayTimeMinutes: Value(endOfDayTimeMinutes),
      quietHoursStartMinutes: quietHoursStartMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(quietHoursStartMinutes),
      quietHoursEndMinutes: quietHoursEndMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(quietHoursEndMinutes),
      soundEnabled: Value(soundEnabled),
      vibrationEnabled: Value(vibrationEnabled),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ReminderPreferenceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderPreferenceRecord(
      profileId: serializer.fromJson<String>(json['profileId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      morningTimeMinutes: serializer.fromJson<int>(json['morningTimeMinutes']),
      middayTimeMinutes: serializer.fromJson<int>(json['middayTimeMinutes']),
      endOfDayTimeMinutes: serializer.fromJson<int>(
        json['endOfDayTimeMinutes'],
      ),
      quietHoursStartMinutes: serializer.fromJson<int?>(
        json['quietHoursStartMinutes'],
      ),
      quietHoursEndMinutes: serializer.fromJson<int?>(
        json['quietHoursEndMinutes'],
      ),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      vibrationEnabled: serializer.fromJson<bool>(json['vibrationEnabled']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'enabled': serializer.toJson<bool>(enabled),
      'morningTimeMinutes': serializer.toJson<int>(morningTimeMinutes),
      'middayTimeMinutes': serializer.toJson<int>(middayTimeMinutes),
      'endOfDayTimeMinutes': serializer.toJson<int>(endOfDayTimeMinutes),
      'quietHoursStartMinutes': serializer.toJson<int?>(quietHoursStartMinutes),
      'quietHoursEndMinutes': serializer.toJson<int?>(quietHoursEndMinutes),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'vibrationEnabled': serializer.toJson<bool>(vibrationEnabled),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  ReminderPreferenceRecord copyWith({
    String? profileId,
    bool? enabled,
    int? morningTimeMinutes,
    int? middayTimeMinutes,
    int? endOfDayTimeMinutes,
    Value<int?> quietHoursStartMinutes = const Value.absent(),
    Value<int?> quietHoursEndMinutes = const Value.absent(),
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? updatedAtUtc,
  }) => ReminderPreferenceRecord(
    profileId: profileId ?? this.profileId,
    enabled: enabled ?? this.enabled,
    morningTimeMinutes: morningTimeMinutes ?? this.morningTimeMinutes,
    middayTimeMinutes: middayTimeMinutes ?? this.middayTimeMinutes,
    endOfDayTimeMinutes: endOfDayTimeMinutes ?? this.endOfDayTimeMinutes,
    quietHoursStartMinutes: quietHoursStartMinutes.present
        ? quietHoursStartMinutes.value
        : this.quietHoursStartMinutes,
    quietHoursEndMinutes: quietHoursEndMinutes.present
        ? quietHoursEndMinutes.value
        : this.quietHoursEndMinutes,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ReminderPreferenceRecord copyWithCompanion(
    ReminderPreferencesCompanion data,
  ) {
    return ReminderPreferenceRecord(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      morningTimeMinutes: data.morningTimeMinutes.present
          ? data.morningTimeMinutes.value
          : this.morningTimeMinutes,
      middayTimeMinutes: data.middayTimeMinutes.present
          ? data.middayTimeMinutes.value
          : this.middayTimeMinutes,
      endOfDayTimeMinutes: data.endOfDayTimeMinutes.present
          ? data.endOfDayTimeMinutes.value
          : this.endOfDayTimeMinutes,
      quietHoursStartMinutes: data.quietHoursStartMinutes.present
          ? data.quietHoursStartMinutes.value
          : this.quietHoursStartMinutes,
      quietHoursEndMinutes: data.quietHoursEndMinutes.present
          ? data.quietHoursEndMinutes.value
          : this.quietHoursEndMinutes,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      vibrationEnabled: data.vibrationEnabled.present
          ? data.vibrationEnabled.value
          : this.vibrationEnabled,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreferenceRecord(')
          ..write('profileId: $profileId, ')
          ..write('enabled: $enabled, ')
          ..write('morningTimeMinutes: $morningTimeMinutes, ')
          ..write('middayTimeMinutes: $middayTimeMinutes, ')
          ..write('endOfDayTimeMinutes: $endOfDayTimeMinutes, ')
          ..write('quietHoursStartMinutes: $quietHoursStartMinutes, ')
          ..write('quietHoursEndMinutes: $quietHoursEndMinutes, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    enabled,
    morningTimeMinutes,
    middayTimeMinutes,
    endOfDayTimeMinutes,
    quietHoursStartMinutes,
    quietHoursEndMinutes,
    soundEnabled,
    vibrationEnabled,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderPreferenceRecord &&
          other.profileId == this.profileId &&
          other.enabled == this.enabled &&
          other.morningTimeMinutes == this.morningTimeMinutes &&
          other.middayTimeMinutes == this.middayTimeMinutes &&
          other.endOfDayTimeMinutes == this.endOfDayTimeMinutes &&
          other.quietHoursStartMinutes == this.quietHoursStartMinutes &&
          other.quietHoursEndMinutes == this.quietHoursEndMinutes &&
          other.soundEnabled == this.soundEnabled &&
          other.vibrationEnabled == this.vibrationEnabled &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ReminderPreferencesCompanion
    extends UpdateCompanion<ReminderPreferenceRecord> {
  final Value<String> profileId;
  final Value<bool> enabled;
  final Value<int> morningTimeMinutes;
  final Value<int> middayTimeMinutes;
  final Value<int> endOfDayTimeMinutes;
  final Value<int?> quietHoursStartMinutes;
  final Value<int?> quietHoursEndMinutes;
  final Value<bool> soundEnabled;
  final Value<bool> vibrationEnabled;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const ReminderPreferencesCompanion({
    this.profileId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.morningTimeMinutes = const Value.absent(),
    this.middayTimeMinutes = const Value.absent(),
    this.endOfDayTimeMinutes = const Value.absent(),
    this.quietHoursStartMinutes = const Value.absent(),
    this.quietHoursEndMinutes = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderPreferencesCompanion.insert({
    required String profileId,
    this.enabled = const Value.absent(),
    required int morningTimeMinutes,
    required int middayTimeMinutes,
    required int endOfDayTimeMinutes,
    this.quietHoursStartMinutes = const Value.absent(),
    this.quietHoursEndMinutes = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       morningTimeMinutes = Value(morningTimeMinutes),
       middayTimeMinutes = Value(middayTimeMinutes),
       endOfDayTimeMinutes = Value(endOfDayTimeMinutes),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ReminderPreferenceRecord> custom({
    Expression<String>? profileId,
    Expression<bool>? enabled,
    Expression<int>? morningTimeMinutes,
    Expression<int>? middayTimeMinutes,
    Expression<int>? endOfDayTimeMinutes,
    Expression<int>? quietHoursStartMinutes,
    Expression<int>? quietHoursEndMinutes,
    Expression<bool>? soundEnabled,
    Expression<bool>? vibrationEnabled,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (enabled != null) 'enabled': enabled,
      if (morningTimeMinutes != null)
        'morning_time_minutes': morningTimeMinutes,
      if (middayTimeMinutes != null) 'midday_time_minutes': middayTimeMinutes,
      if (endOfDayTimeMinutes != null)
        'end_of_day_time_minutes': endOfDayTimeMinutes,
      if (quietHoursStartMinutes != null)
        'quiet_hours_start_minutes': quietHoursStartMinutes,
      if (quietHoursEndMinutes != null)
        'quiet_hours_end_minutes': quietHoursEndMinutes,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (vibrationEnabled != null) 'vibration_enabled': vibrationEnabled,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderPreferencesCompanion copyWith({
    Value<String>? profileId,
    Value<bool>? enabled,
    Value<int>? morningTimeMinutes,
    Value<int>? middayTimeMinutes,
    Value<int>? endOfDayTimeMinutes,
    Value<int?>? quietHoursStartMinutes,
    Value<int?>? quietHoursEndMinutes,
    Value<bool>? soundEnabled,
    Value<bool>? vibrationEnabled,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return ReminderPreferencesCompanion(
      profileId: profileId ?? this.profileId,
      enabled: enabled ?? this.enabled,
      morningTimeMinutes: morningTimeMinutes ?? this.morningTimeMinutes,
      middayTimeMinutes: middayTimeMinutes ?? this.middayTimeMinutes,
      endOfDayTimeMinutes: endOfDayTimeMinutes ?? this.endOfDayTimeMinutes,
      quietHoursStartMinutes:
          quietHoursStartMinutes ?? this.quietHoursStartMinutes,
      quietHoursEndMinutes: quietHoursEndMinutes ?? this.quietHoursEndMinutes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (morningTimeMinutes.present) {
      map['morning_time_minutes'] = Variable<int>(morningTimeMinutes.value);
    }
    if (middayTimeMinutes.present) {
      map['midday_time_minutes'] = Variable<int>(middayTimeMinutes.value);
    }
    if (endOfDayTimeMinutes.present) {
      map['end_of_day_time_minutes'] = Variable<int>(endOfDayTimeMinutes.value);
    }
    if (quietHoursStartMinutes.present) {
      map['quiet_hours_start_minutes'] = Variable<int>(
        quietHoursStartMinutes.value,
      );
    }
    if (quietHoursEndMinutes.present) {
      map['quiet_hours_end_minutes'] = Variable<int>(
        quietHoursEndMinutes.value,
      );
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (vibrationEnabled.present) {
      map['vibration_enabled'] = Variable<bool>(vibrationEnabled.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreferencesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('enabled: $enabled, ')
          ..write('morningTimeMinutes: $morningTimeMinutes, ')
          ..write('middayTimeMinutes: $middayTimeMinutes, ')
          ..write('endOfDayTimeMinutes: $endOfDayTimeMinutes, ')
          ..write('quietHoursStartMinutes: $quietHoursStartMinutes, ')
          ..write('quietHoursEndMinutes: $quietHoursEndMinutes, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledReminderRequestsTable extends ScheduledReminderRequests
    with
        TableInfo<
          $ScheduledReminderRequestsTable,
          ScheduledReminderRequestRecord
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledReminderRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _identityMeta = const VerificationMeta(
    'identity',
  );
  @override
  late final GeneratedColumn<String> identity = GeneratedColumn<String>(
    'identity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentKindMeta = const VerificationMeta(
    'contentKind',
  );
  @override
  late final GeneratedColumn<String> contentKind = GeneratedColumn<String>(
    'content_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _istDateMeta = const VerificationMeta(
    'istDate',
  );
  @override
  late final GeneratedColumn<String> istDate = GeneratedColumn<String>(
    'ist_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configuredTimeMinutesMeta =
      const VerificationMeta('configuredTimeMinutes');
  @override
  late final GeneratedColumn<int> configuredTimeMinutes = GeneratedColumn<int>(
    'configured_time_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtUtcMeta = const VerificationMeta(
    'scheduledAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAtUtc =
      GeneratedColumn<DateTime>(
        'scheduled_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    identity,
    notificationId,
    profileId,
    slot,
    contentKind,
    istDate,
    configuredTimeMinutes,
    scheduledAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_reminder_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduledReminderRequestRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('identity')) {
      context.handle(
        _identityMeta,
        identity.isAcceptableOrUnknown(data['identity']!, _identityMeta),
      );
    } else if (isInserting) {
      context.missing(_identityMeta);
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('content_kind')) {
      context.handle(
        _contentKindMeta,
        contentKind.isAcceptableOrUnknown(
          data['content_kind']!,
          _contentKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentKindMeta);
    }
    if (data.containsKey('ist_date')) {
      context.handle(
        _istDateMeta,
        istDate.isAcceptableOrUnknown(data['ist_date']!, _istDateMeta),
      );
    } else if (isInserting) {
      context.missing(_istDateMeta);
    }
    if (data.containsKey('configured_time_minutes')) {
      context.handle(
        _configuredTimeMinutesMeta,
        configuredTimeMinutes.isAcceptableOrUnknown(
          data['configured_time_minutes']!,
          _configuredTimeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configuredTimeMinutesMeta);
    }
    if (data.containsKey('scheduled_at_utc')) {
      context.handle(
        _scheduledAtUtcMeta,
        scheduledAtUtc.isAcceptableOrUnknown(
          data['scheduled_at_utc']!,
          _scheduledAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {identity};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {notificationId},
  ];
  @override
  ScheduledReminderRequestRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledReminderRequestRecord(
      identity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
      contentKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_kind'],
      )!,
      istDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ist_date'],
      )!,
      configuredTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}configured_time_minutes'],
      )!,
      scheduledAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ScheduledReminderRequestsTable createAlias(String alias) {
    return $ScheduledReminderRequestsTable(attachedDatabase, alias);
  }
}

class ScheduledReminderRequestRecord extends DataClass
    implements Insertable<ScheduledReminderRequestRecord> {
  /// Logical identity is stable across retries and content changes.
  final String identity;
  final int notificationId;
  final String profileId;
  final String slot;
  final String contentKind;
  final String istDate;
  final int configuredTimeMinutes;
  final DateTime scheduledAtUtc;
  final DateTime updatedAtUtc;
  const ScheduledReminderRequestRecord({
    required this.identity,
    required this.notificationId,
    required this.profileId,
    required this.slot,
    required this.contentKind,
    required this.istDate,
    required this.configuredTimeMinutes,
    required this.scheduledAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['identity'] = Variable<String>(identity);
    map['notification_id'] = Variable<int>(notificationId);
    map['profile_id'] = Variable<String>(profileId);
    map['slot'] = Variable<String>(slot);
    map['content_kind'] = Variable<String>(contentKind);
    map['ist_date'] = Variable<String>(istDate);
    map['configured_time_minutes'] = Variable<int>(configuredTimeMinutes);
    map['scheduled_at_utc'] = Variable<DateTime>(scheduledAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  ScheduledReminderRequestsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledReminderRequestsCompanion(
      identity: Value(identity),
      notificationId: Value(notificationId),
      profileId: Value(profileId),
      slot: Value(slot),
      contentKind: Value(contentKind),
      istDate: Value(istDate),
      configuredTimeMinutes: Value(configuredTimeMinutes),
      scheduledAtUtc: Value(scheduledAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ScheduledReminderRequestRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledReminderRequestRecord(
      identity: serializer.fromJson<String>(json['identity']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      slot: serializer.fromJson<String>(json['slot']),
      contentKind: serializer.fromJson<String>(json['contentKind']),
      istDate: serializer.fromJson<String>(json['istDate']),
      configuredTimeMinutes: serializer.fromJson<int>(
        json['configuredTimeMinutes'],
      ),
      scheduledAtUtc: serializer.fromJson<DateTime>(json['scheduledAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'identity': serializer.toJson<String>(identity),
      'notificationId': serializer.toJson<int>(notificationId),
      'profileId': serializer.toJson<String>(profileId),
      'slot': serializer.toJson<String>(slot),
      'contentKind': serializer.toJson<String>(contentKind),
      'istDate': serializer.toJson<String>(istDate),
      'configuredTimeMinutes': serializer.toJson<int>(configuredTimeMinutes),
      'scheduledAtUtc': serializer.toJson<DateTime>(scheduledAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  ScheduledReminderRequestRecord copyWith({
    String? identity,
    int? notificationId,
    String? profileId,
    String? slot,
    String? contentKind,
    String? istDate,
    int? configuredTimeMinutes,
    DateTime? scheduledAtUtc,
    DateTime? updatedAtUtc,
  }) => ScheduledReminderRequestRecord(
    identity: identity ?? this.identity,
    notificationId: notificationId ?? this.notificationId,
    profileId: profileId ?? this.profileId,
    slot: slot ?? this.slot,
    contentKind: contentKind ?? this.contentKind,
    istDate: istDate ?? this.istDate,
    configuredTimeMinutes: configuredTimeMinutes ?? this.configuredTimeMinutes,
    scheduledAtUtc: scheduledAtUtc ?? this.scheduledAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ScheduledReminderRequestRecord copyWithCompanion(
    ScheduledReminderRequestsCompanion data,
  ) {
    return ScheduledReminderRequestRecord(
      identity: data.identity.present ? data.identity.value : this.identity,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      slot: data.slot.present ? data.slot.value : this.slot,
      contentKind: data.contentKind.present
          ? data.contentKind.value
          : this.contentKind,
      istDate: data.istDate.present ? data.istDate.value : this.istDate,
      configuredTimeMinutes: data.configuredTimeMinutes.present
          ? data.configuredTimeMinutes.value
          : this.configuredTimeMinutes,
      scheduledAtUtc: data.scheduledAtUtc.present
          ? data.scheduledAtUtc.value
          : this.scheduledAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledReminderRequestRecord(')
          ..write('identity: $identity, ')
          ..write('notificationId: $notificationId, ')
          ..write('profileId: $profileId, ')
          ..write('slot: $slot, ')
          ..write('contentKind: $contentKind, ')
          ..write('istDate: $istDate, ')
          ..write('configuredTimeMinutes: $configuredTimeMinutes, ')
          ..write('scheduledAtUtc: $scheduledAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    identity,
    notificationId,
    profileId,
    slot,
    contentKind,
    istDate,
    configuredTimeMinutes,
    scheduledAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledReminderRequestRecord &&
          other.identity == this.identity &&
          other.notificationId == this.notificationId &&
          other.profileId == this.profileId &&
          other.slot == this.slot &&
          other.contentKind == this.contentKind &&
          other.istDate == this.istDate &&
          other.configuredTimeMinutes == this.configuredTimeMinutes &&
          other.scheduledAtUtc == this.scheduledAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ScheduledReminderRequestsCompanion
    extends UpdateCompanion<ScheduledReminderRequestRecord> {
  final Value<String> identity;
  final Value<int> notificationId;
  final Value<String> profileId;
  final Value<String> slot;
  final Value<String> contentKind;
  final Value<String> istDate;
  final Value<int> configuredTimeMinutes;
  final Value<DateTime> scheduledAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const ScheduledReminderRequestsCompanion({
    this.identity = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.slot = const Value.absent(),
    this.contentKind = const Value.absent(),
    this.istDate = const Value.absent(),
    this.configuredTimeMinutes = const Value.absent(),
    this.scheduledAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduledReminderRequestsCompanion.insert({
    required String identity,
    required int notificationId,
    required String profileId,
    required String slot,
    required String contentKind,
    required String istDate,
    required int configuredTimeMinutes,
    required DateTime scheduledAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : identity = Value(identity),
       notificationId = Value(notificationId),
       profileId = Value(profileId),
       slot = Value(slot),
       contentKind = Value(contentKind),
       istDate = Value(istDate),
       configuredTimeMinutes = Value(configuredTimeMinutes),
       scheduledAtUtc = Value(scheduledAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ScheduledReminderRequestRecord> custom({
    Expression<String>? identity,
    Expression<int>? notificationId,
    Expression<String>? profileId,
    Expression<String>? slot,
    Expression<String>? contentKind,
    Expression<String>? istDate,
    Expression<int>? configuredTimeMinutes,
    Expression<DateTime>? scheduledAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (identity != null) 'identity': identity,
      if (notificationId != null) 'notification_id': notificationId,
      if (profileId != null) 'profile_id': profileId,
      if (slot != null) 'slot': slot,
      if (contentKind != null) 'content_kind': contentKind,
      if (istDate != null) 'ist_date': istDate,
      if (configuredTimeMinutes != null)
        'configured_time_minutes': configuredTimeMinutes,
      if (scheduledAtUtc != null) 'scheduled_at_utc': scheduledAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduledReminderRequestsCompanion copyWith({
    Value<String>? identity,
    Value<int>? notificationId,
    Value<String>? profileId,
    Value<String>? slot,
    Value<String>? contentKind,
    Value<String>? istDate,
    Value<int>? configuredTimeMinutes,
    Value<DateTime>? scheduledAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return ScheduledReminderRequestsCompanion(
      identity: identity ?? this.identity,
      notificationId: notificationId ?? this.notificationId,
      profileId: profileId ?? this.profileId,
      slot: slot ?? this.slot,
      contentKind: contentKind ?? this.contentKind,
      istDate: istDate ?? this.istDate,
      configuredTimeMinutes:
          configuredTimeMinutes ?? this.configuredTimeMinutes,
      scheduledAtUtc: scheduledAtUtc ?? this.scheduledAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (identity.present) {
      map['identity'] = Variable<String>(identity.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (contentKind.present) {
      map['content_kind'] = Variable<String>(contentKind.value);
    }
    if (istDate.present) {
      map['ist_date'] = Variable<String>(istDate.value);
    }
    if (configuredTimeMinutes.present) {
      map['configured_time_minutes'] = Variable<int>(
        configuredTimeMinutes.value,
      );
    }
    if (scheduledAtUtc.present) {
      map['scheduled_at_utc'] = Variable<DateTime>(scheduledAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledReminderRequestsCompanion(')
          ..write('identity: $identity, ')
          ..write('notificationId: $notificationId, ')
          ..write('profileId: $profileId, ')
          ..write('slot: $slot, ')
          ..write('contentKind: $contentKind, ')
          ..write('istDate: $istDate, ')
          ..write('configuredTimeMinutes: $configuredTimeMinutes, ')
          ..write('scheduledAtUtc: $scheduledAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $LocalTasksTable localTasks = $LocalTasksTable(this);
  late final $LocalProgressEntriesTable localProgressEntries =
      $LocalProgressEntriesTable(this);
  late final $LocalLifecycleEventsTable localLifecycleEvents =
      $LocalLifecycleEventsTable(this);
  late final $ReminderPreferencesTable reminderPreferences =
      $ReminderPreferencesTable(this);
  late final $ScheduledReminderRequestsTable scheduledReminderRequests =
      $ScheduledReminderRequestsTable(this);
  late final Index localTasksProfileStartStatusIdx = Index(
    'local_tasks_profile_start_status_idx',
    'CREATE INDEX local_tasks_profile_start_status_idx ON local_tasks (profile_id, start_date, status)',
  );
  late final Index localProgressProfileTaskTimeIdx = Index(
    'local_progress_profile_task_time_idx',
    'CREATE INDEX local_progress_profile_task_time_idx ON local_progress_entries (profile_id, task_id, occurred_at_utc)',
  );
  late final Index localLifecycleProfileTaskTimeIdx = Index(
    'local_lifecycle_profile_task_time_idx',
    'CREATE INDEX local_lifecycle_profile_task_time_idx ON local_lifecycle_events (profile_id, task_id, occurred_at_utc)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localProfiles,
    localTasks,
    localProgressEntries,
    localLifecycleEvents,
    reminderPreferences,
    scheduledReminderRequests,
    localTasksProfileStartStatusIdx,
    localProgressProfileTaskTimeIdx,
    localLifecycleProfileTaskTimeIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_progress_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_lifecycle_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminder_preferences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('scheduled_reminder_requests', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$LocalProfilesTableCreateCompanionBuilder =
    LocalProfilesCompanion Function({
      required String id,
      Value<String> profileType,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$LocalProfilesTableUpdateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<String> id,
      Value<String> profileType,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

final class $$LocalProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $LocalProfilesTable, ProfileRecord> {
  $$LocalProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LocalTasksTable, List<TaskRecord>>
  _localTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localTasks,
    aliasName: 'local_profiles__id__local_tasks__profile_id',
  );

  $$LocalTasksTableProcessedTableManager get localTasksRefs {
    final manager = $$LocalTasksTableTableManager(
      $_db,
      $_db.localTasks,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LocalProgressEntriesTable,
    List<ProgressEntryRecord>
  >
  _localProgressEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localProgressEntries,
        aliasName: 'local_profiles__id__local_progress_entries__profile_id',
      );

  $$LocalProgressEntriesTableProcessedTableManager
  get localProgressEntriesRefs {
    final manager = $$LocalProgressEntriesTableTableManager(
      $_db,
      $_db.localProgressEntries,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localProgressEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $LocalLifecycleEventsTable,
    List<LifecycleEventRecord>
  >
  _localLifecycleEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localLifecycleEvents,
        aliasName: 'local_profiles__id__local_lifecycle_events__profile_id',
      );

  $$LocalLifecycleEventsTableProcessedTableManager
  get localLifecycleEventsRefs {
    final manager = $$LocalLifecycleEventsTableTableManager(
      $_db,
      $_db.localLifecycleEvents,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localLifecycleEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ReminderPreferencesTable,
    List<ReminderPreferenceRecord>
  >
  _reminderPreferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reminderPreferences,
        aliasName: 'local_profiles__id__reminder_preferences__profile_id',
      );

  $$ReminderPreferencesTableProcessedTableManager get reminderPreferencesRefs {
    final manager = $$ReminderPreferencesTableTableManager(
      $_db,
      $_db.reminderPreferences,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reminderPreferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ScheduledReminderRequestsTable,
    List<ScheduledReminderRequestRecord>
  >
  _scheduledReminderRequestsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduledReminderRequests,
        aliasName:
            'local_profiles__id__scheduled_reminder_requests__profile_id',
      );

  $$ScheduledReminderRequestsTableProcessedTableManager
  get scheduledReminderRequestsRefs {
    final manager = $$ScheduledReminderRequestsTableTableManager(
      $_db,
      $_db.scheduledReminderRequests,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduledReminderRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localTasksRefs(
    Expression<bool> Function($$LocalTasksTableFilterComposer f) f,
  ) {
    final $$LocalTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localTasks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalTasksTableFilterComposer(
            $db: $db,
            $table: $db.localTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localProgressEntriesRefs(
    Expression<bool> Function($$LocalProgressEntriesTableFilterComposer f) f,
  ) {
    final $$LocalProgressEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localProgressEntries,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProgressEntriesTableFilterComposer(
            $db: $db,
            $table: $db.localProgressEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> localLifecycleEventsRefs(
    Expression<bool> Function($$LocalLifecycleEventsTableFilterComposer f) f,
  ) {
    final $$LocalLifecycleEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localLifecycleEvents,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalLifecycleEventsTableFilterComposer(
            $db: $db,
            $table: $db.localLifecycleEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reminderPreferencesRefs(
    Expression<bool> Function($$ReminderPreferencesTableFilterComposer f) f,
  ) {
    final $$ReminderPreferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderPreferences,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderPreferencesTableFilterComposer(
            $db: $db,
            $table: $db.reminderPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scheduledReminderRequestsRefs(
    Expression<bool> Function($$ScheduledReminderRequestsTableFilterComposer f)
    f,
  ) {
    final $$ScheduledReminderRequestsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduledReminderRequests,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduledReminderRequestsTableFilterComposer(
                $db: $db,
                $table: $db.scheduledReminderRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  Expression<T> localTasksRefs<T extends Object>(
    Expression<T> Function($$LocalTasksTableAnnotationComposer a) f,
  ) {
    final $$LocalTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localTasks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.localTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> localProgressEntriesRefs<T extends Object>(
    Expression<T> Function($$LocalProgressEntriesTableAnnotationComposer a) f,
  ) {
    final $$LocalProgressEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localProgressEntries,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalProgressEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.localProgressEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localLifecycleEventsRefs<T extends Object>(
    Expression<T> Function($$LocalLifecycleEventsTableAnnotationComposer a) f,
  ) {
    final $$LocalLifecycleEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localLifecycleEvents,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalLifecycleEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.localLifecycleEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> reminderPreferencesRefs<T extends Object>(
    Expression<T> Function($$ReminderPreferencesTableAnnotationComposer a) f,
  ) {
    final $$ReminderPreferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderPreferences,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderPreferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.reminderPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> scheduledReminderRequestsRefs<T extends Object>(
    Expression<T> Function($$ScheduledReminderRequestsTableAnnotationComposer a)
    f,
  ) {
    final $$ScheduledReminderRequestsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduledReminderRequests,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduledReminderRequestsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduledReminderRequests,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LocalProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProfilesTable,
          ProfileRecord,
          $$LocalProfilesTableFilterComposer,
          $$LocalProfilesTableOrderingComposer,
          $$LocalProfilesTableAnnotationComposer,
          $$LocalProfilesTableCreateCompanionBuilder,
          $$LocalProfilesTableUpdateCompanionBuilder,
          (ProfileRecord, $$LocalProfilesTableReferences),
          ProfileRecord,
          PrefetchHooks Function({
            bool localTasksRefs,
            bool localProgressEntriesRefs,
            bool localLifecycleEventsRefs,
            bool reminderPreferencesRefs,
            bool scheduledReminderRequestsRefs,
          })
        > {
  $$LocalProfilesTableTableManager(_$AppDatabase db, $LocalProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileType = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion(
                id: id,
                profileType: profileType,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> profileType = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion.insert(
                id: id,
                profileType: profileType,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalProfilesTable, ProfileRecord>(table),
                  $$LocalProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                localTasksRefs = false,
                localProgressEntriesRefs = false,
                localLifecycleEventsRefs = false,
                reminderPreferencesRefs = false,
                scheduledReminderRequestsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localTasksRefs) db.localTasks,
                    if (localProgressEntriesRefs) db.localProgressEntries,
                    if (localLifecycleEventsRefs) db.localLifecycleEvents,
                    if (reminderPreferencesRefs) db.reminderPreferences,
                    if (scheduledReminderRequestsRefs)
                      db.scheduledReminderRequests,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localTasksRefs)
                        await $_getPrefetchedData<
                          ProfileRecord,
                          $LocalProfilesTable,
                          TaskRecord
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._localTasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).localTasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localProgressEntriesRefs)
                        await $_getPrefetchedData<
                          ProfileRecord,
                          $LocalProfilesTable,
                          ProgressEntryRecord
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._localProgressEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).localProgressEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localLifecycleEventsRefs)
                        await $_getPrefetchedData<
                          ProfileRecord,
                          $LocalProfilesTable,
                          LifecycleEventRecord
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._localLifecycleEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).localLifecycleEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reminderPreferencesRefs)
                        await $_getPrefetchedData<
                          ProfileRecord,
                          $LocalProfilesTable,
                          ReminderPreferenceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._reminderPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scheduledReminderRequestsRefs)
                        await $_getPrefetchedData<
                          ProfileRecord,
                          $LocalProfilesTable,
                          ScheduledReminderRequestRecord
                        >(
                          currentTable: table,
                          referencedTable: $$LocalProfilesTableReferences
                              ._scheduledReminderRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduledReminderRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProfilesTable,
      ProfileRecord,
      $$LocalProfilesTableFilterComposer,
      $$LocalProfilesTableOrderingComposer,
      $$LocalProfilesTableAnnotationComposer,
      $$LocalProfilesTableCreateCompanionBuilder,
      $$LocalProfilesTableUpdateCompanionBuilder,
      (ProfileRecord, $$LocalProfilesTableReferences),
      ProfileRecord,
      PrefetchHooks Function({
        bool localTasksRefs,
        bool localProgressEntriesRefs,
        bool localLifecycleEventsRefs,
        bool reminderPreferencesRefs,
        bool scheduledReminderRequestsRefs,
      })
    >;
typedef $$LocalTasksTableCreateCompanionBuilder = LocalTasksCompanion Function({
  required String id,
  required String profileId,
  required String topic,
  Value<String?> subtopic,
  Value<String?> description,
  required String startDate,
  required String plannedEndDate,
  Value<String?> maximumEndDate,
  required int effortHundredths,
  Value<String> status,
  Value<DateTime?> completedAtUtc,
  required DateTime createdAtUtc,
  required DateTime updatedAtUtc,
  Value<int> rowid,
});
typedef $$LocalTasksTableUpdateCompanionBuilder = LocalTasksCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> topic,
  Value<String?> subtopic,
  Value<String?> description,
  Value<String> startDate,
  Value<String> plannedEndDate,
  Value<String?> maximumEndDate,
  Value<int> effortHundredths,
  Value<String> status,
  Value<DateTime?> completedAtUtc,
  Value<DateTime> createdAtUtc,
  Value<DateTime> updatedAtUtc,
  Value<int> rowid,
});

final class $$LocalTasksTableReferences
    extends BaseReferences<_$AppDatabase, $LocalTasksTable, TaskRecord> {
  $$LocalTasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalProfilesTable _profileIdTable(_$AppDatabase db) => db
      .localProfiles
      .createAlias('local_tasks__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalTasksTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtopic => $composableBuilder(
    column: $table.subtopic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedEndDate => $composableBuilder(
    column: $table.plannedEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maximumEndDate => $composableBuilder(
    column: $table.maximumEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effortHundredths => $composableBuilder(
    column: $table.effortHundredths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtopic => $composableBuilder(
    column: $table.subtopic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedEndDate => $composableBuilder(
    column: $table.plannedEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maximumEndDate => $composableBuilder(
    column: $table.maximumEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effortHundredths => $composableBuilder(
    column: $table.effortHundredths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTasksTable> {
  $$LocalTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get subtopic =>
      $composableBuilder(column: $table.subtopic, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get plannedEndDate => $composableBuilder(
    column: $table.plannedEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maximumEndDate => $composableBuilder(
    column: $table.maximumEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effortHundredths => $composableBuilder(
    column: $table.effortHundredths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTasksTable,
          TaskRecord,
          $$LocalTasksTableFilterComposer,
          $$LocalTasksTableOrderingComposer,
          $$LocalTasksTableAnnotationComposer,
          $$LocalTasksTableCreateCompanionBuilder,
          $$LocalTasksTableUpdateCompanionBuilder,
          (TaskRecord, $$LocalTasksTableReferences),
          TaskRecord,
          PrefetchHooks Function({bool profileId})
        > {
  $$LocalTasksTableTableManager(_$AppDatabase db, $LocalTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String?> subtopic = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> plannedEndDate = const Value.absent(),
                Value<String?> maximumEndDate = const Value.absent(),
                Value<int> effortHundredths = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTasksCompanion(
                id: id,
                profileId: profileId,
                topic: topic,
                subtopic: subtopic,
                description: description,
                startDate: startDate,
                plannedEndDate: plannedEndDate,
                maximumEndDate: maximumEndDate,
                effortHundredths: effortHundredths,
                status: status,
                completedAtUtc: completedAtUtc,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String topic,
                Value<String?> subtopic = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String startDate,
                required String plannedEndDate,
                Value<String?> maximumEndDate = const Value.absent(),
                required int effortHundredths,
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => LocalTasksCompanion.insert(
                id: id,
                profileId: profileId,
                topic: topic,
                subtopic: subtopic,
                description: description,
                startDate: startDate,
                plannedEndDate: plannedEndDate,
                maximumEndDate: maximumEndDate,
                effortHundredths: effortHundredths,
                status: status,
                completedAtUtc: completedAtUtc,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalTasksTable, TaskRecord>(table),
                  $$LocalTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$LocalTasksTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$LocalTasksTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTasksTable,
      TaskRecord,
      $$LocalTasksTableFilterComposer,
      $$LocalTasksTableOrderingComposer,
      $$LocalTasksTableAnnotationComposer,
      $$LocalTasksTableCreateCompanionBuilder,
      $$LocalTasksTableUpdateCompanionBuilder,
      (TaskRecord, $$LocalTasksTableReferences),
      TaskRecord,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$LocalProgressEntriesTableCreateCompanionBuilder =
    LocalProgressEntriesCompanion Function({
      required String id,
      required String profileId,
      required String taskId,
      required String method,
      Value<int?> percentComplete,
      Value<int?> completedUnits,
      Value<int?> totalUnits,
      Value<String?> note,
      required DateTime occurredAtUtc,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$LocalProgressEntriesTableUpdateCompanionBuilder =
    LocalProgressEntriesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> taskId,
      Value<String> method,
      Value<int?> percentComplete,
      Value<int?> completedUnits,
      Value<int?> totalUnits,
      Value<String?> note,
      Value<DateTime> occurredAtUtc,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

final class $$LocalProgressEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalProgressEntriesTable,
          ProgressEntryRecord
        > {
  $$LocalProgressEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalProfilesTable _profileIdTable(_$AppDatabase db) => db
      .localProfiles
      .createAlias('local_progress_entries__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProgressEntriesTable> {
  $$LocalProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get percentComplete => $composableBuilder(
    column: $table.percentComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedUnits => $composableBuilder(
    column: $table.completedUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalUnits => $composableBuilder(
    column: $table.totalUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProgressEntriesTable> {
  $$LocalProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percentComplete => $composableBuilder(
    column: $table.percentComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedUnits => $composableBuilder(
    column: $table.completedUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalUnits => $composableBuilder(
    column: $table.totalUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProgressEntriesTable> {
  $$LocalProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get percentComplete => $composableBuilder(
    column: $table.percentComplete,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedUnits => $composableBuilder(
    column: $table.completedUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalUnits => $composableBuilder(
    column: $table.totalUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProgressEntriesTable,
          ProgressEntryRecord,
          $$LocalProgressEntriesTableFilterComposer,
          $$LocalProgressEntriesTableOrderingComposer,
          $$LocalProgressEntriesTableAnnotationComposer,
          $$LocalProgressEntriesTableCreateCompanionBuilder,
          $$LocalProgressEntriesTableUpdateCompanionBuilder,
          (ProgressEntryRecord, $$LocalProgressEntriesTableReferences),
          ProgressEntryRecord,
          PrefetchHooks Function({bool profileId})
        > {
  $$LocalProgressEntriesTableTableManager(
    _$AppDatabase db,
    $LocalProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<int?> percentComplete = const Value.absent(),
                Value<int?> completedUnits = const Value.absent(),
                Value<int?> totalUnits = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProgressEntriesCompanion(
                id: id,
                profileId: profileId,
                taskId: taskId,
                method: method,
                percentComplete: percentComplete,
                completedUnits: completedUnits,
                totalUnits: totalUnits,
                note: note,
                occurredAtUtc: occurredAtUtc,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String taskId,
                required String method,
                Value<int?> percentComplete = const Value.absent(),
                Value<int?> completedUnits = const Value.absent(),
                Value<int?> totalUnits = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime occurredAtUtc,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => LocalProgressEntriesCompanion.insert(
                id: id,
                profileId: profileId,
                taskId: taskId,
                method: method,
                percentComplete: percentComplete,
                completedUnits: completedUnits,
                totalUnits: totalUnits,
                note: note,
                occurredAtUtc: occurredAtUtc,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalProgressEntriesTable, ProgressEntryRecord>(
                    table,
                  ),
                  $$LocalProgressEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$LocalProgressEntriesTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$LocalProgressEntriesTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProgressEntriesTable,
      ProgressEntryRecord,
      $$LocalProgressEntriesTableFilterComposer,
      $$LocalProgressEntriesTableOrderingComposer,
      $$LocalProgressEntriesTableAnnotationComposer,
      $$LocalProgressEntriesTableCreateCompanionBuilder,
      $$LocalProgressEntriesTableUpdateCompanionBuilder,
      (ProgressEntryRecord, $$LocalProgressEntriesTableReferences),
      ProgressEntryRecord,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$LocalLifecycleEventsTableCreateCompanionBuilder =
    LocalLifecycleEventsCompanion Function({
      required String id,
      required String profileId,
      required String taskId,
      required String eventType,
      required DateTime occurredAtUtc,
      Value<int> rowid,
    });
typedef $$LocalLifecycleEventsTableUpdateCompanionBuilder =
    LocalLifecycleEventsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> taskId,
      Value<String> eventType,
      Value<DateTime> occurredAtUtc,
      Value<int> rowid,
    });

final class $$LocalLifecycleEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LocalLifecycleEventsTable,
          LifecycleEventRecord
        > {
  $$LocalLifecycleEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalProfilesTable _profileIdTable(_$AppDatabase db) => db
      .localProfiles
      .createAlias('local_lifecycle_events__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalLifecycleEventsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLifecycleEventsTable> {
  $$LocalLifecycleEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalLifecycleEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLifecycleEventsTable> {
  $$LocalLifecycleEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalLifecycleEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLifecycleEventsTable> {
  $$LocalLifecycleEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalLifecycleEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLifecycleEventsTable,
          LifecycleEventRecord,
          $$LocalLifecycleEventsTableFilterComposer,
          $$LocalLifecycleEventsTableOrderingComposer,
          $$LocalLifecycleEventsTableAnnotationComposer,
          $$LocalLifecycleEventsTableCreateCompanionBuilder,
          $$LocalLifecycleEventsTableUpdateCompanionBuilder,
          (LifecycleEventRecord, $$LocalLifecycleEventsTableReferences),
          LifecycleEventRecord,
          PrefetchHooks Function({bool profileId})
        > {
  $$LocalLifecycleEventsTableTableManager(
    _$AppDatabase db,
    $LocalLifecycleEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLifecycleEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLifecycleEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalLifecycleEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLifecycleEventsCompanion(
                id: id,
                profileId: profileId,
                taskId: taskId,
                eventType: eventType,
                occurredAtUtc: occurredAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String taskId,
                required String eventType,
                required DateTime occurredAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => LocalLifecycleEventsCompanion.insert(
                id: id,
                profileId: profileId,
                taskId: taskId,
                eventType: eventType,
                occurredAtUtc: occurredAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalLifecycleEventsTable, LifecycleEventRecord>(
                    table,
                  ),
                  $$LocalLifecycleEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$LocalLifecycleEventsTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$LocalLifecycleEventsTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalLifecycleEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLifecycleEventsTable,
      LifecycleEventRecord,
      $$LocalLifecycleEventsTableFilterComposer,
      $$LocalLifecycleEventsTableOrderingComposer,
      $$LocalLifecycleEventsTableAnnotationComposer,
      $$LocalLifecycleEventsTableCreateCompanionBuilder,
      $$LocalLifecycleEventsTableUpdateCompanionBuilder,
      (LifecycleEventRecord, $$LocalLifecycleEventsTableReferences),
      LifecycleEventRecord,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ReminderPreferencesTableCreateCompanionBuilder =
    ReminderPreferencesCompanion Function({
      required String profileId,
      Value<bool> enabled,
      required int morningTimeMinutes,
      required int middayTimeMinutes,
      required int endOfDayTimeMinutes,
      Value<int?> quietHoursStartMinutes,
      Value<int?> quietHoursEndMinutes,
      Value<bool> soundEnabled,
      Value<bool> vibrationEnabled,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$ReminderPreferencesTableUpdateCompanionBuilder =
    ReminderPreferencesCompanion Function({
      Value<String> profileId,
      Value<bool> enabled,
      Value<int> morningTimeMinutes,
      Value<int> middayTimeMinutes,
      Value<int> endOfDayTimeMinutes,
      Value<int?> quietHoursStartMinutes,
      Value<int?> quietHoursEndMinutes,
      Value<bool> soundEnabled,
      Value<bool> vibrationEnabled,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

final class $$ReminderPreferencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReminderPreferencesTable,
          ReminderPreferenceRecord
        > {
  $$ReminderPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalProfilesTable _profileIdTable(_$AppDatabase db) => db
      .localProfiles
      .createAlias('reminder_preferences__profile_id__local_profiles__id');

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get morningTimeMinutes => $composableBuilder(
    column: $table.morningTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get middayTimeMinutes => $composableBuilder(
    column: $table.middayTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOfDayTimeMinutes => $composableBuilder(
    column: $table.endOfDayTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietHoursStartMinutes => $composableBuilder(
    column: $table.quietHoursStartMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietHoursEndMinutes => $composableBuilder(
    column: $table.quietHoursEndMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get morningTimeMinutes => $composableBuilder(
    column: $table.morningTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get middayTimeMinutes => $composableBuilder(
    column: $table.middayTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOfDayTimeMinutes => $composableBuilder(
    column: $table.endOfDayTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietHoursStartMinutes => $composableBuilder(
    column: $table.quietHoursStartMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietHoursEndMinutes => $composableBuilder(
    column: $table.quietHoursEndMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get morningTimeMinutes => $composableBuilder(
    column: $table.morningTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get middayTimeMinutes => $composableBuilder(
    column: $table.middayTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOfDayTimeMinutes => $composableBuilder(
    column: $table.endOfDayTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietHoursStartMinutes => $composableBuilder(
    column: $table.quietHoursStartMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietHoursEndMinutes => $composableBuilder(
    column: $table.quietHoursEndMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderPreferencesTable,
          ReminderPreferenceRecord,
          $$ReminderPreferencesTableFilterComposer,
          $$ReminderPreferencesTableOrderingComposer,
          $$ReminderPreferencesTableAnnotationComposer,
          $$ReminderPreferencesTableCreateCompanionBuilder,
          $$ReminderPreferencesTableUpdateCompanionBuilder,
          (ReminderPreferenceRecord, $$ReminderPreferencesTableReferences),
          ReminderPreferenceRecord,
          PrefetchHooks Function({bool profileId})
        > {
  $$ReminderPreferencesTableTableManager(
    _$AppDatabase db,
    $ReminderPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReminderPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> morningTimeMinutes = const Value.absent(),
                Value<int> middayTimeMinutes = const Value.absent(),
                Value<int> endOfDayTimeMinutes = const Value.absent(),
                Value<int?> quietHoursStartMinutes = const Value.absent(),
                Value<int?> quietHoursEndMinutes = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferencesCompanion(
                profileId: profileId,
                enabled: enabled,
                morningTimeMinutes: morningTimeMinutes,
                middayTimeMinutes: middayTimeMinutes,
                endOfDayTimeMinutes: endOfDayTimeMinutes,
                quietHoursStartMinutes: quietHoursStartMinutes,
                quietHoursEndMinutes: quietHoursEndMinutes,
                soundEnabled: soundEnabled,
                vibrationEnabled: vibrationEnabled,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                Value<bool> enabled = const Value.absent(),
                required int morningTimeMinutes,
                required int middayTimeMinutes,
                required int endOfDayTimeMinutes,
                Value<int?> quietHoursStartMinutes = const Value.absent(),
                Value<int?> quietHoursEndMinutes = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferencesCompanion.insert(
                profileId: profileId,
                enabled: enabled,
                morningTimeMinutes: morningTimeMinutes,
                middayTimeMinutes: middayTimeMinutes,
                endOfDayTimeMinutes: endOfDayTimeMinutes,
                quietHoursStartMinutes: quietHoursStartMinutes,
                quietHoursEndMinutes: quietHoursEndMinutes,
                soundEnabled: soundEnabled,
                vibrationEnabled: vibrationEnabled,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ReminderPreferencesTable,
                    ReminderPreferenceRecord
                  >(table),
                  $$ReminderPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $$ReminderPreferencesTableReferences
                            ._profileIdTable(db),
                        referencedColumn: $$ReminderPreferencesTableReferences
                            ._profileIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReminderPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderPreferencesTable,
      ReminderPreferenceRecord,
      $$ReminderPreferencesTableFilterComposer,
      $$ReminderPreferencesTableOrderingComposer,
      $$ReminderPreferencesTableAnnotationComposer,
      $$ReminderPreferencesTableCreateCompanionBuilder,
      $$ReminderPreferencesTableUpdateCompanionBuilder,
      (ReminderPreferenceRecord, $$ReminderPreferencesTableReferences),
      ReminderPreferenceRecord,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$ScheduledReminderRequestsTableCreateCompanionBuilder =
    ScheduledReminderRequestsCompanion Function({
      required String identity,
      required int notificationId,
      required String profileId,
      required String slot,
      required String contentKind,
      required String istDate,
      required int configuredTimeMinutes,
      required DateTime scheduledAtUtc,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$ScheduledReminderRequestsTableUpdateCompanionBuilder =
    ScheduledReminderRequestsCompanion Function({
      Value<String> identity,
      Value<int> notificationId,
      Value<String> profileId,
      Value<String> slot,
      Value<String> contentKind,
      Value<String> istDate,
      Value<int> configuredTimeMinutes,
      Value<DateTime> scheduledAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

final class $$ScheduledReminderRequestsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScheduledReminderRequestsTable,
          ScheduledReminderRequestRecord
        > {
  $$ScheduledReminderRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.localProfiles.createAlias(
        'scheduled_reminder_requests__profile_id__local_profiles__id',
      );

  $$LocalProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$LocalProfilesTableTableManager(
      $_db,
      $_db.localProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduledReminderRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledReminderRequestsTable> {
  $$ScheduledReminderRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get identity => $composableBuilder(
    column: $table.identity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentKind => $composableBuilder(
    column: $table.contentKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get istDate => $composableBuilder(
    column: $table.istDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get configuredTimeMinutes => $composableBuilder(
    column: $table.configuredTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAtUtc => $composableBuilder(
    column: $table.scheduledAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalProfilesTableFilterComposer get profileId {
    final $$LocalProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableFilterComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledReminderRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledReminderRequestsTable> {
  $$ScheduledReminderRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get identity => $composableBuilder(
    column: $table.identity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentKind => $composableBuilder(
    column: $table.contentKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get istDate => $composableBuilder(
    column: $table.istDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get configuredTimeMinutes => $composableBuilder(
    column: $table.configuredTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAtUtc => $composableBuilder(
    column: $table.scheduledAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalProfilesTableOrderingComposer get profileId {
    final $$LocalProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledReminderRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledReminderRequestsTable> {
  $$ScheduledReminderRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get identity =>
      $composableBuilder(column: $table.identity, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get contentKind => $composableBuilder(
    column: $table.contentKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get istDate =>
      $composableBuilder(column: $table.istDate, builder: (column) => column);

  GeneratedColumn<int> get configuredTimeMinutes => $composableBuilder(
    column: $table.configuredTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAtUtc => $composableBuilder(
    column: $table.scheduledAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$LocalProfilesTableAnnotationComposer get profileId {
    final $$LocalProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.localProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.localProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledReminderRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduledReminderRequestsTable,
          ScheduledReminderRequestRecord,
          $$ScheduledReminderRequestsTableFilterComposer,
          $$ScheduledReminderRequestsTableOrderingComposer,
          $$ScheduledReminderRequestsTableAnnotationComposer,
          $$ScheduledReminderRequestsTableCreateCompanionBuilder,
          $$ScheduledReminderRequestsTableUpdateCompanionBuilder,
          (
            ScheduledReminderRequestRecord,
            $$ScheduledReminderRequestsTableReferences,
          ),
          ScheduledReminderRequestRecord,
          PrefetchHooks Function({bool profileId})
        > {
  $$ScheduledReminderRequestsTableTableManager(
    _$AppDatabase db,
    $ScheduledReminderRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledReminderRequestsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScheduledReminderRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduledReminderRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> identity = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> slot = const Value.absent(),
                Value<String> contentKind = const Value.absent(),
                Value<String> istDate = const Value.absent(),
                Value<int> configuredTimeMinutes = const Value.absent(),
                Value<DateTime> scheduledAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduledReminderRequestsCompanion(
                identity: identity,
                notificationId: notificationId,
                profileId: profileId,
                slot: slot,
                contentKind: contentKind,
                istDate: istDate,
                configuredTimeMinutes: configuredTimeMinutes,
                scheduledAtUtc: scheduledAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String identity,
                required int notificationId,
                required String profileId,
                required String slot,
                required String contentKind,
                required String istDate,
                required int configuredTimeMinutes,
                required DateTime scheduledAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => ScheduledReminderRequestsCompanion.insert(
                identity: identity,
                notificationId: notificationId,
                profileId: profileId,
                slot: slot,
                contentKind: contentKind,
                istDate: istDate,
                configuredTimeMinutes: configuredTimeMinutes,
                scheduledAtUtc: scheduledAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ScheduledReminderRequestsTable,
                    ScheduledReminderRequestRecord
                  >(table),
                  $$ScheduledReminderRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable:
                            $$ScheduledReminderRequestsTableReferences
                                ._profileIdTable(db),
                        referencedColumn:
                            $$ScheduledReminderRequestsTableReferences
                                ._profileIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScheduledReminderRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduledReminderRequestsTable,
      ScheduledReminderRequestRecord,
      $$ScheduledReminderRequestsTableFilterComposer,
      $$ScheduledReminderRequestsTableOrderingComposer,
      $$ScheduledReminderRequestsTableAnnotationComposer,
      $$ScheduledReminderRequestsTableCreateCompanionBuilder,
      $$ScheduledReminderRequestsTableUpdateCompanionBuilder,
      (
        ScheduledReminderRequestRecord,
        $$ScheduledReminderRequestsTableReferences,
      ),
      ScheduledReminderRequestRecord,
      PrefetchHooks Function({bool profileId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$LocalTasksTableTableManager get localTasks =>
      $$LocalTasksTableTableManager(_db, _db.localTasks);
  $$LocalProgressEntriesTableTableManager get localProgressEntries =>
      $$LocalProgressEntriesTableTableManager(_db, _db.localProgressEntries);
  $$LocalLifecycleEventsTableTableManager get localLifecycleEvents =>
      $$LocalLifecycleEventsTableTableManager(_db, _db.localLifecycleEvents);
  $$ReminderPreferencesTableTableManager get reminderPreferences =>
      $$ReminderPreferencesTableTableManager(_db, _db.reminderPreferences);
  $$ScheduledReminderRequestsTableTableManager get scheduledReminderRequests =>
      $$ScheduledReminderRequestsTableTableManager(
        _db,
        _db.scheduledReminderRequests,
      );
}
