import '../entities/lifecycle_event.dart';
import '../entities/progress_entry.dart';
import '../entities/task.dart';

/// Pure, reusable rules shared by forms, storage, and future sync code.
/// Errors are returned by field name so a form can show them beside inputs.
abstract final class TaskRules {
  static const maximumEffortHundredths = 9999999;
  static const _effortPattern = r'^\d+(?:\.\d{1,2})?$';

  static Map<String, String> validateTask({
    required String topic,
    String? subtopic,
    String? description,
    required TaskDate? startDate,
    required TaskDate? plannedEndDate,
    TaskDate? maximumEndDate,
    required String effortInput,
  }) {
    final errors = <String, String>{};
    final cleanedTopic = topic.trim();
    final cleanedSubtopic = subtopic?.trim();
    final cleanedDescription = description?.trim();

    if (cleanedTopic.isEmpty) {
      errors['topic'] = 'Enter a topic.';
    } else if (cleanedTopic.length > 200) {
      errors['topic'] = 'Topic must be 200 characters or fewer.';
    }
    if ((cleanedSubtopic?.length ?? 0) > 200) {
      errors['subtopic'] = 'Subtopic must be 200 characters or fewer.';
    }
    if ((cleanedDescription?.length ?? 0) > 5000) {
      errors['description'] = 'Description must be 5,000 characters or fewer.';
    }

    if (startDate == null || plannedEndDate == null) {
      errors['dates'] = 'Choose a start date and an end date.';
    } else if (plannedEndDate < startDate) {
      errors['plannedEndDate'] = 'End date must be on or after the start date.';
    }
    if (maximumEndDate != null &&
        plannedEndDate != null &&
        maximumEndDate < plannedEndDate) {
      errors['maximumEndDate'] =
          'Maximum end date must be on or after the end date.';
    }

    final effort = effortInput.trim();
    if (effort.isEmpty || !RegExp(_effortPattern).hasMatch(effort)) {
      errors['effort'] =
          'Enter an effort greater than 0 and no more than 99,999.99 hours.';
    } else {
      final hundredths = effortHundredthsFromInput(effort);
      if (hundredths == null || hundredths <= 0 ||
          hundredths > maximumEffortHundredths) {
        errors['effort'] =
            'Enter an effort greater than 0 and no more than 99,999.99 hours.';
      }
    }
    return errors;
  }

  /// Parses decimal hours exactly into integer hundredths, or returns null
  /// when input is malformed or outside the supported range.
  static int? effortHundredthsFromInput(String input) {
    final normalized = input.trim();
    if (!RegExp(_effortPattern).hasMatch(normalized)) return null;
    final parts = normalized.split('.');
    final wholeHours = int.tryParse(parts.first);
    if (wholeHours == null) return null;
    final fraction = parts.length == 1
        ? 0
        : int.parse(parts.last.padRight(2, '0'));
    final result = wholeHours * 100 + fraction;
    if (result > maximumEffortHundredths) return null;
    return result;
  }

  static Map<String, String> validateProgress(ProgressEntry entry) {
    final errors = <String, String>{};
    switch (entry.method) {
      case ProgressMethod.percent:
        if (entry.percentComplete == null ||
            entry.percentComplete! < 0 ||
            entry.percentComplete! > 100 ||
            entry.completedUnits != null ||
            entry.totalUnits != null ||
            entry.note != null) {
          errors['progress'] = 'Enter a percentage from 0 to 100.';
        }
        break;
      case ProgressMethod.units:
        final completed = entry.completedUnits;
        final total = entry.totalUnits;
        if (completed == null || total == null || completed <= 0 ||
            total <= 0 || completed > total || entry.percentComplete != null ||
            entry.note != null) {
          errors['progress'] =
              'Enter positive completed and total units. Completed units cannot exceed total units.';
        }
        break;
      case ProgressMethod.note:
        final note = entry.note?.trim() ?? '';
        if (note.isEmpty || note.length > 2000 ||
            entry.percentComplete != null ||
            entry.completedUnits != null ||
            entry.totalUnits != null) {
          errors['progress'] =
              'Enter a progress note of up to 2,000 characters.';
        }
        break;
    }
    return errors;
  }

  static Map<String, String> validateLifecycleTransition({
    required TaskStatus currentStatus,
    required LifecycleEventType event,
  }) {
    final isValid = switch ((currentStatus, event)) {
      (TaskStatus.open, LifecycleEventType.completed) => true,
      (TaskStatus.completed, LifecycleEventType.reopened) => true,
      _ => false,
    };
    return isValid ? const {} : {'status': 'This task status change is not valid.'};
  }

  /// Completed tasks are exclusive to Completed. Future open tasks are Later.
  /// Due open tasks remain in Today and receive overdue styling.
  static TaskCategory classify(Task task, TaskDate today) {
    if (task.status == TaskStatus.completed) return TaskCategory.completed;
    if (task.startDate > today) return TaskCategory.scheduled;
    if (task.plannedEndDate < today) return TaskCategory.overdue;
    return TaskCategory.current;
  }

  static bool isPastMaximumDate(Task task, TaskDate today) =>
      task.status == TaskStatus.open &&
      task.maximumEndDate != null &&
      task.maximumEndDate! < today;

  /// Fixed thresholds from UI-Flow-and-Wireframe.md. UI maps the returned
  /// band to its theme colors so domain code stays independent of Flutter.
  static EffortBand effortBand(int effortHundredths) {
    if (effortHundredths <= 100) return EffortBand.level1;
    if (effortHundredths <= 300) return EffortBand.level2;
    if (effortHundredths <= 600) return EffortBand.level3;
    if (effortHundredths <= 1000) return EffortBand.level4;
    return EffortBand.level5;
  }
}

