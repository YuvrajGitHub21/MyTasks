enum ProgressMethod { percent, units, note }

/// One dated partial-progress entry. A method selects which value is used;
/// TaskRules checks that all other method values are absent.
final class ProgressEntry {
  const ProgressEntry({
    required this.id,
    required this.taskId,
    required this.profileId,
    required this.method,
    this.percentComplete,
    this.completedUnits,
    this.totalUnits,
    this.note,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String taskId;
  final String profileId;
  final ProgressMethod method;
  final int? percentComplete;
  final int? completedUnits;
  final int? totalUnits;
  final String? note;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
