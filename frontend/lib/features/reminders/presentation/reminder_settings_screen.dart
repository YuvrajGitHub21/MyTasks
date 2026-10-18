import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/alarm_permission_provider.dart';
import '../../../app/notification_permission_provider.dart';
import '../../../app/reminder_settings_providers.dart';
import '../../../app/reminder_use_case_providers.dart';
import '../../../domain/entities/reminder_preferences.dart';
import '../../../domain/services/alarm_permission_gateway.dart';
import '../../../domain/services/notification_permission_gateway.dart';

/// Explains local reminders and lets the user manage app preference and OS
/// permission as two independent settings.
class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationPermissionStatusProvider);
      ref.invalidate(alarmPermissionStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final permission = ref.watch(notificationPermissionStatusProvider);
    final alarmPermission = ref.watch(alarmPermissionStatusProvider);
    final preferences = ref.watch(reminderSettingsPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.notifications_active_outlined, size: 56),
          const SizedBox(height: 16),
          Text(
            'Stay on top of today’s work',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'MyTasks can send local reminders when it is time to plan today, '
            'review your progress, or log what you worked on. Reminders are '
            'scheduled on this device and do not need an internet connection.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: preferences.when(
              loading: () => const ListTile(
                title: Text('Reminders in MyTasks'),
                subtitle: Text('Loading your preference…'),
                trailing: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, _) => const ListTile(
                leading: Icon(Icons.error_outline),
                title: Text('Reminder preference unavailable'),
                subtitle: Text('Could not read your saved reminder setting.'),
              ),
              data: (saved) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Reminders in MyTasks'),
                    subtitle: const Text(
                      'When on, MyTasks keeps your local reminder schedule up '
                      'to date. Device permission separately controls delivery.',
                    ),
                    value: saved.enabled,
                    onChanged: _savingPreferences
                        ? null
                        : (enabled) => _savePreferences(
                            context,
                            _copyPreferences(saved, enabled: enabled),
                          ),
                  ),
                  const Divider(height: 1),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Reminder times · Asia/Kolkata (IST)'),
                    ),
                  ),
                  _ReminderTimeTile(
                    title: 'Morning reminder',
                    subtitle: 'Daily summary or prompt to plan today',
                    time: saved.morningTime,
                    enabled: saved.enabled && !_savingPreferences,
                    onTap: () => _pickReminderTime(
                      context,
                      saved,
                      _ReminderSlot.morning,
                    ),
                  ),
                  _ReminderTimeTile(
                    title: 'Midday reminder',
                    subtitle: 'Prompt if no task is assigned for today',
                    time: saved.middayTime,
                    enabled: saved.enabled && !_savingPreferences,
                    onTap: () =>
                        _pickReminderTime(context, saved, _ReminderSlot.midday),
                  ),
                  _ReminderTimeTile(
                    title: 'End-of-day reminder',
                    subtitle: 'Prompt to log today’s progress',
                    time: saved.endOfDayTime,
                    enabled: saved.enabled && !_savingPreferences,
                    onTap: () => _pickReminderTime(
                      context,
                      saved,
                      _ReminderSlot.endOfDay,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Quiet hours'),
                    subtitle: const Text(
                      'Defer reminders during quiet hours when possible. '
                      'Default window: 23:00–07:00 IST.',
                    ),
                    value: saved.quietHoursEnabled,
                    onChanged: !saved.enabled || _savingPreferences
                        ? null
                        : (enabled) => _savePreferences(
                            context,
                            _copyPreferences(
                              saved,
                              quietHoursEnabled: enabled,
                              quietHoursStart: enabled
                                  ? saved.quietHoursStart ??
                                        ReminderTime(23 * 60)
                                  : null,
                              quietHoursEnd: enabled
                                  ? saved.quietHoursEnd ?? ReminderTime(7 * 60)
                                  : null,
                            ),
                          ),
                  ),
                  if (saved.quietHoursEnabled) ...[
                    _ReminderTimeTile(
                      title: 'Quiet hours start',
                      subtitle: 'Reminders are held from this time',
                      time: saved.quietHoursStart!,
                      enabled: saved.enabled && !_savingPreferences,
                      onTap: () =>
                          _pickQuietHoursTime(context, saved, isStart: true),
                    ),
                    _ReminderTimeTile(
                      title: 'Quiet hours end',
                      subtitle: 'Reminders may resume at this time',
                      time: saved.quietHoursEnd!,
                      enabled: saved.enabled && !_savingPreferences,
                      onTap: () =>
                          _pickQuietHoursTime(context, saved, isStart: false),
                    ),
                  ],
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Allow standard-notification fallback'),
                    subtitle: const Text(
                      'If alarm-style delivery is unavailable or not allowed, '
                      'MyTasks may send a regular notification instead. It '
                      'can arrive later and will not keep ringing. Off by default.',
                    ),
                    value: saved.allowStandardNotificationFallback,
                    onChanged: !saved.enabled || _savingPreferences
                        ? null
                        : (enabled) => _savePreferences(
                            context,
                            _copyPreferences(
                              saved,
                              allowStandardNotificationFallback: enabled,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: permission.when(
                loading: () => const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Checking notification permission…'),
                  ],
                ),
                error: (error, _) => const _PermissionStatusMessage(
                  icon: Icons.help_outline,
                  message: 'Could not read notification permission status.',
                ),
                data: (status) => _PermissionStatusMessage(
                  icon: switch (status) {
                    NotificationPermissionStatus.enabled =>
                      Icons.check_circle_outline,
                    NotificationPermissionStatus.disabled =>
                      Icons.notifications_off_outlined,
                    NotificationPermissionStatus.unavailable =>
                      Icons.help_outline,
                  },
                  message: switch (status) {
                    NotificationPermissionStatus.enabled =>
                      'Notifications are allowed by your device.',
                    NotificationPermissionStatus.disabled =>
                      'Notifications are disabled by your device. Reminders '
                          'cannot be delivered until you allow them.',
                    NotificationPermissionStatus.unavailable =>
                      'This platform could not report notification status.',
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIos
                        ? 'AlarmKit access (iOS 26+)'
                        : 'Exact alarm access (Android)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  alarmPermission.when(
                    loading: () => const _PermissionStatusMessage(
                      icon: Icons.hourglass_empty,
                      message: 'Checking whether exact alarms are allowed…',
                    ),
                    error: (error, _) => const _PermissionStatusMessage(
                      icon: Icons.help_outline,
                      message: 'Could not read exact-alarm access status.',
                    ),
                    data: (status) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PermissionStatusMessage(
                          icon: switch (status) {
                            AlarmPermissionStatus.allowed =>
                              Icons.check_circle_outline,
                            AlarmPermissionStatus.notAllowed =>
                              Icons.alarm_off_outlined,
                            AlarmPermissionStatus.notDetermined =>
                              Icons.alarm_outlined,
                            AlarmPermissionStatus.unsupported =>
                              Icons.phone_android_outlined,
                          },
                          message: switch (status) {
                            AlarmPermissionStatus.allowed =>
                              isIos
                                  ? 'AlarmKit can schedule MyTasks alarms. '
                                        'Ordinary notification permission is '
                                        'separate.'
                                  : 'Android allows exact alarm scheduling. '
                                        'Notification permission is also needed '
                                        'to show an alert.',
                            AlarmPermissionStatus.notAllowed =>
                              isIos
                                  ? 'AlarmKit access is denied. Enable alarms for '
                                        'MyTasks in iOS Settings; the app will use '
                                        'standard notifications only if you opted in.'
                                  : 'Exact-time alarms are not allowed. You can '
                                        'grant access in Android settings; reminders '
                                        'remain unavailable as alarms until then.',
                            AlarmPermissionStatus.notDetermined =>
                              'Alarm access has not been requested yet. Continue '
                                  'to let the operating system ask you.',
                            AlarmPermissionStatus.unsupported =>
                              isIos
                                  ? 'AlarmKit requires iOS 26 or later. Standard '
                                        'notifications are available only if you '
                                        'opted in to the fallback.'
                                  : 'Exact alarm access is supported on Android '
                                        'and iOS 26 or later.',
                          },
                        ),
                        if (isIos && status == AlarmPermissionStatus.notAllowed)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  _openAlarmSystemSettings(context),
                              icon: const Icon(Icons.settings_outlined),
                              label: const Text('Open iOS Settings'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: alarmPermission.isLoading
                        ? null
                        : () => _explainAndRequestAlarmAccess(context),
                    icon: const Icon(Icons.alarm_add_outlined),
                    label: Text(isIos ? 'Allow alarms' : 'Allow exact alarms'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: permission.isLoading
                ? null
                : () => _explainAndRequestPermission(context, ref),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Enable notifications'),
          ),
          OutlinedButton.icon(
            onPressed: () => _openSystemSettings(context, ref),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Open notification settings'),
          ),
          const SizedBox(height: 8),
          Text(
            'You control notification access in your device settings. '
            'Task creation and other app features work if notifications are off.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _savingPreferences = false;

  Future<void> _pickReminderTime(
    BuildContext context,
    ReminderPreferences current,
    _ReminderSlot slot,
  ) async {
    final currentTime = switch (slot) {
      _ReminderSlot.morning => current.morningTime,
      _ReminderSlot.midday => current.middayTime,
      _ReminderSlot.endOfDay => current.endOfDayTime,
    };
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
      helpText: switch (slot) {
        _ReminderSlot.morning => 'Choose morning reminder time (IST)',
        _ReminderSlot.midday => 'Choose midday reminder time (IST)',
        _ReminderSlot.endOfDay => 'Choose end-of-day reminder time (IST)',
      },
    );
    if (selected == null || !context.mounted) return;

    final selectedTime = ReminderTime(selected.hour * 60 + selected.minute);
    final updated = switch (slot) {
      _ReminderSlot.morning => _copyPreferences(
        current,
        morningTime: selectedTime,
      ),
      _ReminderSlot.midday => _copyPreferences(
        current,
        middayTime: selectedTime,
      ),
      _ReminderSlot.endOfDay => _copyPreferences(
        current,
        endOfDayTime: selectedTime,
      ),
    };
    await _savePreferences(context, updated);
  }

  ReminderPreferences _copyPreferences(
    ReminderPreferences current, {
    bool? enabled,
    bool? quietHoursEnabled,
    bool? allowStandardNotificationFallback,
    ReminderTime? morningTime,
    ReminderTime? middayTime,
    ReminderTime? endOfDayTime,
    ReminderTime? quietHoursStart,
    ReminderTime? quietHoursEnd,
  }) => ReminderPreferences(
    profileId: current.profileId,
    enabled: enabled ?? current.enabled,
    morningTime: morningTime ?? current.morningTime,
    middayTime: middayTime ?? current.middayTime,
    endOfDayTime: endOfDayTime ?? current.endOfDayTime,
    quietHoursStart: quietHoursEnabled == false
        ? null
        : quietHoursStart ?? current.quietHoursStart,
    quietHoursEnd: quietHoursEnabled == false
        ? null
        : quietHoursEnd ?? current.quietHoursEnd,
    allowStandardNotificationFallback:
        allowStandardNotificationFallback ??
        current.allowStandardNotificationFallback,
    soundEnabled: current.soundEnabled,
    vibrationEnabled: current.vibrationEnabled,
    updatedAtUtc: current.updatedAtUtc,
  );

  Future<void> _pickQuietHoursTime(
    BuildContext context,
    ReminderPreferences current, {
    required bool isStart,
  }) async {
    final currentTime = isStart
        ? current.quietHoursStart!
        : current.quietHoursEnd!;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
      helpText: isStart
          ? 'Choose quiet-hours start (IST)'
          : 'Choose quiet-hours end (IST)',
    );
    if (selected == null || !context.mounted) return;

    final selectedTime = ReminderTime(selected.hour * 60 + selected.minute);
    final updated = _copyPreferences(
      current,
      quietHoursStart: isStart ? selectedTime : current.quietHoursStart,
      quietHoursEnd: isStart ? current.quietHoursEnd : selectedTime,
    );
    if (updated.quietHoursStart == updated.quietHoursEnd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiet-hours start and end must differ.')),
      );
      return;
    }
    await _savePreferences(context, updated);
  }

  Future<void> _savePreferences(
    BuildContext context,
    ReminderPreferences updated,
  ) async {
    if (_savingPreferences) return;
    setState(() => _savingPreferences = true);

    try {
      final save = await ref.read(saveReminderPreferencesProvider.future);
      await save(updated);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save reminder setting.')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingPreferences = false);
    }
  }

  Future<void> _explainAndRequestPermission(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Allow task reminders?'),
        content: const Text(
          'MyTasks will use notifications for your chosen planning and progress '
          'reminders. Notification text is generic and does not show task names. '
          'Your device may still delay or suppress reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (shouldContinue != true || !context.mounted) return;

    try {
      await ref.read(notificationPermissionGatewayProvider).requestPermission();
      ref.invalidate(notificationPermissionStatusProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not request notification access.')),
      );
    }
  }

  Future<void> _openSystemSettings(BuildContext context, WidgetRef ref) async {
    try {
      final opened = await ref
          .read(notificationPermissionGatewayProvider)
          .openSystemSettings();
      if (!context.mounted) return;
      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open notification settings.'),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open notification settings.')),
      );
    }
  }

  Future<void> _explainAndRequestAlarmAccess(BuildContext context) async {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isIos ? 'Allow MyTasks alarms?' : 'Allow exact-time alarms?',
        ),
        content: Text(
          isIos
              ? 'MyTasks uses AlarmKit to schedule the alarms you configure. '
                    'Apple will ask whether MyTasks may schedule alarms. '
                    'Alarm authorization is separate from ordinary notification '
                    'permission and can be changed in iOS Settings.'
              : 'MyTasks needs Android exact-alarm access to trigger an alarm '
                    'at your chosen time, including while the phone is idle. '
                    'Android will open a system settings page where you can '
                    'allow or decline access. This permission alone does not '
                    'enable notification display or guarantee delivery on '
                    'every device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(isIos ? 'Continue' : 'Continue to settings'),
          ),
        ],
      ),
    );
    if (shouldContinue != true || !context.mounted) return;

    try {
      await ref.read(alarmPermissionGatewayProvider).requestAccess();
      ref.invalidate(alarmPermissionStatusProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open exact-alarm settings.')),
      );
    }
  }

  Future<void> _openAlarmSystemSettings(BuildContext context) async {
    try {
      await ref.read(alarmPermissionGatewayProvider).openSettings();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open iOS Settings.')),
      );
    }
  }
}

class _PermissionStatusMessage extends StatelessWidget {
  const _PermissionStatusMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon),
      const SizedBox(width: 12),
      Expanded(child: Text(message)),
    ],
  );
}

enum _ReminderSlot { morning, midday, endOfDay }

class _ReminderTimeTile extends StatelessWidget {
  const _ReminderTimeTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final ReminderTime time;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayTime = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: time.hour, minute: time.minute));

    return ListTile(
      enabled: enabled,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        displayTime,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
