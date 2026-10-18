# M3 — Detailed Implementation Plan: Local Reminders and Alarm Prompts

**Project:** MyTasks mobile application  
**Status:** Reminder rules, settings, Android alarms, snooze persistence, and iOS AlarmKit source are implemented. Android debug build passes. Device behavior and iOS/macOS/Xcode compilation and runtime checks remain before M3 can be accepted.
**Date:** 18 October 2026  
**Owner:** Project owner and assistant. The owner explicitly waived the five-file batch limit once for this M3 completion pass; the ordinary project limit remains in effect for later work.
**Prerequisite:** M2 Android guest experience completed.  
**Baseline:** [FRS](FRS.md), [HLD](HLD.md), [LLD](LLD.md), [Implementation Roadmap](Implementation-Roadmap.md), [UI Flow and Wireframes](UI-Flow-and-Wireframe.md), [M2 plan](M2-Implementation-Plan.md), and [Working Agreement](Working-Agreement.md).

## 1. Goal

Add configurable local reminders for the guest profile based on encrypted local task/progress data. Keep the 09:00 daily summary informational. Present actionable no-task and end-of-day logging prompts as OS-managed alarm-style alerts with Open, Snooze (10 minutes), and Stop/Dismiss actions. Protect task names, avoid duplicates, work offline, and keep core task use available when authorization is denied.

M3 is a mobile-only, guest-mode milestone. It does not add accounts, synchronization, backend reminder workers, or a continuously running foreground service. The existing normal notification implementation is already present but does not meet this updated alarm requirement. M6 must schedule signed-in local alarms from the latest synchronized device copy; server push may remain a supplemental summary and is not the precise alarm mechanism.

## 2. Decisions for M3

| Decision | M3 choice | Reason |
|---|---|---|
| Delivery boundary | Keep reminder rules and schedule identity behind application-owned contracts; implement platform-specific alarm adapters outside the domain. Use the existing notification plugin only for the informational summary and fallback unless a verified adapter supports the required alarm behavior. | Domain rules stay portable while Android exact alarms and iOS AlarmKit have different authorization and presentation models. |
| Local scheduling time zone | Always schedule using the IANA zone `Asia/Kolkata`; device travel/time-zone changes do not change the reminder's intended IST wall-clock time. | The initial release explicitly uses IST and defers travel-aware scheduling. |
| Time-zone conversion | Use `timezone` and construct dates with its `Asia/Kolkata` location. Initialize the bundled tz database once during app startup. | A scheduled wall-clock time must be converted using an explicit zone; the package defaults its local zone to UTC unless configured. |
| Reminder times | No-task reminders: 09:00 and 12:00 IST. End-of-day log reminder: 22:00 IST. All are configurable in settings. | These are the approved requirements and defaults. |
| Morning summary | Reuse the first configured no-task slot (default 09:00): show one count-only daily summary when active tasks exist; show the “assign today's work” prompt when there are none. Never send both in that slot. At the second configured no-task time (default 12:00), send only the no-task prompt if the day is still empty. | This satisfies both the daily summary and no-task reminder requirements without duplicate morning notifications. |
| Reminder preference default | The guest reminder preference starts enabled, matching the approved wireframe; show a contextual explanation before the first OS permission request. If permission is denied, leave tasks usable and show the blocked delivery status in settings. | The user originally requested reminders; an in-app setting and OS permission still let them opt out. |
| Android alarm precision | Use exact user-facing scheduling only after contextual explanation and user-granted `SCHEDULE_EXACT_ALARM` access. Do not select `USE_EXACT_ALARM` until public-store eligibility is reviewed. If access is denied, report alarms as unavailable and offer standard notifications only when the saved `allowStandardNotificationFallback` preference is on. It defaults off. | Android treats exact alarms as special access; the user can decline. This avoids silently substituting a notification for an alarm. |
| iOS alarm capability | Use AlarmKit with separate authorization on iOS 26+; on iOS 15–25 or after denial, report alarms as unavailable and offer standard local notifications only as an explicit opt-in. | This preserves the project's iOS 15 minimum while using the native alarm UI where the OS supports it. |
| Alarm actions | Provide Open, Snooze for 10 minutes, and Stop/Dismiss this occurrence. Alarm sound continues until the user responds, subject to platform limits. Open routes a no-task alarm to task creation and an end-of-day alarm to Today. | The user can take the intended action from the alert; stopping an occurrence does not disable future reminders. |
| Alarm presentation limits | Full-screen/lock-screen presentation is conditional on OS and public-store policy. Never request Do Not Disturb bypass or claim guaranteed delivery. | Alarm and full-screen permissions are intentionally restricted; the standard alarm notification must remain actionable without full-screen access. |
| Sound/vibration | Let OS alarm/channel settings control sound and vibration; quiet hours remain an app-level scheduling rule. | Android channel controls are user-owned and immutable after creation; AlarmKit has its own system authorization/presentation. |
| Default lock-screen content | Always use a generic title/body and an optional task count; never include topic, subtopic, or description. | The FRS requires count-only privacy-safe lock-screen summaries. Notification taps open the relevant app view. |
| Permission timing | Explain the value in the reminder setup flow, then request OS permission only when the user turns reminders on/continues setup. Never prompt on the first app launch. | This gives context and preserves a useful guest app if permission is declined. Android 13+ uses runtime notification permission; iOS authorization can be denied or changed in Settings. |
| Sticky task-list notification | Do not build a permanent task-list notification or foreground service in M3. Use dismissible, scheduled reminders and the Today screen. | Android and iOS control notification visibility; the app cannot promise an unhideable notification. There is no valid long-running foreground operation for M3. |
| Schedule horizon | Reconcile one-shot requests for the rest of today and the next IST calendar day only, at most six requests including the morning-summary/no-task alternatives. Recompute on every relevant local change and app start/resume. | A short rolling horizon makes state changes easy to reconcile and stays far below platform pending-notification limits. It avoids repeating notifications whose eligibility has not been checked against current local data. |
| Task-content telemetry | No cloud logging or analytics is added. Diagnostics may record reminder type, date, result, and platform error without task content. | M3 is local-only and task names are private. The app currently has no centralized logging service. |

