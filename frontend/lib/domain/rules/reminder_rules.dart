import '../entities/progress_entry.dart';
import '../entities/reminder_preferences.dart';
import '../entities/reminder_request.dart';
import '../entities/task.dart';

/// Pure reminder decisions. This file does not read a clock, database, or OS.
abstract final class ReminderRules {
  /// Returns the one morning request: a summary if there is active work,
  /// otherwise a prompt to assign work. The slot identity is always the same.
  static ReminderRequest? morningRequest({
    required ReminderPreferences preferences,
    required TaskDate today,
    required DateTime scheduledAtUtc,
    required List<Task> tasks,
  }) {
    if (!preferences.enabled) return null;
    final activeCount = _activeTasks(
      preferences.profileId,
      today,
      tasks,
    ).length;
    return ReminderRequest(
      profileId: preferences.profileId,
      slot: ReminderSlot.morning,
      contentKind: activeCount == 0
          ? ReminderContentKind.assignTask
          : ReminderContentKind.dailySummary,
      date: today,
      configuredTime: preferences.morningTime,
      scheduledAtUtc: scheduledAtUtc.toUtc(),
      taskCount: activeCount == 0 ? null : activeCount,
    );
  }

  /// The noon prompt is only needed while there is no active task for today.
  static ReminderRequest? middayRequest({
    required ReminderPreferences preferences,
    required TaskDate today,
    required DateTime scheduledAtUtc,
    required List<Task> tasks,
  }) {
    if (!preferences.enabled ||
        _activeTasks(preferences.profileId, today, tasks).isNotEmpty) {
      return null;
    }
    return ReminderRequest(
      profileId: preferences.profileId,
      slot: ReminderSlot.midday,
      contentKind: ReminderContentKind.assignTask,
      date: today,
      configuredTime: preferences.middayTime,
      scheduledAtUtc: scheduledAtUtc.toUtc(),
    );
  }

  /// One generic end-of-day prompt is needed if any active task has no progress
  /// entry that occurred on the current IST calendar date.
  static ReminderRequest? endOfDayRequest({
    required ReminderPreferences preferences,
    required TaskDate today,
    required DateTime scheduledAtUtc,
    required List<Task> tasks,
    required List<ProgressEntry> progressEntries,
  }) {
    if (!preferences.enabled) return null;
    final needsLog = _activeTasks(preferences.profileId, today, tasks).where((
      task,
    ) {
      return !progressEntries.any(
        (entry) =>
            entry.profileId == preferences.profileId &&
            entry.taskId == task.id &&
            TaskDate.todayInIst(entry.occurredAt) == today,
      );
    }).length;
    if (needsLog == 0) return null;
    return ReminderRequest(
      profileId: preferences.profileId,
      slot: ReminderSlot.endOfDay,
      contentKind: ReminderContentKind.logToday,
      date: today,
      configuredTime: preferences.endOfDayTime,
      scheduledAtUtc: scheduledAtUtc.toUtc(),
      taskCount: needsLog,
    );
  }

  /// Returns a same-day quiet-hours deferral, or null to suppress a reminder
  /// whose quiet period would only end on the following IST date.
  static ReminderTime? quietHoursDeliveryTime({
    required ReminderTime configuredTime,
    required ReminderTime? quietHoursStart,
    required ReminderTime? quietHoursEnd,
  }) {
    if (quietHoursStart == null ||
        quietHoursEnd == null ||
        quietHoursStart == quietHoursEnd) {
      return configuredTime;
    }

    final time = configuredTime.minutesAfterMidnight;
    final start = quietHoursStart.minutesAfterMidnight;
    final end = quietHoursEnd.minutesAfterMidnight;
    final crossesMidnight = start > end;
    final isQuiet = crossesMidnight
        ? time >= start || time < end
        : time >= start && time < end;
    if (!isQuiet) return configuredTime;

    // For an overnight window, a reminder in the late-evening part would be
    // deferred to tomorrow, so suppress it instead of sending stale content.
    if (crossesMidnight && time >= start) return null;
    return end > time ? quietHoursEnd : null;
  }

  static List<Task> _activeTasks(
    String profileId,
    TaskDate today,
    List<Task> tasks,
  ) => tasks
      .where(
        (task) =>
            task.profileId == profileId &&
            task.status == TaskStatus.open &&
            task.startDate <= today,
      )
      .toList(growable: false);
}
