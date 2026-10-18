package com.yuvrajpadhy.mytasks

import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var taskAlarmChannel: MethodChannel? = null
    private var focusDisplayChannel: MethodChannel? = null
    private var savedFocusBrightness: Float? = null
    private var hadKeepScreenOnFlag = false
    private var savedInterruptionFilter: Int? = null
    private var pendingAlarmPayload: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        taskAlarmChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        try {
                            val arguments = call.arguments as? Map<*, *>
                                ?: throw IllegalArgumentException("Alarm arguments are missing.")
                            TaskAlarmScheduler.schedule(
                                this,
                                TaskAlarmScheduler.AlarmRecord(
                                    id = (arguments["id"] as Number).toInt(),
                                    triggerAtMillis = (arguments["triggerAtMillis"] as Number).toLong(),
                                    title = arguments["title"] as String,
                                    body = arguments["body"] as String,
                                    payload = arguments["payload"] as String,
                                ),
                            )
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("ALARM_SCHEDULE_FAILED", error.message, null)
                        }
                    }
                    "cancelAlarm" -> {
                        try {
                            val id = (call.argument<Number>("id")
                                ?: throw IllegalArgumentException("Alarm ID is missing.")).toInt()
                            TaskAlarmScheduler.cancel(this, id)
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("ALARM_CANCEL_FAILED", error.message, null)
                        }
                    }
                    "takePendingAlarmPayload" -> {
                        val payload = pendingAlarmPayload
                        pendingAlarmPayload = null
                        result.success(payload)
                    }
                    "getPendingSnoozes" -> {
                        result.success(TaskAlarmScheduler.pendingSnoozeEvents(this).map { event ->
                            mapOf(
                                "id" to event.id,
                                "parentAlarmId" to event.parentAlarmId,
                                "triggerAtMillis" to event.triggerAtMillis,
                                "createdAtMillis" to event.createdAtMillis,
                                "payload" to event.payload,
                            )
                        })
                    }
                    "acknowledgeSnooze" -> {
                        try {
                            val id = (call.argument<Number>("id")
                                ?: throw IllegalArgumentException("Snooze ID is missing.")).toInt()
                            TaskAlarmScheduler.acknowledgeSnoozeEvent(this, id)
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("SNOOZE_ACKNOWLEDGE_FAILED", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
        focusDisplayChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FOCUS_DISPLAY_CHANNEL_NAME,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "enterFocus" -> {
                            if (savedFocusBrightness == null) {
                                savedFocusBrightness = window.attributes.screenBrightness
                                hadKeepScreenOnFlag =
                                    window.attributes.flags and android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON != 0
                            }
                            window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            result.success(null)
                        }
                        "setFocusBrightness" -> {
                            val brightness = call.arguments as? Number
                                ?: throw IllegalArgumentException("Brightness value is missing.")
                            window.attributes = window.attributes.apply {
                                screenBrightness = brightness.toFloat().coerceIn(0f, 1f)
                            }
                            result.success(null)
                        }
                        "restoreFocusBrightness" -> {
                            restoreFocusBrightness()
                            result.success(null)
                        }
                        "exitFocus" -> {
                            setFocusSilence(false)
                            restoreFocusBrightness()
                            if (!hadKeepScreenOnFlag) {
                                window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            }
                            savedFocusBrightness = null
                            result.success(null)
                        }
                        "hasNotificationPolicyAccess" -> {
                            result.success(
                                getSystemService(NotificationManager::class.java)
                                    .isNotificationPolicyAccessGranted,
                            )
                        }
                        "openNotificationPolicySettings" -> {
                            startActivity(Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS))
                            result.success(null)
                        }
                        "setFocusSilence" -> {
                            val enabled = call.arguments as? Boolean
                                ?: throw IllegalArgumentException("Silence setting is missing.")
                            setFocusSilence(enabled)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("FOCUS_DISPLAY_FAILED", error.message, null)
                }
            }
        }
        captureAlarmPayload(intent)
    }

    private fun restoreFocusBrightness() {
        val saved = savedFocusBrightness ?: return
        window.attributes = window.attributes.apply { screenBrightness = saved }
    }

    private fun setFocusSilence(enabled: Boolean) {
        val manager = getSystemService(NotificationManager::class.java)
        if (!manager.isNotificationPolicyAccessGranted) {
            if (enabled) {
                throw SecurityException("Do Not Disturb access has not been granted.")
            }
            return
        }
        if (enabled) {
            if (Build.VERSION.SDK_INT < 35 && savedInterruptionFilter == null) {
                savedInterruptionFilter = manager.currentInterruptionFilter
            }
            manager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)
        } else {
            if (Build.VERSION.SDK_INT >= 35) {
                // On Android 15+, ALL deactivates MyTasks' implicit rule while
                // preserving any Do Not Disturb rules the user enabled.
                manager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
            } else {
                savedInterruptionFilter?.let(manager::setInterruptionFilter)
            }
            savedInterruptionFilter = null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureAlarmPayload(intent)
        pendingAlarmPayload?.let { payload ->
            taskAlarmChannel?.invokeMethod("alarmOpened", payload)
        }
    }

    private fun captureAlarmPayload(intent: Intent?) {
        val alarmId = intent?.getIntExtra(TaskAlarmReceiver.EXTRA_ALARM_ID, 0) ?: 0
        if (alarmId > 0) {
            // Opening the alarm notification is an explicit user action. Stop
            // that occurrence before routing to its task screen.
            startService(Intent(this, TaskAlarmRingingService::class.java).apply {
                action = TaskAlarmRingingService.ACTION_STOP
                putExtra(TaskAlarmReceiver.EXTRA_ALARM_ID, alarmId)
            })
        }
        val payload = intent?.getStringExtra(TaskAlarmReceiver.EXTRA_PAYLOAD)
        if (payload != null) pendingAlarmPayload = payload
    }

    companion object {
        const val CHANNEL_NAME = "com.yuvrajpadhy.mytasks/task_alarm"
        const val FOCUS_DISPLAY_CHANNEL_NAME = "com.mytasks/focus_display"
    }
}
