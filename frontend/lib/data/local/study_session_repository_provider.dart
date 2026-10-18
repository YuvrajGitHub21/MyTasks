import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/study_session_repository.dart';
import 'database_providers.dart';
import 'drift_study_session_repository.dart';

/// Opens the study-session adapter within the signed-in guest profile boundary.
final studySessionRepositoryProvider = FutureProvider<StudySessionRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  return DriftStudySessionRepository(database, profile.id);
});