### Package versions at plan preparation

The app uses `flutter_local_notifications 22.3.2` and `timezone 0.11.2` for informational summaries and explicitly opted-in fallbacks. Actionable Android alarms use the native `AlarmManager` adapter; iOS 26+ uses a native AlarmKit adapter through a Flutter method channel. The app's iOS deployment target remains 15.0: runtime availability checks report AlarmKit unavailable below iOS 26. Android exact-alarm access and iOS AlarmKit authorization are requested contextually. Android full-screen behavior remains conditional on OS and store eligibility. The iOS source requires an Xcode 26 SDK to compile and must be verified on macOS.

References: [Android alarm scheduling](https://developer.android.com/develop/background-work/services/alarms), [Android exact alarm access](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms), [Android full-screen intent limits](https://developer.android.com/about/versions/14/behavior-changes-14), [Apple AlarmKit](https://developer.apple.com/documentation/AlarmKit), [Apple AlarmKit authorization and scheduling](https://developer.apple.com/documentation/AlarmKit/scheduling-an-alarm-with-alarmkit), and [Apple local notifications](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app).

## 3. Reminder rules

All predicates use `TaskDate.todayInIst()` and date-only comparisons. Event timestamps remain UTC instants; schedule times are converted to `Asia/Kolkata` before passing them to the platform plugin. The first configured no-task slot (default 09:00) produces exactly one notification: a generic count-only summary when active work exists, or a no-task prompt when it does not.

### 3.1 No-task prompts

- At the first configured slot (default 09:00), show the count-only daily summary if an active task exists; otherwise show the no-task prompt. At the second configured slot (default 12:00), show a no-task prompt only if there is still no open task with `startDate <= today's IST date`.
- The 09:00 summary and no-task prompt are mutually exclusive and share one stable morning-slot identity, so they cannot both appear for the same date.
- A task starting tomorrow or later does not count as work assigned for today.
- Completed tasks do not count as active work.
- An overdue open task still counts as today's active work, matching M2 list classification; it suppresses the “assign a task” prompt.
- The 12:00 slot has its own identity. A delivered 09:00 no-task prompt does not suppress the 12:00 slot if no task is created.
- When a task is created, edited, deleted, completed, or reopened, reconcile the rest of today's and tomorrow's scheduled prompts. Cancel any no-task prompt that is no longer eligible.

### 3.2 End-of-day logging prompt

- At the configured time (default 22:00), find open tasks whose start date has arrived.
- A task needs a log if it has no progress entry whose occurrence date in IST is today. A progress entry uses one method (percentage, units, or note) and does not itself complete the task.
- Show one generic reminder if at least one active task still needs a log. One logged task suppresses the prompt for that task only; other unlogged tasks remain eligible.
- A task completed before the scheduled reminder is excluded. Reopening it before 22:00 makes it eligible again if it has no log for today.
- Progress create/update/delete and task lifecycle changes trigger reconciliation.

### 3.3 Quiet hours

- Quiet hours are optional and disabled by default.
- If a reminder falls inside quiet hours, defer it to the quiet-hours end only if that end is on the same IST date and occurs after the configured reminder time.
- If quiet hours end on the next IST date, suppress that day's reminder; do not deliver a stale prompt after midnight.
- Store the original reminder slot separately from the effective delivery time so deferral does not create a duplicate reminder identity.

### 3.4 Idempotency and stale requests

- Use an identity key containing local profile, logical slot type, IST date, and configured time (for example `guest/morning_slot/2026-10-18/0900`). The morning slot's content kind (summary or no-task) can change as task state changes without creating a second notification for the same slot.
- Persist the platform notification ID associated with each identity. Allocate IDs through the local ledger rather than truncating a hash and risking collisions.
- Scheduling the same ID again replaces the pending request; cancel ledger entries that are no longer in the computed desired set.
- Reconcile after task create/update/delete, progress create/update/delete, complete/reopen, preference changes, app startup/resume, IST date rollover, and supported reboot/package-update events.
- Before scheduling, discard requests whose IST date has passed. A reminder remains best effort: OS sleep, vendor background limits, permission, and network-independent platform scheduling can affect delivery time.

## 4. Architecture and data design

Keep the Onion dependency direction already used by M2:

```text
Reminder settings UI
        ↓
Application use cases: save preferences, evaluate rules, reconcile, handle tap
        ↓
Domain entities/rules/contracts: preferences, eligibility, quiet hours, schedule identity
        ↑
Drift preference/schedule-ledger adapter     Platform alarm/notification adapters
        ↑                                      ↑
        └────────── app composition root ─────┘
```

The domain layer must not import Flutter widgets, Drift, notification packages, or platform APIs. The application layer coordinates local task/progress repositories, the reminder-preference repository, and an alarm-scheduler port. Outer adapters translate desired schedules into Android/iOS alarm and notification requests.

### Local schema

M2 introduced Drift schema version 1. M3 adds a version-2 migration that preserves all existing encrypted task data and adds:

- `ReminderPreferences`: one row per local profile, with enabled state; no-task times; end-of-day time; optional quiet-hours start/end; `allowStandardNotificationFallback` (default false); legacy sound/vibration columns; and update time. Sound/vibration columns remain for schema compatibility but do not drive OS channel/alarm settings or appear as app toggles; remove them only in a separately planned schema migration.
- `ScheduledReminderRequests`: a stable schedule identity, platform integer ID, logical slot type, content kind, IST local date, configured slot, effective scheduled instant, and update time. Add uniqueness for identity and notification ID. The table is a reconciliation ledger, not a history of reminders that were shown.

**Implementation checkpoint (18 October 2026):** `AppDatabase` now declares both tables at schema version 2. The version-1 upgrade creates only these new tables, so it does not rewrite existing profile, task, progress, or lifecycle rows. Drift code generation completed for `app_database.g.dart`. A disposable in-memory SQLite database shaped like schema version 1 was upgraded successfully: its sample profile, task, progress, and lifecycle rows remained present, both reminder tables were created, and `user_version` became 2. This check validates the Drift migration path and row preservation on SQLite; it does not exercise the encrypted database connection or the database on a physical phone.

**Fallback preference persistence (18 October 2026):** The app now uses schema version 3. The version-2 upgrade adds `allow_standard_notification_fallback` to `reminder_preferences` with a database default of false, preserving existing rows and task data. The domain model, Drift repository, and `SaveReminderPreferences` use case carry this value through reads, writes, and unrelated setting changes. The settings screen exposes an explicit opt-in and explains that standard notifications can be late and do not ring continuously. The current scheduler honors this preference on both platforms. No automated tests or encrypted on-device migration check were run for this change.

The domain record and Drift adapters map reminder preferences and scheduled-request identities to the version-2 tables. The schedule repository preserves notification IDs for unchanged identities and retains obsolete ledger rows until the platform adapter confirms cancellation, so a retry can still discover IDs after an interrupted reconciliation. Riverpod wires these repositories to the encrypted database and composes the clock, calculate, save, and reconcile use cases. Schema versions 3 and 4 add the fallback preference and snoozed-occurrence ledger. A disposable SQLite v1-to-v2 migration check passed as recorded above; encrypted on-device migration verification remains pending.

Test the migration from an existing version-1 database without resetting user data. Keep all queries profile-scoped. OS pending requests and this ledger must reconcile safely after a crash between a database write and a platform plugin call.

## 5. Implementation phases and teaching checkpoints

Each implementation phase is split into approved batches of at most five changed files. Before each batch, state the exact files, concept, behavior, and verification command. Generated Drift files and package lockfiles count toward the limit. Do not run Git commands unless the owner explicitly asks.

### M3-A — Domain rules and application contracts

**Goal:** Make reminder decisions testable without a phone or notification plugin.

Define reminder preferences, reminder types, desired reminder requests, schedule identity, and pure eligibility/quiet-hours rules. Add domain-owned repository and scheduler interfaces and application use cases for saving preferences, calculating desired requests, reconciling platform schedules, and handling notification taps. Inject a clock so behavior can be evaluated around 09:00, noon, 22:00, and IST midnight.

**Learning:** An outbound port is an interface the application owns; the local notification plugin is only one adapter. A pure predicate turns a time-based requirement into inputs and outputs that can be reviewed independently of Android/iOS behavior.

**Review gate:** Confirm per-task logging suppression, overdue tasks, reopened tasks, quiet-hours crossing midnight, and same-slot duplicate identity against the FRS/LLD before connecting persistence.

### M3-B — Version-2 local preferences and schedule ledger

**Goal:** Save guest reminder choices and recover the desired/pending schedule after app restarts.

Add Drift tables and the version-1-to-version-2 migration, preference/schedule repositories, profile-scoped providers, and generated code. Migration verification must use a copy of a version-1 database and confirm tasks, progress, lifecycle events, profile IDs, and encrypted key behavior remain intact.

**Learning:** A migration evolves a database without discarding existing records; a repository lets the scheduler save intent without knowing SQL.

### M3-C — Notification and alarm foundation (implemented; verification pending)

**Goal:** Initialize ordinary notification support for daily summaries and fallback reminders; this foundation is implemented. Alarm-specific platform adapters are a new pending slice.

The prototype foundation uses `flutter_local_notifications: ^22.3.2` and `timezone: ^0.11.2` (resolved exact versions are in `frontend/pubspec.lock`). Android declares the plugin's scheduled-notification receiver and boot/package-replacement recovery receiver. It currently does not declare exact-alarm or full-screen-intent access and therefore does not yet meet the new alarm requirement. Do Not Disturb and foreground-service access remain out of scope.

The Dart startup initializer is in `frontend/lib/data/notifications/local_notification_initializer.dart` and is awaited before the Flutter UI starts. It initializes the bundled IANA time-zone data, sets the default scheduling zone to `Asia/Kolkata`, and initializes Android/iOS plugin settings with iOS permission prompts disabled. It also creates Android's standard `Task reminders` channel. If setup fails, startup logs the error in debug output and still opens the task app. Actionable reminders now use Android exact alarms or iOS AlarmKit when authorized; ordinary notifications remain for summaries and explicit fallback.

The Android initializer creates the normal `Task reminders` channel with default importance. On iOS, `AppDelegate.swift` assigns the notification-center delegate and registers the AlarmKit method channel through Flutter's implicit engine bridge. AlarmKit authorization, one-shot scheduling/cancellation, custom snooze actions, and alarm-open routing are implemented in native Swift; iOS build/runtime verification remains unavailable on this Windows host.

The initializer, notification tap callback, Android exact-alarm scheduler, native ringing engine, snooze event ledger, iOS AlarmKit channel, and iOS authorization/scheduling source are implemented. The Android alarm engine uses a separate alarm notification channel from the informational summary channel. Platform behavior still needs physical-device validation; iOS source still needs macOS/Xcode verification.

**Startup verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after startup initialization was added and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk`. The cached Android build completed in about 40 seconds. This verifies compilation, not runtime notification delivery; no automated tests or physical-device checks were run for this batch.

**Channel and delegate verification (18 October 2026):** The Android debug APK rebuilt successfully after channel creation was added. This confirms Android compilation of the channel setup. The iOS delegate edit could not be compiled in the Windows environment; verify it on macOS/Xcode before claiming iOS support.

The `FlutterLocalNotificationScheduler` adapter maps reminder requests to generic, privacy-safe content, converts UTC instants to the `Asia/Kolkata` zone, and uses stable IDs from the encrypted Drift ledger. Informational summaries use standard notifications. Actionable requests use Android exact alarms or iOS AlarmKit only when authorized; standard notifications are a fallback only when the saved opt-in is true. It cancels obsolete platform requests before removing their ledger rows, so failed cancellation can be retried.

Task create, edit, and delete, progress create/edit/delete, task complete/reopen, and reminder preference saves trigger best-effort reconciliation after a successful database write. Startup/resume reconciliation is wired through `ReminderReconciliationObserver`; it imports durable snooze events before reconciling. Validation failures and no-op updates/deletes/transitions do not reconcile. Reminder/plugin failures are caught and logged so a committed user action is still reported as successful; the app does not yet have a centralized logging service.

`ReminderReconciliationObserver` now runs one reconciliation after the first app frame and whenever the app resumes. It serializes overlapping requests and repeats once if another resume occurs during a reconciliation. Profile/database/plugin failures are logged as best-effort reminder errors and do not block task navigation.

**Task-mutation verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after the callback wiring was formatted, producing `frontend/build/app/outputs/flutter-apk/app-debug.apk`. This confirms Android compilation only. No automated tests or physical-device reminder checks were run.

**Progress/lifecycle verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after progress and completion/reopen callbacks were wired. This confirms Android compilation only; no automated tests or physical-device reminder checks were run.

**Startup/resume verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after adding the reconciliation observer. This confirms Android compilation only; lifecycle behavior and actual notification delivery were not manually verified on a device.

**Adapter verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after formatting and the adapter syntax correction, producing `frontend/build/app/outputs/flutter-apk/app-debug.apk`. This confirms Android compilation only. No automated tests or device notification delivery checks were run.

**Verification (18 October 2026):** `flutter pub get` resolved the dependencies successfully, and `flutter build apk --debug --no-pub` completed successfully with the project JDK 25 and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk`. The first Android build took about 4.5 minutes while Gradle initialized/downloaded dependencies. No automated tests were run. This confirms Android compilation of the plugin/platform setup; it does not yet prove notification delivery or reboot recovery on a device.

**Learning:** Flutter plugins bridge Dart code to native Android/iOS APIs. Android notification channels are created once and users control their sound/visibility settings. Desugaring backports selected Java library APIs for older Android versions; it is separate from the Java runtime used by Gradle.

**Review gate:** Android debug build on the available Android 12 phone. Confirm no regression from the plugin's desugaring requirement. iOS source configuration can be prepared on Windows, but iOS build/runtime verification needs macOS/Xcode.

### M3-D — Reconciliation and scheduling adapters (implemented; verification pending)

**Goal:** Turn the domain's desired reminders into idempotent OS requests.

The current plugin adapter already reconciles stable IDs, privacy-safe payloads, `Asia/Kolkata` wall-clock times, and cancellation/replacement, but uses `inexactAllowWhileIdle`. Replace actionable reminder dispatch with the alarm adapter selected by the technical spike. Keep the 09:00 informational summary on the standard notification path. Preserve desired-state reconciliation and the short schedule horizon. Reconcile on task/progress/lifecycle/preference mutations, app startup/resume, and supported reboot/package-update events. Keep task text out of logs and payloads.

**Learning:** Reconciliation compares desired state with external state and applies only the changes needed. Stable IDs make retries safe when an operation is interrupted.

### M3-E — Permission onboarding and reminder settings

**Goal:** Let the owner understand and control reminders without blocking task use.

The reminder settings screen, schedule times, quiet hours, notification permission status, reminder enable/disable, Android exact-alarm access, iOS AlarmKit authorization, and explicit standard-notification fallback choice are implemented. The fallback is stored per profile and defaults Off. Sound/vibration remain under OS channel/alarm controls rather than redundant in-app switches. Authorization is platform state, separate from the user's app preference, and is refreshed after returning from system settings.

**Permission gateway implemented (18 October 2026):** `NotificationPermissionGateway` is the application-owned contract for reading permission status, requesting permission, and opening app notification settings. `FlutterNotificationPermissionGateway` adapts the installed `flutter_local_notifications 22.3.2` APIs for Android and iOS, and `notificationPermissionGatewayProvider` exposes it through Riverpod. This layer does not display an explanation or request permission automatically; no app startup behavior changed. The cross-platform state is intentionally `enabled`, `disabled`, or `unavailable`: the plugin does not consistently tell the app whether disabled permission was never requested or explicitly denied. The settings screen must explain this limitation and only call `requestPermission()` after a user action.

**Verification status (updated 18 October 2026):** The integrated Android debug build succeeded after the permission settings screen was added, and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk`. This confirms Android compilation of the permission gateway and settings screen. A targeted analyzer command could not start its analysis-server subprocess in the restricted environment; no standalone analyzer result is available. No automated tests or physical-device permission prompt checks were run.

**Learning:** App preference and OS permission are different states: a user can enable the feature in app settings while the operating system still blocks delivery.

**Permission and reminder settings implemented (18 October 2026):** The task-list app bar links to a reminder settings screen. It reads Android/iOS notification status through Riverpod, explains the reminder purpose and generic lock-screen content before a user-initiated permission request, and offers a shortcut to the operating system's notification settings. Its `Reminders in MyTasks` switch streams and stores the profile-scoped enabled preference. After a successful database save, the save use case triggers best-effort reconciliation; disabling reminders makes the desired schedule empty, so reconciliation cancels pending requests. Three IST time pickers configure the morning summary/no-task slot, midday no-task slot, and end-of-day progress-log slot; each preserves other preference values and triggers the same save-and-reconcile flow. Optional quiet hours can be enabled with start/end times; their initial window is 23:00–07:00 IST so the default 22:00 end-of-day reminder remains outside quiet hours. Equal start/end times are rejected because the existing rules interpret them as a disabled window. During a quiet period the existing rules defer a reminder to the end if it is later on the same day; if an overnight quiet window would defer it to the following day, it is suppressed instead. The app preference is displayed separately from OS permission, so a saved enabled choice does not claim that the device will deliver notifications. `flutter build apk --debug --no-pub` succeeded after quiet-hours controls were added and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk` (about 67 seconds). Verify saving, schedule cancellation/restoration, time changes, quiet-hours deferral/suppression, prompt allow/deny paths, and returning from system settings on a physical device; automated UI checks were not run. iOS compilation/runtime verification still requires macOS/Xcode.

### M3-F — Notification tap routes and lifecycle recovery

**Quiet-hours implementation verification (18 October 2026):** Settings now reject equal quiet-hours start/end times in the UI and in `SaveReminderPreferences`, while requiring the values to be either both present or both absent. This avoids persisting a window that the existing domain rule would treat as disabled. `flutter build apk --debug --no-pub` succeeded after the quiet-hours controls and validation were added (about 67 seconds). No automated tests or physical-device quiet-hours checks were run.

**Goal:** Make a delivered reminder lead to the right useful screen and recover schedules after routine app/device changes.

**Notification tap routing implemented (18 October 2026):** Scheduled payloads contain versioned, non-sensitive routing metadata. No-task prompts open task creation; summaries and progress prompts open Today. Android alarm Open taps now use the same routes for warm and cold app starts. Snooze must persist a distinct one-off occurrence without duplicating the original daily slot; Stop/Dismiss acknowledges only the current occurrence. Verify foreground, background, and terminated-app taps on a device; iOS runtime verification requires macOS/Xcode.

**Android alarm engine connected (18 October 2026):** The app-owned Dart scheduler now sends actionable reminders to the native `AlarmManager.setAlarmClock` bridge only when Android exact-alarm access is granted. Daily summaries stay ordinary notifications. If exact alarm access is unavailable, task prompts use ordinary notifications only when the saved `allowStandardNotificationFallback` preference is enabled; otherwise those prompts remain unscheduled. If access is revoked between the status check and scheduling, the same explicit fallback rule is applied. Alarm taps are routed through the existing versioned payload router for both warm and cold app starts. Android stores pending native alarms for reboot restoration and rings through a foreground media-playback service with Stop/Snooze controls. `flutter analyze` completed with no issues and `flutter build apk --debug --no-pub` succeeded for this integration. Device delivery verification is pending because no Android device was attached during the check.

**Snooze identity and durable import (18 October 2026):** Android allocates a distinct native alarm ID for each snooze, retains a durable event until Flutter acknowledges it, and cancels pending child snoozes when the parent reminder is canceled. iOS AlarmKit uses a custom Snooze App Intent to schedule a new one-shot alarm and queue an event. `ImportSnoozedReminders` runs before schedule reconciliation at startup/resume, resolves the parent reminder within the active profile, upserts the event in Drift, then acknowledges it. If saving succeeds but acknowledgement fails, the stable occurrence ID makes the retry safe. This queue contains routing metadata only; task text is never stored in platform alarm payloads.

**Snoozed-occurrence schema (18 October 2026):** Drift schema version 4 adds `snoozed_reminder_records`, separate from the daily `scheduled_reminder_requests`. Each row identifies the profile, parent reminder identity, one-off content kind, platform alarm ID, and UTC fire time. Deleting a parent reminder cascades its snooze row; the repository verifies that the referenced parent belongs to the same profile. The version 4 migration only creates the new table, so it does not rebuild or rewrite existing reminder rows. The domain entity, repository contract, Drift adapter, and Android/iOS queue import paths are implemented. A debug Android build succeeded after the integration. Analyzer output still includes one unrelated existing unused import warning and informational lints. No automated tests or encrypted on-device migration test were run.

No-task reminder taps open the new-task form with today's IST date as the start-date default. End-of-day taps open Today so the user can choose which task to log. Handle cold-start and warm-app taps. Restore the rolling schedule after launch/resume, device reboot, and package replacement on Android as supported by the plugin. Cancel past-date requests and avoid replaying missed prompts on the following day.

### M3-G — Device validation and release notes

**M3 Android build verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after Android alarm scheduling and snooze import were connected; it produced `frontend/build/app/outputs/flutter-apk/app-debug.apk`. This verifies Dart and Android compilation only. Foreground, background, terminated-app taps, alarm permission, snooze/stop behavior, reboot recovery, and Xiaomi clear-RAM behavior remain to be checked on a device. iOS build/runtime verification needs macOS/Xcode 26.

**Goal:** Demonstrate rule correctness and document platform limits before calling M3 complete.

Remaining acceptance work is verification: use an approved test harness to check each predicate, quiet-hours edge, date rollover, migration, duplicate reconciliation, cancellation, alarm snooze/stop/open behavior, and tap route. Then manually verify notification and alarm authorization allow/deny, channel disabled, schedule changes, reboot, app update, foreground/background/terminated behavior, task/progress mutations near dispatch, sound, and privacy-safe lock-screen content. Automated tests were not requested in this implementation pass and were not added or run.

Run device checks on the owner's Android 12 Xiaomi phone and, if available, a separate Android 13+ device/emulator. **Observed 18 October 2026:** an alarm set for 12:35 arrived while MyTasks was open but did not arrive after using Xiaomi's clear-RAM action. ADB later showed future `ScheduledNotificationReceiver` alarms registered with Android, but that does not establish why the cleared-RAM case failed. Reproduce separately with (1) Home/lock, (2) swipe from Recents, (3) Xiaomi clear-RAM, and (4) Android Force stop; record scheduled OS alarms before/after each. Xiaomi/MIUI background restrictions can delay or stop background delivery; document app-specific auto-start/battery settings based on this evidence, without requesting broad battery exemptions. Android 12 does not exercise Android 13+'s runtime notification permission or Android 14+'s exact-alarm grant defaults. Record iOS source/build/runtime verification as pending until a Mac/Xcode device or simulator is available. Automated tests are not added or run unless the owner explicitly asks for that test batch.

**Owner device results and follow-up (18 October 2026):** the owner reports the 18:39 midday reminder rang while the app was open; background delivery, app closure/Xiaomi cleanup, snooze, stop, and reminder updates after task changes worked. The alarm currently appears as a notification rather than a full-screen screen. Previously, tapping its notification row opened the task destination but left ringing active; the Stop action silenced it, with the task screen also observed. The updated Android APK now stops the matching alarm when the notification row is tapped before routing to its task destination. The separate Stop button remains stop-only in code. This APK was built and installed on the connected Xiaomi phone on 18 October; the owner still needs to test notification-row tap and Stop separately after this update.

**Deferred UX improvements (recorded 18 October 2026; not part of the current M3 implementation scope):** (1) a full-screen alarm experience that can wake/show over the lock screen, subject to Android's full-screen-intent access and store eligibility; (2) optional hardware volume-button snooze. Volume-button behavior should be considered with the future alarm screen because capturing volume keys while MyTasks is in the background may interfere with the user's ability to adjust alarm loudness. Keep the normal notification row behavior (silence this occurrence and open its task destination) separate from the notification's Stop action (silence only, do not navigate).

## 6. Suggested change batches

All implementation phases above have source code in place. The remaining M3 work is acceptance verification, not another planned implementation slice:

1. Run Android physical-device checks for permission allow/deny, normal close versus Recents swipe versus Xiaomi clear-RAM versus force-stop, reboot, and Open/Snooze/Stop behavior.
2. Build and test on macOS with Xcode 26 using an iOS 26+ simulator/device for AlarmKit, and an iOS 15–25 target for the explicit notification fallback.
3. Complete the reminder eligibility, quiet-hours, migration, and duplicate-reconciliation checks in the verification matrix. Automated tests require a separately approved test batch under the standing project agreement.
4. Record limitations and results, then review M3 exit criteria before marking the milestone complete.

## 7. Verification matrix

| Area | Required checks | Expected result |
|---|---|---|
| Eligibility | No task at 09:00/noon; active tasks at 09:00; task added before noon; future task only; overdue open task; all work completed | 09:00 shows one count-only summary or no-task prompt; noon shows only the still-eligible no-task prompt; adding a task cancels the noon prompt. |
| End-of-day logs | No logs; one of several tasks logged; all tasks logged; note/units/percentage log; 100% progress without completion | Reminder appears only while at least one active task lacks a same-day log; 100% progress remains separate from completion. |
| Lifecycle | Complete, reopen, delete before reminder | Reconcile removes or restores eligibility without deleting retained history except when the task is deleted. |
| Quiet hours | Off; inside window; window crossing midnight; quiet end same day/next day | Defer only to a permitted same-day time; otherwise suppress; no duplicate slot. |
| Idempotency | Reconcile repeatedly; task mutation during schedule; app restart | Stable request IDs replace/cancel prior requests; one pending request per unique identity. |
| Privacy/actions | Lock screen, notification shade, foreground, cold start, warm start, Open/Snooze/Stop | No task names appear; Open routes correctly, Snooze creates one 10-minute occurrence, Stop only acknowledges the current occurrence. |
| Permission | Allow, deny, later revoke, Android channel disabled, iOS setting changed | Task CRUD remains available; app reports actual delivery status and gives a settings route. |
| Platform lifecycle | Android exact-alarm allow/deny, reboot/update, idle mode, Recents swipe, Xiaomi RAM cleanup, force-stop; iOS AlarmKit allow/deny and fallback | Exact Android alarms run only with access; fallback is clearly identified; document OEM behavior and never claim guaranteed delivery. |
| Migration | Upgrade encrypted schema v1 through current schema v4 with user data | Existing guest records remain readable; reminder preferences/ledgers are added without replacing the database key. |

## 8. M3 exit criteria

**Implementation checkpoint (18 October 2026):** Android alarm scheduling, native snooze events, encrypted Drift import, iOS AlarmKit authorization/scheduling/snooze source, settings, and startup/resume reconciliation are implemented. `flutter build apk --debug --no-pub` succeeded and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk` (about 62 seconds). Flutter analysis found no compilation errors, but reported one pre-existing unused import warning and informational lints; the earlier analyzer process was stopped after its findings appeared. No automated tests or physical-device checks were run in this pass. The iOS implementation was not compiled because this workspace is Windows-only and has no Xcode; Xcode 26/macOS and iOS 26+ device or simulator verification remain required. Keep M3 in implementation-complete/verification-pending state until those checks are recorded.

- Guest reminders work without network access and use the correct IST date and times.
- No-task alarm prompts occur only when there is no active open task for today; 09:00 summaries remain informational.
- The 22:00 alarm prompt appears only if one or more active tasks lack a same-day progress log; logs are evaluated per task.
- Preferences persist, quiet hours follow the documented same-day defer/suppress rule, and repeated reconciliation creates no duplicates.
- Schedules reconcile after relevant task/progress/lifecycle/preference changes, app restart/resume, and supported Android reboot/app-update events.
- Notification/alarm authorization denial or OS-level channel/settings disablement never blocks core task functionality; standard-notification fallback is offered only as an explicit user choice.
- Lock-screen content contains no task names; Open/Snooze/Stop alarm actions work and route as specified.
- Android exact scheduling and iOS AlarmKit are used only with required authorization; full-screen presentation is used only when permitted. OEM, force-stop, and fallback limits are documented.
- Android analysis/build and supported-device validation are recorded. iOS implementation/build/runtime status is explicit and requires Mac/Xcode validation before an iOS release claim.
- No Java backend, push, account, sync, study timer, or calendar work is pulled into M3.

## 9. Commands to teach during implementation

Commands will be updated to match the exact package versions and project configuration when each approved batch is implemented. Expected commands, from `frontend/` in PowerShell:

```powershell
# Resolve added Flutter dependencies and update the tracked lockfile
& "C:\Users\yuvra\develop\MyTasksToolchains\flutter\bin\flutter.bat" pub get

# Check Dart/Flutter source without launching the app
& "C:\Users\yuvra\develop\MyTasksToolchains\flutter\bin\flutter.bat" analyze --no-pub

# Build a local Android debug APK
$env:JAVA_HOME = 'C:\Users\yuvra\develop\MyTasksToolchains\jdk-25.0.4.1+1'
& "C:\Users\yuvra\develop\MyTasksToolchains\flutter\bin\flutter.bat" build apk --debug --no-pub

# Install/run on the connected Android phone
& "C:\Users\yuvra\develop\MyTasksToolchains\flutter\bin\flutter.bat" run -d e20fb1ea --no-pub
```

`pub get` may update `pubspec.lock`; it is a tracked source change and must be reviewed in the same approved batch. Build artifacts remain generated and ignored. Do not use commands that reset app data as part of routine reminder verification.

## 10. Learning glossary

| Term | Meaning here |
|---|---|
| Local notification | An alert scheduled by the app on the device, without a server push. |
| Notification permission | OS authorization to display notifications; separate from the in-app reminder toggle. |
| Notification channel | Android's user-controlled category for sound, importance, and visibility. |
| Exact alarm | Android scheduling access for precise wake-up time; not requested for these best-effort reminders. |
| Time-zone-aware date | A date/time interpreted through an IANA zone such as `Asia/Kolkata`, rather than the computer's default zone. |
| Reconciliation | Recomputing what should be scheduled and making the OS requests match that desired state. |
| Idempotent request | A schedule operation that can run again safely without creating another copy. |
| Foreground service | A long-running Android operation with an ongoing notification. Do not keep one running just to maintain the alarm schedule; a short-lived, user-visible playback component may be needed only while an alarm is actively ringing. |
