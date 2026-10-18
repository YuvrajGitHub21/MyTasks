package com.yuvrajpadhy.mytasks

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

/** Stores local alarm metadata and registers one-shot AlarmManager alarms. */
internal object TaskAlarmScheduler {
    private const val PREFERENCES = "mytasks_exact_alarms"
    private const val ALARMS_JSON = "alarms"
    private const val SNOOZE_EVENTS_JSON = "snoozeEvents"
    private const val EXTRA_ALARM_ID = "mytasks.alarm.id"
    private const val EXTRA_TRIGGER_AT = "mytasks.alarm.triggerAt"
    private const val EXTRA_TITLE = "mytasks.alarm.title"
    private const val EXTRA_BODY = "mytasks.alarm.body"
    private const val EXTRA_PAYLOAD = "mytasks.alarm.payload"
    private const val EXTRA_PARENT_ALARM_ID = "mytasks.alarm.parentId"
    private const val NEXT_SNOOZE_ID = "nextSnoozeId"
    private const val FIRST_SNOOZE_ID = 2_000_000_000
    private const val LAST_SNOOZE_ID = Int.MAX_VALUE
    private const val SNOOZE_MILLIS = 10 * 60 * 1000L

    data class AlarmRecord(
        val id: Int,
        val triggerAtMillis: Long,
        val title: String,
        val body: String,
        val payload: String,
        val parentAlarmId: Int? = null,
    )

    data class SnoozeEvent(
        val id: Int,
        val parentAlarmId: Int,
        val triggerAtMillis: Long,
        val createdAtMillis: Long,
        val payload: String,
    )

    @Synchronized
    fun schedule(context: Context, record: AlarmRecord) {
        require(record.id > 0) { "Alarm ID must be positive." }
        require(record.triggerAtMillis > System.currentTimeMillis()) {
            "Alarm time must be in the future."
        }

        val alarmManager = context.getSystemService(AlarmManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            !alarmManager.canScheduleExactAlarms()
        ) {
            throw SecurityException("Exact alarm access has not been granted.")
        }

        save(context, record)
        val operation = alarmPendingIntent(context, record)
        val showIntent = openAppPendingIntent(context, record)
        alarmManager.setAlarmClock(
            AlarmManager.AlarmClockInfo(record.triggerAtMillis, showIntent),
            operation,
        )
    }

    @Synchronized
    fun cancel(context: Context, id: Int) {
        val records = load(context)
        val canceled = records.filter { it.id == id || it.parentAlarmId == id }
        val alarmManager = context.getSystemService(AlarmManager::class.java)
        canceled.forEach { record ->
            alarmManager.cancel(alarmPendingIntent(context, record))
        }
        val canceledIds = canceled.map { it.id }.toSet()
        saveAll(context, records.filterNot { it.id in canceledIds })
        saveSnoozeEvents(context, pendingSnoozeEvents(context).filterNot { it.id in canceledIds })
    }

    @Synchronized
    fun scheduleSnooze(context: Context, source: AlarmRecord) {
        val createdAt = System.currentTimeMillis()
        val parentId = source.parentAlarmId ?: source.id
        val snooze = source.copy(
            id = allocateSnoozeId(context),
            triggerAtMillis = createdAt + SNOOZE_MILLIS,
            parentAlarmId = parentId,
        )
        schedule(context, snooze)
        saveSnoozeEvent(context, SnoozeEvent(
            id = snooze.id,
            parentAlarmId = parentId,
            triggerAtMillis = snooze.triggerAtMillis,
            createdAtMillis = createdAt,
            payload = snooze.payload,
        ))
    }

