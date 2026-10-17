import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/reminder_preferences_repository.dart';
import '../../domain/repositories/scheduled_reminder_repository.dart';
import 'database_providers.dart';
import 'drift_reminder_preferences_repository.dart';
import 'drift_scheduled_reminder_repository.dart';

/// Builds reminder repositories after the encrypted database is available.
final reminderPreferencesRepositoryProvider =
    FutureProvider<ReminderPreferencesRepository>((ref) async {
      final database = await ref.watch(appDatabaseProvider.future);
      return DriftReminderPreferencesRepository(database);
    });

final scheduledReminderRepositoryProvider =
    FutureProvider<ScheduledReminderRepository>((ref) async {
      final database = await ref.watch(appDatabaseProvider.future);
      return DriftScheduledReminderRepository(database);
    });
