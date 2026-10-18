package com.yuvrajpadhy.mytasks

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var taskAlarmChannel: MethodChannel? = null
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
        captureAlarmPayload(intent)
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
        val payload = intent?.getStringExtra(TaskAlarmReceiver.EXTRA_PAYLOAD)
        if (payload != null) pendingAlarmPayload = payload
    }

    companion object {
        const val CHANNEL_NAME = "com.yuvrajpadhy.mytasks/task_alarm"
    }
}
