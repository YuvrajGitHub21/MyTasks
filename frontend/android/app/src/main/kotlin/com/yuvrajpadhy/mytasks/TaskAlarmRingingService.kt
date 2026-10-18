package com.yuvrajpadhy.mytasks

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.provider.Settings

/** Plays the alarm tone only while an occurrence is actively ringing. */
class TaskAlarmRingingService : Service() {
    private var player: MediaPlayer? = null
    private var activeNotificationId: Int = DEFAULT_NOTIFICATION_ID

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopRinging()
                return START_NOT_STICKY
            }
            ACTION_SNOOZE -> {
                snooze(intent)
                stopRinging()
                return START_NOT_STICKY
            }
            ACTION_START -> startRinging(intent)
            else -> stopSelf(startId)
        }
        return START_NOT_STICKY
    }

    private fun startRinging(intent: Intent) {
        val alarmId = intent.getIntExtra(TaskAlarmReceiver.EXTRA_ALARM_ID, 0)
        if (alarmId <= 0) {
            stopSelf()
            return
        }

        activeNotificationId = alarmId
        createAlarmNotificationChannel()
        val notification = buildNotification(intent, alarmId)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                activeNotificationId,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            startForeground(activeNotificationId, notification)
        }
        playAlarmTone()
    }

    private fun buildNotification(intent: Intent, alarmId: Int): Notification {
        val payload = intent.getStringExtra(TaskAlarmReceiver.EXTRA_PAYLOAD).orEmpty()
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(TaskAlarmReceiver.EXTRA_PAYLOAD, payload)
        }
        val openPendingIntent = PendingIntent.getActivity(
            this,
            alarmId,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val stopPendingIntent = actionPendingIntent(ACTION_STOP, intent, alarmId)
        val snoozePendingIntent = actionPendingIntent(ACTION_SNOOZE, intent, alarmId)
        val title = intent.getStringExtra(TaskAlarmReceiver.EXTRA_TITLE) ?: "MyTasks alarm"
        val body = intent.getStringExtra(TaskAlarmReceiver.EXTRA_BODY)
            ?: "A reminder is ready."

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setCategory(Notification.CATEGORY_ALARM)
            .setPriority(Notification.PRIORITY_MAX)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setContentIntent(openPendingIntent)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSound(null)
            .addAction(Notification.Action.Builder(null, "Snooze 10 min", snoozePendingIntent).build())
            .addAction(Notification.Action.Builder(null, "Stop", stopPendingIntent).build())
            .build()
    }

    private fun actionPendingIntent(action: String, source: Intent, alarmId: Int): PendingIntent {
        val actionIntent = Intent(this, TaskAlarmRingingService::class.java).apply {
            this.action = action
            putExtras(source)
        }
        return PendingIntent.getService(
            this,
            alarmId xor if (action == ACTION_SNOOZE) SNOOZE_REQUEST_MASK else STOP_REQUEST_MASK,
            actionIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun createAlarmNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Task alarms",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Ringing task reminders that you can stop or snooze."
                setSound(null, null) // The foreground service plays the alarm tone.
                enableVibration(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun playAlarmTone() {
        releasePlayer()
        val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: Settings.System.DEFAULT_NOTIFICATION_URI
        player = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            setDataSource(this@TaskAlarmRingingService, alarmUri)
            isLooping = true
            setOnPreparedListener { it.start() }
            setOnErrorListener { _, _, _ ->
                stopRinging()
                true
            }
            prepareAsync()
        }
    }

    private fun snooze(intent: Intent) {
        val alarmId = intent.getIntExtra(TaskAlarmReceiver.EXTRA_ALARM_ID, 0)
        val title = intent.getStringExtra(TaskAlarmReceiver.EXTRA_TITLE) ?: "MyTasks alarm"
        val body = intent.getStringExtra(TaskAlarmReceiver.EXTRA_BODY) ?: "A reminder is ready."
        val payload = intent.getStringExtra(TaskAlarmReceiver.EXTRA_PAYLOAD).orEmpty()
        if (alarmId > 0) {
            TaskAlarmScheduler.scheduleSnooze(
                this,
                TaskAlarmScheduler.AlarmRecord(
                    id = alarmId,
                    triggerAtMillis = intent.getLongExtra(
                        TaskAlarmReceiver.EXTRA_TRIGGER_AT,
                        System.currentTimeMillis(),
                    ),
                    title = title,
                    body = body,
                    payload = payload,
                    parentAlarmId = intent.getIntExtra(EXTRA_PARENT_ALARM_ID, 0)
                        .takeIf { it > 0 },
                ),
            )
        }
    }

    private fun stopRinging() {
        releasePlayer()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun releasePlayer() {
        player?.let { current ->
            try {
                if (current.isPlaying) current.stop()
            } catch (_: IllegalStateException) {
                // The asynchronous player may not be prepared yet.
            }
            current.release()
        }
        player = null
    }

    override fun onDestroy() {
        releasePlayer()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val ACTION_START = "com.yuvrajpadhy.mytasks.alarm.START"
        const val ACTION_STOP = "com.yuvrajpadhy.mytasks.alarm.STOP"
        const val ACTION_SNOOZE = "com.yuvrajpadhy.mytasks.alarm.SNOOZE"
        private const val EXTRA_PARENT_ALARM_ID = "mytasks.alarm.parentId"
        private const val CHANNEL_ID = "task_alarms"
        private const val DEFAULT_NOTIFICATION_ID = 70001
        private const val STOP_REQUEST_MASK = 0x40000000
        private const val SNOOZE_REQUEST_MASK = 0x20000000
    }
}
