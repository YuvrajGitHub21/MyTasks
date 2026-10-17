import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

/// Initializes the notification plugin and the app's scheduling time zone.
///
/// This class only prepares platform support. It does not request permission
/// or schedule notifications.
class LocalNotificationInitializer {
  LocalNotificationInitializer({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const schedulingTimeZone = 'Asia/Kolkata';
  static const _androidChannel = AndroidNotificationChannel(
    'task_reminders',
    'Task reminders',
    description: 'Reminders that help you plan and log your tasks.',
    importance: Importance.defaultImportance,
  );

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // The bundled IANA database lets scheduling use IST regardless of the
    // device's current time-zone setting or travel location.
    timezone_data.initializeTimeZones();
    timezone.setLocalLocation(timezone.getLocation(schedulingTimeZone));

    // Keep OS permission prompts for the reminder onboarding/settings flow.
    // In particular, initializing the app must not prompt on first launch.
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    // Android 8+ requires every notification to belong to a channel. Creating
    // the same channel on later launches is safe; Android retains its settings.
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }
}
