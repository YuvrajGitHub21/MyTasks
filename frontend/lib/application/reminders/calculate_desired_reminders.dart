import '../../domain/entities/reminder_preferences.dart';
import '../../domain/entities/reminder_request.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/reminder_preferences_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/rules/reminder_rules.dart';
import 'reminder_clock.dart';
import 'reminder_schedule_time.dart';

/// Calculates the one-shot reminders needed for the rest of today and
/// tomorrow. It reads app/domain ports only; no database or OS plugin types.
final class CalculateDesiredReminders {
  factory CalculateDesiredReminders({
    required TaskRepository tasks,
    required ProgressRepository progress,
    required ReminderPreferencesRepository preferences,
    required ReminderClock clock,
  }) => CalculateDesiredReminders._(
    tasks: tasks,
    progress: progress,
    preferences: preferences,
    clock: clock,
  );

  const CalculateDesiredReminders._({
    required this._tasks,
    required this._progress,
    required this._preferences,
    required this._clock,
  });

  final TaskRepository _tasks;
  final ProgressRepository _progress;
  final ReminderPreferencesRepository _preferences;
  final ReminderClock _clock;

  Future<List<ReminderRequest>> call(String profileId) async {
    if (profileId.trim().isEmpty) {
      throw ArgumentError.value(profileId, 'profileId', 'Cannot be empty.');
    }

    final nowUtc = _clock.nowUtc().toUtc();
    final today = TaskDate.todayInIst(nowUtc);
    final tomorrow = ReminderScheduleTime.nextDay(today);
    final preferences =
        await _preferences.getPreferences(profileId) ??
        ReminderPreferences.defaults(
          profileId: profileId,
          updatedAtUtc: nowUtc,
        );
    if (!preferences.enabled) return const [];

    final profileTasks = (await _tasks.watchTasks().first)
        .where((task) => task.profileId == profileId)
        .toList(growable: false);
    final tasksNeedingHistory = profileTasks.where(
      (task) => task.status == TaskStatus.open && task.startDate <= tomorrow,
    );
    final histories = await Future.wait(
      tasksNeedingHistory.map(
        (task) => _progress.watchEntriesForTask(task.id).first,
      ),
    );
    final entries = histories.expand((history) => history).toList();

    final requests = <ReminderRequest>[];
    for (final date in [today, tomorrow]) {
      _addIfEligible(
        requests,
        ReminderRules.morningRequest(
          preferences: preferences,
          today: date,
          scheduledAtUtc: ReminderScheduleTime.toUtc(
            date,
            preferences.morningTime,
          ),
          tasks: profileTasks,
        ),
        preferences,
        nowUtc,
        today,
      );
      _addIfEligible(
        requests,
        ReminderRules.middayRequest(
          preferences: preferences,
          today: date,
          scheduledAtUtc: ReminderScheduleTime.toUtc(
            date,
            preferences.middayTime,
          ),
          tasks: profileTasks,
        ),
        preferences,
        nowUtc,
        today,
      );
      _addIfEligible(
        requests,
        ReminderRules.endOfDayRequest(
          preferences: preferences,
          today: date,
          scheduledAtUtc: ReminderScheduleTime.toUtc(
            date,
            preferences.endOfDayTime,
          ),
          tasks: profileTasks,
          progressEntries: entries,
        ),
        preferences,
        nowUtc,
        today,
      );
    }

    requests.sort(
      (left, right) => left.scheduledAtUtc.compareTo(right.scheduledAtUtc),
    );
    return List.unmodifiable(requests);
  }

  void _addIfEligible(
    List<ReminderRequest> requests,
    ReminderRequest? request,
    ReminderPreferences preferences,
    DateTime nowUtc,
    TaskDate today,
  ) {
    if (request == null) return;
    final effectiveTime = ReminderRules.quietHoursDeliveryTime(
      configuredTime: request.configuredTime,
      quietHoursStart: preferences.quietHoursStart,
      quietHoursEnd: preferences.quietHoursEnd,
    );
    if (effectiveTime == null) return;

    final scheduledAtUtc = ReminderScheduleTime.toUtc(
      request.date,
      effectiveTime,
    );
    if (request.date == today && !scheduledAtUtc.isAfter(nowUtc)) return;

    requests.add(
      ReminderRequest(
        profileId: request.profileId,
        slot: request.slot,
        contentKind: request.contentKind,
        date: request.date,
        configuredTime: request.configuredTime,
        scheduledAtUtc: scheduledAtUtc,
        taskCount: request.taskCount,
      ),
    );
  }
}
