import 'package:flutter_test/flutter_test.dart';
import 'package:mytasks/application/reminders/import_snoozed_reminders.dart';
import 'package:mytasks/application/reminders/reminder_clock.dart';
import 'package:mytasks/application/reminders/save_reminder_preferences.dart';
import 'package:mytasks/domain/entities/pending_snooze_event.dart';
import 'package:mytasks/domain/entities/reminder_preferences.dart';
import 'package:mytasks/domain/entities/reminder_request.dart';
import 'package:mytasks/domain/entities/scheduled_reminder_record.dart';
import 'package:mytasks/domain/entities/snoozed_reminder_record.dart';
import 'package:mytasks/domain/repositories/reminder_preferences_repository.dart';
import 'package:mytasks/domain/repositories/scheduled_reminder_repository.dart';
import 'package:mytasks/domain/repositories/snoozed_reminder_repository.dart';
import 'package:mytasks/domain/services/diagnostic_logger.dart';
import 'package:mytasks/domain/services/snoozed_reminder_event_source.dart';

void main() {
  const profileId = 'profile-id';
  final logger = _CaptureLogger();

  setUp(() => logger.clear());

  test('records preference-save outcome without reminder times', () async {
    final repository = _PreferencesRepository();
    final action = SaveReminderPreferences(
      repository: repository,
      profileId: profileId,
      clock: _FixedClock(),
      logger: logger,
    );

    await action(
      ReminderPreferences.defaults(
        profileId: profileId,
        updatedAtUtc: DateTime.utc(2026),
      ),
    );

    expect(logger.activities, ['reminder.preferences.save.succeeded']);
    expect(logger.failures, isEmpty);
    expect(logger.attributes, hasLength(1));
    expect(logger.attributes.single, isEmpty);
    expect(repository.saved, isNotNull);
  });

  test('records preference-save failure and preserves the error', () async {
    final original = StateError('private preference detail');
    final action = SaveReminderPreferences(
      repository: _PreferencesRepository(error: original),
      profileId: profileId,
      clock: _FixedClock(),
      logger: logger,
    );

    await expectLater(
      action(
        ReminderPreferences.defaults(
          profileId: profileId,
          updatedAtUtc: DateTime.utc(2026),
        ),
      ),
      throwsA(same(original)),
    );
    expect(logger.failures, ['reminder.preferences.save.failed']);
    expect(logger.attributes, isEmpty);
  });

  test('records snooze-import success without IDs or payloads', () async {
    final action = ImportSnoozedReminders(
      eventSource: _EventSource(),
      scheduledRepository: _ScheduledRepository(),
      snoozedRepository: _SnoozedRepository(),
      logger: logger,
    );

    expect(await action(profileId), 0);
    expect(logger.activities, ['reminder.snooze.import.succeeded']);
    expect(logger.failures, isEmpty);
    expect(logger.attributes, hasLength(1));
    expect(logger.attributes.single, isEmpty);
  });

  test('records snooze-import failure without swallowing it', () async {
    final original = StateError('private snooze payload');
    final action = ImportSnoozedReminders(
      eventSource: _EventSource(error: original),
      scheduledRepository: _ScheduledRepository(),
      snoozedRepository: _SnoozedRepository(),
      logger: logger,
    );

    await expectLater(action(profileId), throwsA(same(original)));
    expect(logger.failures, ['reminder.snooze.import.failed']);
    expect(logger.attributes, isEmpty);
  });
}

final class _CaptureLogger implements DiagnosticLogger {
  final activities = <String>[];
  final failures = <String>[];
  final attributes = <Map<String, Object?>>[];

  void clear() {
    activities.clear();
    failures.clear();
    attributes.clear();
  }

  @override
  void activity(
    String eventName, {
    required String feature,
    Map<String, Object?> attributes = const {},
  }) {
    activities.add(eventName);
    this.attributes.add(attributes);
  }

  @override
  void failure(
    String eventName, {
    required String feature,
    required Object error,
    required StackTrace stackTrace,
  }) {
    failures.add(eventName);
  }
}

final class _FixedClock implements ReminderClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 18);
}

final class _PreferencesRepository implements ReminderPreferencesRepository {
  _PreferencesRepository({this.error});

  final Object? error;
  ReminderPreferences? saved;

  @override
  Future<ReminderPreferences?> getPreferences(String profileId) async => null;

  @override
  Future<void> savePreferences(ReminderPreferences preferences) async {
    if (error != null) throw error!;
    saved = preferences;
  }

  @override
  Stream<ReminderPreferences?> watchPreferences(String profileId) =>
      const Stream.empty();
}

final class _EventSource implements SnoozedReminderEventSource {
  _EventSource({this.error});

  final Object? error;

  @override
  Future<void> acknowledge(String platformAlarmId) async {}

  @override
  Future<List<PendingSnoozeEvent>> getPendingEvents() async {
    if (error != null) throw error!;
    return const [];
  }
}

final class _ScheduledRepository implements ScheduledReminderRepository {
  @override
  Future<List<ScheduledReminderRecord>> getRequests(String profileId) async =>
      const [];

  @override
  Future<List<ScheduledReminderRecord>> upsertDesiredRequests({
    required String profileId,
    required List<ReminderRequest> requests,
    required DateTime updatedAtUtc,
  }) async => const [];

  @override
  Future<void> deleteRequests({
    required String profileId,
    required Set<String> identities,
  }) async {}
}

final class _SnoozedRepository implements SnoozedReminderRepository {
  @override
  Future<void> delete({
    required String profileId,
    required Set<String> occurrenceIds,
  }) async {}

  @override
  Future<List<SnoozedReminderRecord>> getForProfile(String profileId) async =>
      const [];

  @override
  Future<void> save(SnoozedReminderRecord record) async {}
}
