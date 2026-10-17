import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reminder_use_case_providers.dart';

/// Refreshes the OS schedule after a successful task-related write.
///
/// Reminder delivery is best effort: an OS/plugin error must not make an
/// already-saved task appear to have failed. Keep the error visible in logs
/// so it can be diagnosed without exposing task contents.
Future<void> reconcileRemindersAfterChange(Ref ref, String profileId) async {
  try {
    final reconcile = await ref.read(reconcileRemindersProvider.future);
    await reconcile(profileId);
  } catch (error, stackTrace) {
    debugPrint('Could not refresh local reminders: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
