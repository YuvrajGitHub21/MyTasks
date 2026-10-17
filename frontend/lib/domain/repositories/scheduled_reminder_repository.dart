import '../entities/reminder_request.dart';
import '../entities/scheduled_reminder_record.dart';

/// Profile-scoped persistence port for the desired/pending notification ledger.
abstract interface class ScheduledReminderRepository {
  Future<List<ScheduledReminderRecord>> getRequests(String profileId);

  /// Upserts the desired requests, retaining IDs for matching identities.
  /// Obsolete records stay in the ledger until their OS notifications have
  /// been canceled; then call [deleteRequests] to acknowledge their removal.
  Future<List<ScheduledReminderRecord>> upsertDesiredRequests({
    required String profileId,
    required List<ReminderRequest> requests,
    required DateTime updatedAtUtc,
  });

  Future<void> deleteRequests({
    required String profileId,
    required Set<String> identities,
  });
}
