import '../entities/snoozed_reminder_record.dart';

/// Encrypted local ledger for one-off snooze occurrences.
abstract interface class SnoozedReminderRepository {
  Future<List<SnoozedReminderRecord>> getForProfile(String profileId);

  /// Saves or replaces one occurrence by its stable local ID.
  Future<void> save(SnoozedReminderRecord record);

  Future<void> delete({
    required String profileId,
    required Set<String> occurrenceIds,
  });
}
