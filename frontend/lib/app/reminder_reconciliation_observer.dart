import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database_providers.dart';
import 'reminder_use_case_providers.dart';

/// Keeps local reminder schedules aligned when the app starts or resumes.
class ReminderReconciliationObserver extends ConsumerStatefulWidget {
  const ReminderReconciliationObserver({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReminderReconciliationObserver> createState() =>
      _ReminderReconciliationObserverState();
}

class _ReminderReconciliationObserverState
    extends ConsumerState<ReminderReconciliationObserver>
    with WidgetsBindingObserver {
  bool _isReconciling = false;
  bool _needsAnotherPass = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueReconciliation();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _queueReconciliation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _queueReconciliation() {
    if (!mounted) return;
    if (_isReconciling) {
      _needsAnotherPass = true;
      return;
    }

    _isReconciling = true;
    unawaited(_reconcileUntilCurrent());
  }

  Future<void> _reconcileUntilCurrent() async {
    try {
      do {
        _needsAnotherPass = false;
        try {
          final profile = await ref.read(activeProfileProvider.future);
          if (!mounted) return;
          final reconcile = await ref.read(reconcileRemindersProvider.future);
          await reconcile(profile.id);
        } catch (error, stackTrace) {
          // Reminder setup is best effort; never block opening or resuming tasks.
          debugPrint('Could not reconcile reminders on app resume: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      } while (_needsAnotherPass && mounted);
    } finally {
      _isReconciling = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
