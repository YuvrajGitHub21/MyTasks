import 'dart:async';

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
  static const _studyBreakChannel = AndroidNotificationChannel(
    'study_breaks',
    'Study breaks',
    description: 'A reminder when a study break ends.',
    importance: Importance.defaultImportance,
  );

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static final StreamController<String> _tapPayloads =
      StreamController<String>.broadcast();
  static String? _launchPayload;

  /// Warm-app notification taps arrive here after plugin initialization.
  static Stream<String> get tapPayloads => _tapPayloads.stream;

  /// Cold-start taps are held until the app's Navigator is ready.
  static String? takeLaunchPayload() {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

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
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _tapPayloads.add(payload);
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = launchDetails?.notificationResponse?.payload;
    }

    // Android 8+ requires every notification to belong to a channel. Creating
    // the same channel on later launches is safe; Android retains its settings.
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_androidChannel);
    await androidPlugin?.createNotificationChannel(_studyBreakChannel);

    _initialized = true;
  }
}
