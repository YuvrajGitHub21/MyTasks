// This file is resposible for creating local SqlLite database . 
import 'package:drift/drift.dart';

import 'encrypted_database_connection.dart';

part 'app_database.g.dart';

@DataClassName('ProfileRecord')
class LocalProfiles extends Table {
  @override
  String get tableName => 'local_profiles';

  TextColumn get id => text()();
  TextColumn get profileType => text().withDefault(const Constant('GUEST'))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (profile_type IN ('GUEST', 'ACCOUNT'))",
  ];
}

@DataClassName('TaskRecord')
@TableIndex(
  name: 'local_tasks_profile_start_status_idx',
  columns: {#profileId, #startDate, #status},
)
class LocalTasks extends Table {
  @override
  String get tableName => 'local_tasks';

  TextColumn get id => text()();
  TextColumn get profileId => text().references(
    LocalProfiles,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get topic => text()();
  TextColumn get subtopic => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get startDate => text()();
  TextColumn get plannedEndDate => text()();
  TextColumn get maximumEndDate => text().nullable()();
  IntColumn get effortHundredths => integer()();
  TextColumn get status => text().withDefault(const Constant('OPEN'))();
  DateTimeColumn get completedAtUtc => dateTime().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // The composite unique key lets history rows enforce that their profile and
  // task belong together, in addition to each row's profile foreign key.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {id, profileId},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(topic)) BETWEEN 1 AND 200)',
    'CHECK (subtopic IS NULL OR length(trim(subtopic)) <= 200)',
    'CHECK (description IS NULL OR length(description) <= 5000)',
    'CHECK (effort_hundredths BETWEEN 1 AND 9999999)',
    "CHECK (start_date <= planned_end_date AND "
        "(maximum_end_date IS NULL OR maximum_end_date >= planned_end_date))",
    "CHECK ((status = 'OPEN' AND completed_at_utc IS NULL) OR "
        "(status = 'COMPLETED' AND completed_at_utc IS NOT NULL))",
  ];
}

@DataClassName('ProgressEntryRecord')
@TableIndex(
  name: 'local_progress_profile_task_time_idx',
  columns: {#profileId, #taskId, #occurredAtUtc},
)
class LocalProgressEntries extends Table {
  @override
  String get tableName => 'local_progress_entries';

  TextColumn get id => text()();
  TextColumn get profileId => text().references(
    LocalProfiles,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get taskId => text()();
  TextColumn get method => text()();
  IntColumn get percentComplete => integer().nullable()();
  IntColumn get completedUnits => integer().nullable()();
  IntColumn get totalUnits => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get occurredAtUtc => dateTime()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK ((method = 'PERCENT' AND percent_complete IS NOT NULL "
        'AND percent_complete BETWEEN 0 AND 100 '
        'AND completed_units IS NULL AND total_units IS NULL AND note IS NULL) OR '
        "(method = 'UNITS' AND completed_units IS NOT NULL AND total_units IS NOT NULL "
        'AND completed_units > 0 AND total_units > 0 '
        'AND completed_units <= total_units AND percent_complete IS NULL AND note IS NULL) OR '
        "(method = 'NOTE' AND note IS NOT NULL AND length(trim(note)) BETWEEN 1 AND 2000 "
        'AND percent_complete IS NULL AND completed_units IS NULL AND total_units IS NULL))',
    'FOREIGN KEY (task_id, profile_id) '
        'REFERENCES local_tasks (id, profile_id) ON DELETE CASCADE',
  ];
}

@DataClassName('LifecycleEventRecord')
@TableIndex(
  name: 'local_lifecycle_profile_task_time_idx',
  columns: {#profileId, #taskId, #occurredAtUtc},
)
class LocalLifecycleEvents extends Table {
  @override
  String get tableName => 'local_lifecycle_events';

  TextColumn get id => text()();
  TextColumn get profileId => text().references(
    LocalProfiles,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get taskId => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get occurredAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (event_type IN ('COMPLETED', 'REOPENED'))",
    'FOREIGN KEY (task_id, profile_id) '
        'REFERENCES local_tasks (id, profile_id) ON DELETE CASCADE',
  ];
}

@DriftDatabase(
  tables: [
    LocalProfiles,
    LocalTasks,
    LocalProgressEntries,
    LocalLifecycleEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  static Future<AppDatabase> openEncrypted({
    EncryptedDatabaseConnection? connection,
  }) async {
    final executor = await (connection ?? EncryptedDatabaseConnection()).open();
    return AppDatabase(executor);
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
