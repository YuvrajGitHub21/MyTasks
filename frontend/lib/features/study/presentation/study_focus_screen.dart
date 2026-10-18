import 'dart:async';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/study_session_use_case_providers.dart';
import '../../../domain/entities/study_session.dart';
import '../../../domain/entities/task.dart';

const _focusDisplayChannel = MethodChannel('com.mytasks/focus_display');

/// Full-screen timer mode. The platform adapter keeps the display awake while
/// this route is visible and changes brightness only for this app window.
class StudyFocusScreen extends ConsumerStatefulWidget {
  const StudyFocusScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<StudyFocusScreen> createState() => _StudyFocusScreenState();
}

class _StudyFocusScreenState extends ConsumerState<StudyFocusScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  DateTime _nowUtc = DateTime.now().toUtc();
  bool _busy = false;
  bool _dimScreen = false;
  bool _silenceEnabled = false;
  bool _waitingForDndAccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _nowUtc = DateTime.now().toUtc());
    });
    unawaited(_enterFocus());
  }

  Future<void> _enterFocus() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    try {
      await _focusDisplayChannel.invokeMethod<void>('enterFocus');
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage('Could not keep the screen awake: ${error.message}');
      }
    } on MissingPluginException {
      if (mounted) {
        _showMessage('Screen focus controls are unavailable on this device.');
      }
    }
  }

  Future<void> _leaveFocus() async {
    if (_silenceEnabled) {
      try {
        await _focusDisplayChannel.invokeMethod<void>('setFocusSilence', false);
      } on PlatformException {
        // DND cleanup must not prevent leaving this page.
      } on MissingPluginException {
        // DND cleanup must not prevent leaving this page.
      }
    }
    try {
      await _focusDisplayChannel.invokeMethod<void>('exitFocus');
    } on PlatformException {
      // A missing display-control adapter must not prevent leaving this page.
    } on MissingPluginException {
      // A missing display-control adapter must not prevent leaving this page.
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    unawaited(_leaveFocus());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _nowUtc = DateTime.now().toUtc());
      unawaited(_enterFocus());
      if (_waitingForDndAccess) {
        unawaited(_enableSilenceAfterSettings());
      }
      if (_dimScreen) {
        unawaited(
          _focusDisplayChannel.invokeMethod<void>('setFocusBrightness', 0.28),
        );
      }
    } else if (_dimScreen) {
      // iOS brightness can outlive the current app window. Restore it while
      // backgrounded, then reapply the user-selected dim level on resume.
      unawaited(
        _focusDisplayChannel.invokeMethod<void>('restoreFocusBrightness'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeStudySessionProvider);
    final availableTasks = ref.watch(studyAvailableTasksProvider).asData?.value;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: active.when(
            data: (detail) {
              if (detail == null || detail.session.id != widget.sessionId) {
                return _sessionEnded(context);
              }
              final taskTitle = _taskTitle(
                availableTasks,
                detail.session.taskId,
              );
              return _focusContent(context, detail, taskTitle);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _sessionError(context),
          ),
        ),
      ),
    );
  }

  Widget _focusContent(
    BuildContext context,
    StudySessionDetail detail,
    String taskTitle,
  ) {
    final isOnBreak = detail.session.status == StudySessionStatus.onBreak;
    final activeBreak = detail.activeBreak;
    final seconds = isOnBreak && activeBreak != null
        ? activeBreak.plannedEndAtUtc
              .difference(_nowUtc)
              .inSeconds
              .clamp(0, 86400)
        : detail.session.focusedSecondsAt(_nowUtc);
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Minimize focus screen',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.fullscreen_exit_rounded),
            ),
            const Spacer(),
            Text(
              'STUDY FOCUS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.secondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 48),
          ],
        ),
        const Spacer(),
        Icon(
          isOnBreak ? Icons.coffee_rounded : Icons.auto_stories_rounded,
          size: 42,
          color: isOnBreak ? colors.tertiary : colors.secondary,
        ),
        const SizedBox(height: 12),
        Text(
          isOnBreak ? 'ON BREAK' : 'FOCUSING',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.secondary,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatDuration(seconds),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 88,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            semanticsLabel: isOnBreak
                ? 'Break time remaining: ${_formatDuration(seconds)}'
                : 'Focused time: ${_formatDuration(seconds)}',
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            taskTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        if (isOnBreak && activeBreak != null) ...[
          const SizedBox(height: 8),
          Text('Break ends at ${_formatClock(activeBreak.plannedEndAtUtc)}'),
        ],
        const Spacer(),
        Card(
          child: SwitchListTile.adaptive(
            value: _dimScreen,
            onChanged: _busy ? null : _setDimScreen,
            title: const Text('Dim display'),
            subtitle: const Text('This setting applies only inside MyTasks.'),
            secondary: const Icon(Icons.brightness_4_outlined),
          ),
        ),
        const SizedBox(height: 8),
        if (defaultTargetPlatform == TargetPlatform.android)
          Card(
            child: SwitchListTile.adaptive(
              value: _silenceEnabled,
              onChanged: _busy ? null : _setSilenceEnabled,
              title: const Text('Silence interruptions'),
              subtitle: const Text(
                'Uses Android Do Not Disturb while this full-screen view is open. Some system alerts may still sound.',
              ),
              secondary: const Icon(Icons.notifications_off_outlined),
            ),
          )
        else if (defaultTargetPlatform == TargetPlatform.iOS)
          Card(
            child: ListTile(
              leading: const Icon(Icons.do_not_disturb_on_outlined),
              title: const Text('Silence interruptions on iPhone'),
              subtitle: const Text(
                'Open Control Center, tap Focus, then choose Do Not Disturb. iOS does not let MyTasks turn on system Focus.',
              ),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            if (isOnBreak)
              FilledButton.icon(
                onPressed: _busy ? null : _resume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Resume study'),
              )
            else
              FilledButton.tonalIcon(
                onPressed: _busy ? null : _chooseBreak,
                icon: const Icon(Icons.coffee_rounded),
                label: const Text('Take a break'),
              ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _stop,
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Stop session'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          label: const Text('Minimize and keep studying'),
        ),
      ],
    );
  }

  String _taskTitle(List<Task>? tasks, String? taskId) {
    if (taskId == null) return 'Unlinked study session';
    if (tasks != null) {
      for (final task in tasks) {
        if (task.id == taskId) return task.topic;
      }
    }
    return 'Linked task';
  }

  Widget _sessionEnded(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline_rounded, size: 52),
        const SizedBox(height: 16),
        Text('Session ended', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );

  Widget _sessionError(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Could not load this study session.'),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Go back'),
        ),
      ],
    ),
  );

  Future<void> _setDimScreen(bool dim) async {
    try {
      if (dim) {
        await _focusDisplayChannel.invokeMethod<void>(
          'setFocusBrightness',
          0.28,
        );
      } else {
        await _focusDisplayChannel.invokeMethod<void>('restoreFocusBrightness');
      }
      if (mounted) setState(() => _dimScreen = dim);
    } on PlatformException {
      if (mounted) {
        _showMessage('Could not change display brightness.');
      }
    } on MissingPluginException {
      if (mounted) {
        _showMessage('Brightness control is unavailable on this device.');
      }
    }
  }

  Future<void> _setSilenceEnabled(bool enabled) async {
    if (!enabled) {
      await _releaseSilence();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silence interruptions during focus?'),
        content: const Text(
          'Android will use a MyTasks Do Not Disturb rule while this full-screen view is open. Device policies, emergency alerts, or allowed exceptions may still interrupt you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final hasAccess =
          await _focusDisplayChannel.invokeMethod<bool>(
            'hasNotificationPolicyAccess',
          ) ??
          false;
      if (!mounted) return;
      if (!hasAccess) {
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Allow Do Not Disturb access'),
            content: const Text(
              'Android requires you to grant MyTasks access in system settings. You can turn it off there at any time.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        if (openSettings != true || !mounted) return;
        _waitingForDndAccess = true;
        await _focusDisplayChannel.invokeMethod<void>(
          'openNotificationPolicySettings',
        );
        return;
      }
      await _focusDisplayChannel.invokeMethod<void>('setFocusSilence', true);
      if (mounted) setState(() => _silenceEnabled = true);
    } on PlatformException {
      if (mounted) _showMessage('Android could not enable silence mode.');
    } on MissingPluginException {
      if (mounted) _showMessage('Silence mode is unavailable on this device.');
    }
  }

  Future<void> _enableSilenceAfterSettings() async {
    _waitingForDndAccess = false;
    try {
      final hasAccess =
          await _focusDisplayChannel.invokeMethod<bool>(
            'hasNotificationPolicyAccess',
          ) ??
          false;
      if (!hasAccess) {
        if (mounted) _showMessage('Do Not Disturb access was not granted.');
        return;
      }
      await _focusDisplayChannel.invokeMethod<void>('setFocusSilence', true);
      if (mounted) setState(() => _silenceEnabled = true);
    } on PlatformException {
      if (mounted) _showMessage('Android could not enable silence mode.');
    } on MissingPluginException {
      if (mounted) _showMessage('Silence mode is unavailable on this device.');
    }
  }

  Future<void> _releaseSilence() async {
    try {
      await _focusDisplayChannel.invokeMethod<void>('setFocusSilence', false);
      if (mounted) setState(() => _silenceEnabled = false);
    } on PlatformException {
      if (mounted) _showMessage('Could not turn off MyTasks silence mode.');
    } on MissingPluginException {
      if (mounted) _showMessage('Silence mode is unavailable on this device.');
    }
  }

  Future<void> _chooseBreak() async {
    final minutes = await showDialog<int>(
      context: context,
      builder: (_) => const _FocusBreakDialog(),
    );
    if (!mounted || minutes == null) return;
    await _runAction(() async {
      final useCases = await ref.read(studySessionUseCasesProvider.future);
      final result = await useCases.takeBreak(
        profileId: useCases.profileId,
        sessionId: widget.sessionId,
        durationMinutes: minutes,
      );
      if (!result.platformAlertHandled && mounted) {
        _showMessage(
          'Break started, but its end alert could not be scheduled.',
        );
      }
    });
  }

  Future<void> _resume() => _runAction(() async {
    final useCases = await ref.read(studySessionUseCasesProvider.future);
    final result = await useCases.resume(
      profileId: useCases.profileId,
      sessionId: widget.sessionId,
    );
    if (!result.platformAlertHandled && mounted) {
      _showMessage('Study resumed, but the break alert could not be cleared.');
    }
  });

  Future<void> _stop() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish this study session?'),
        content: const Text(
          'Focused time will be saved. Break time is excluded from your total.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep studying'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop session'),
          ),
        ],
      ),
    );
    if (shouldStop != true || !mounted) return;
    await _runAction(() async {
      final useCases = await ref.read(studySessionUseCasesProvider.future);
      final result = await useCases.stop(
        profileId: useCases.profileId,
        sessionId: widget.sessionId,
      );
      if (!result.platformAlertHandled && mounted) {
        _showMessage(
          'Session saved, but its break alert could not be cleared.',
        );
      }
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        _showMessage('Could not update the study session. Try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FocusBreakDialog extends StatefulWidget {
  const _FocusBreakDialog();

  @override
  State<_FocusBreakDialog> createState() => _FocusBreakDialogState();
}

class _FocusBreakDialogState extends State<_FocusBreakDialog> {
  final _customMinutes = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _customMinutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Choose a break'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Study time pauses until you choose Resume study.'),
        const SizedBox(height: 12),
        for (final minutes in [10, 20])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.coffee_rounded),
            title: Text('$minutes minutes'),
            onTap: () => Navigator.pop(context, minutes),
          ),
        TextField(
          controller: _customMinutes,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Custom minutes (1–240)',
            errorText: _error,
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final minutes = int.tryParse(_customMinutes.text.trim());
          if (minutes == null || minutes < 1 || minutes > 240) {
            setState(() => _error = 'Enter a whole number from 1 to 240.');
            return;
          }
          Navigator.pop(context, minutes);
        },
        child: const Text('Start break'),
      ),
    ],
  );
}

String _formatDuration(int seconds) {
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final hours = safeSeconds ~/ 3600;
  final minutes = (safeSeconds % 3600) ~/ 60;
  final remainder = safeSeconds % 60;
  if (hours > 0) {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
  return '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
}

String _formatClock(DateTime utc) {
  final ist = utc.toUtc().add(const Duration(hours: 5, minutes: 30));
  final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
  final suffix = ist.hour < 12 ? 'AM' : 'PM';
  return '$hour:${ist.minute.toString().padLeft(2, '0')} $suffix';
}
