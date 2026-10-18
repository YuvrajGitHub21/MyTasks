package com.yuvrajpadhy.mytasks

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/** Receives one-shot alarm events without requiring the Flutter process to stay open. */
class TaskAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(EXTRA_ALARM_ID, 0)
        if (alarmId <= 0) return

        val ringIntent = Intent(context, TaskAlarmRingingService::class.java).apply {
            action = TaskAlarmRingingService.ACTION_START
            putExtras(intent)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(ringIntent)
        } else {
            context.startService(ringIntent)
        }
        TaskAlarmScheduler.consume(context, alarmId)
    }

    companion object {
        const val EXTRA_ALARM_ID = "mytasks.alarm.id"
        const val EXTRA_TRIGGER_AT = "mytasks.alarm.triggerAt"
        const val EXTRA_TITLE = "mytasks.alarm.title"
        const val EXTRA_BODY = "mytasks.alarm.body"
        const val EXTRA_PAYLOAD = "mytasks.alarm.payload"
    }
}

/** Restores pending one-shot alarms after Android or the app package restarts. */
class TaskAlarmBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED
            -> TaskAlarmScheduler.restoreAfterRestart(context)
        }
    }
}