    @Synchronized
    fun pendingSnoozeEvents(context: Context): List<SnoozeEvent> {
        val raw = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getString(SNOOZE_EVENTS_JSON, null) ?: return emptyList()
        return try {
            val array = JSONArray(raw)
            (0 until array.length()).map { index ->
                val value = array.getJSONObject(index)
                SnoozeEvent(
                    id = value.getInt("id"),
                    parentAlarmId = value.getInt("parentAlarmId"),
                    triggerAtMillis = value.getLong("triggerAtMillis"),
                    createdAtMillis = value.getLong("createdAtMillis"),
                    payload = value.getString("payload"),
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    @Synchronized
    fun acknowledgeSnoozeEvent(context: Context, id: Int) {
        saveSnoozeEvents(context, pendingSnoozeEvents(context).filterNot { it.id == id })
    }

    @Synchronized
    fun consume(context: Context, id: Int) {
        saveAll(context, load(context).filterNot { it.id == id })
    }

    @Synchronized
    fun restoreAfterRestart(context: Context) {
        val now = System.currentTimeMillis()
        load(context).forEach { record ->
            if (record.triggerAtMillis > now) {
                try {
                    val alarmManager = context.getSystemService(AlarmManager::class.java)
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                        alarmManager.canScheduleExactAlarms()
                    ) {
                        alarmManager.setAlarmClock(
                            AlarmManager.AlarmClockInfo(
                                record.triggerAtMillis,
                                openAppPendingIntent(context, record),
                            ),
                            alarmPendingIntent(context, record),
                        )
                    }
                } catch (_: SecurityException) {
                    // Permission may have been revoked since this alarm was saved.
                    // Reminder reconciliation can offer the user the access flow.
                }
            } else {
                consume(context, record.id)
            }
        }
    }

    private fun alarmPendingIntent(context: Context, record: AlarmRecord): PendingIntent {
        val intent = Intent(context, TaskAlarmReceiver::class.java).apply {
            action = "com.yuvrajpadhy.mytasks.ALARM.${record.id}"
            putExtra(EXTRA_ALARM_ID, record.id)
            putExtra(EXTRA_TRIGGER_AT, record.triggerAtMillis)
            putExtra(EXTRA_TITLE, record.title)
            putExtra(EXTRA_BODY, record.body)
            putExtra(EXTRA_PAYLOAD, record.payload)
            record.parentAlarmId?.let { putExtra(EXTRA_PARENT_ALARM_ID, it) }
        }
        return PendingIntent.getBroadcast(
            context,
            record.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun openAppPendingIntent(context: Context, record: AlarmRecord): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra(EXTRA_PAYLOAD, record.payload)
        }
        return PendingIntent.getActivity(
            context,
            record.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun save(context: Context, record: AlarmRecord) {
        saveAll(context, load(context).filterNot { it.id == record.id } + record)
    }

    private fun saveAll(context: Context, records: List<AlarmRecord>) {
        val array = JSONArray()
        records.forEach { record ->
            array.put(
                JSONObject()
                    .put("id", record.id)
                    .put("triggerAtMillis", record.triggerAtMillis)
                    .put("title", record.title)
                    .put("body", record.body)
                    .put("payload", record.payload)
                    .put("parentAlarmId", record.parentAlarmId ?: 0),
            )
        }
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(ALARMS_JSON, array.toString())
            .apply()
    }

    private fun saveSnoozeEvent(context: Context, event: SnoozeEvent) {
        val events = pendingSnoozeEvents(context).filterNot { it.id == event.id } + event
        saveSnoozeEvents(context, events)
    }

    private fun saveSnoozeEvents(context: Context, events: List<SnoozeEvent>) {
        val array = JSONArray()
        events.forEach { event ->
            array.put(JSONObject()
                .put("id", event.id)
                .put("parentAlarmId", event.parentAlarmId)
                .put("triggerAtMillis", event.triggerAtMillis)
                .put("createdAtMillis", event.createdAtMillis)
                .put("payload", event.payload))
        }
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit().putString(SNOOZE_EVENTS_JSON, array.toString()).apply()
    }

    private fun load(context: Context): List<AlarmRecord> {
        val raw = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getString(ALARMS_JSON, null) ?: return emptyList()
        return try {
            val array = JSONArray(raw)
            (0 until array.length()).map { index ->
                val value = array.getJSONObject(index)
                AlarmRecord(
                    id = value.getInt("id"),
                    triggerAtMillis = value.getLong("triggerAtMillis"),
                    title = value.getString("title"),
                    body = value.getString("body"),
                    payload = value.getString("payload"),
                    parentAlarmId = value.optInt("parentAlarmId", 0).takeIf { it > 0 },
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun allocateSnoozeId(context: Context): Int {
        val preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        val usedIds = load(context).map { it.id }.toSet()
        var candidate = preferences.getInt(NEXT_SNOOZE_ID, FIRST_SNOOZE_ID)
        repeat(LAST_SNOOZE_ID - FIRST_SNOOZE_ID + 1) {
            if (candidate !in usedIds) {
                val next = if (candidate == LAST_SNOOZE_ID) FIRST_SNOOZE_ID else candidate + 1
                preferences.edit().putInt(NEXT_SNOOZE_ID, next).apply()
                return candidate
            }
            candidate = if (candidate == LAST_SNOOZE_ID) FIRST_SNOOZE_ID else candidate + 1
        }
        throw IllegalStateException("No native alarm IDs are available for snoozes.")
    }
}
