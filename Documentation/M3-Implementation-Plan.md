# M3 — Detailed Implementation Plan: Local Reminders

**Project:** MyTasks mobile application  
**Status:** Plan prepared; implementation not started  
**Date:** 17 October 2026  
**Owner:** Project owner and assistant, using batches of no more than five changed files and an approval checkpoint before each implementation batch.  
**Prerequisite:** M2 Android guest experience completed.  
**Baseline:** [FRS](FRS.md), [HLD](HLD.md), [LLD](LLD.md), [Implementation Roadmap](Implementation-Roadmap.md), [UI Flow and Wireframes](UI-Flow-and-Wireframe.md), [M2 plan](M2-Implementation-Plan.md), and [Working Agreement](Working-Agreement.md).

## 1. Goal

Add configurable local reminders for the guest profile. Reminders must be derived from the encrypted local task and progress data, remain useful offline, avoid duplicates, protect task names on the lock screen, and keep the task app usable when notification permission is denied.

M3 is a mobile-only milestone. It does not add accounts, push notification delivery, backend reminder workers, or an ongoing foreground service. Signed-in push reminders remain part of M6 after identity, device registration, and sync exist.

## 2. Decisions for M3

| Decision | M3 choice | Reason |
|---|---|---|
| Notification implementation | Use `flutter_local_notifications`; keep it behind an application-owned notification scheduling contract. | The package supports scheduled local notifications on Android and iOS, while the app keeps plugin details out of domain and presentation layers. |
| Local scheduling time zone | Always schedule using the IANA zone `Asia/Kolkata`; device travel/time-zone changes do not change the reminder's intended IST wall-clock time. | The initial release explicitly uses IST and defers travel-aware scheduling. |
| Time-zone conversion | Use `timezone` and construct dates with its `Asia/Kolkata` location. Initialize the bundled tz database once during app startup. | A scheduled wall-clock time must be converted using an explicit zone; the package defaults its local zone to UTC unless configured. |
| Reminder times | No-task reminders: 09:00 and 12:00 IST. End-of-day log reminder: 22:00 IST. All are configurable in settings. | These are the approved requirements and defaults. |
| Morning summary | Reuse the first configured no-task slot (default 09:00): show one count-only daily summary when active tasks exist; show the “assign today's work” prompt when there are none. Never send both in that slot. At the second configured no-task time (default 12:00), send only the no-task prompt if the day is still empty. | This satisfies both the daily summary and no-task reminder requirements without duplicate morning notifications. |
| Reminder preference default | The guest reminder preference starts enabled, matching the approved wireframe; show a contextual explanation before the first OS permission request. If permission is denied, leave tasks usable and show the blocked delivery status in settings. | The user originally requested reminders; an in-app setting and OS permission still let them opt out. |
| Sound/vibration default | Follow normal OS defaults; app preferences begin enabled where supported, but never override Android channel or iOS system controls. | The user can change either app preference or system-level notification behavior. |
| Android scheduling precision | Use `AndroidScheduleMode.inexactAllowWhileIdle` by default; do not request exact-alarm special access in M3. | These are planning reminders, not an alarm-clock use case. Android exact alarms have extra access rules and are denied by default for many new Android 14 installs. The app will describe delivery as best effort. |
| Reminder type and tone | Use one normal “Task reminders” notification channel at a calm default importance; let Android channel controls and iOS notification settings remain authoritative. | A task-planning prompt should not impersonate an urgent alarm. Do not request Do Not Disturb access. |
| Default lock-screen content | Always use a generic title/body and an optional task count; never include topic, subtopic, or description. | The FRS requires count-only privacy-safe lock-screen summaries. Notification taps open the relevant app view. |
| Permission timing | Explain the value in the reminder setup flow, then request OS permission only when the user turns reminders on/continues setup. Never prompt on the first app launch. | This gives context and preserves a useful guest app if permission is declined. Android 13+ uses runtime notification permission; iOS authorization can be denied or changed in Settings. |
| Sticky task-list notification | Do not build a permanent task-list notification or foreground service in M3. Use dismissible, scheduled reminders and the Today screen. | Android and iOS control notification visibility; the app cannot promise an unhideable notification. There is no valid long-running foreground operation for M3. |
| Schedule horizon | Reconcile one-shot requests for the rest of today and the next IST calendar day only, at most six requests including the morning-summary/no-task alternatives. Recompute on every relevant local change and app start/resume. | A short rolling horizon makes state changes easy to reconcile and stays far below platform pending-notification limits. It avoids repeating notifications whose eligibility has not been checked against current local data. |
| Task-content telemetry | No cloud logging or analytics is added. Diagnostics may record reminder type, date, result, and platform error without task content. | M3 is local-only and task names are private. The app currently has no centralized logging service. |

### Package versions at plan preparation

The current stable package references on 17 October 2026 are `flutter_local_notifications 22.3.2` and `timezone 0.11.2`. Recheck compatibility and stable versions when the dependency batch starts, add compatible constraints, run `flutter pub get`, and commit the resulting `pubspec.lock` in the same approved batch. The local notification plugin version 10+ requires Android core-library desugaring, Android Gradle Plugin 8.11.1 or higher, and compile SDK 35 or higher; compare these requirements with the existing Flutter/Android configuration before editing it. Keep Java/Kotlin source compatibility at 17 unless the current Flutter toolchain requires a documented change; using JDK 25 to run Gradle does not mean app bytecode needs to target Java 25.

References: [flutter_local_notifications package and setup](https://pub.dev/packages/flutter_local_notifications/versions/22.3.2), [timezone package](https://pub.dev/packages/timezone), [Android notification permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission), [Android exact alarm policy](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms), [Android notification channels](https://developer.android.com/design/ui/mobile/guides/home-screen/notifications), and [Apple local notifications](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app).

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
Drift preference/schedule-ledger adapter     Local-notification plugin adapter
        ↑                                      ↑
        └────────── app composition root ─────┘
```

The domain layer must not import Flutter widgets, Drift, `flutter_local_notifications`, or platform APIs. The application layer coordinates local task/progress repositories, the reminder-preference repository, and a notification-scheduler port. The outer adapter translates a desired schedule into plugin requests.

### Local schema

M2 introduced Drift schema version 1. M3 adds a version-2 migration that preserves all existing encrypted task data and adds:

- `ReminderPreferences`: one row per local profile, with enabled state; no-task times; end-of-day time; optional quiet-hours start/end; sound and vibration preferences where supported; and update time. Defaults match the product decisions above.
- `ScheduledReminderRequests`: a stable schedule identity, platform integer ID, logical slot type, content kind, IST local date, configured slot, effective scheduled instant, and update time. Add uniqueness for identity and notification ID. The table is a reconciliation ledger, not a history of reminders that were shown.

**Implementation checkpoint (18 October 2026):** `AppDatabase` now declares both tables at schema version 2. The version-1 upgrade creates only these new tables, so it does not rewrite existing profile, task, progress, or lifecycle rows. Drift code generation completed for `app_database.g.dart`. A disposable in-memory SQLite database shaped like schema version 1 was upgraded successfully: its sample profile, task, progress, and lifecycle rows remained present, both reminder tables were created, and `user_version` became 2. This check validates the Drift migration path and row preservation on SQLite; it does not exercise the encrypted database connection or the database on a physical phone.

The domain record and Drift adapters now map reminder preferences and scheduled-request identities to the version-2 tables. The schedule repository preserves notification IDs for unchanged identities and retains obsolete ledger rows until the platform adapter confirms cancellation, so a retry can still discover IDs after an interrupted reconciliation. Riverpod now wires these repositories to the encrypted database and composes the clock, calculate, and save use cases. The reconcile use case remains unwired until the OS notification adapter exists. Migration verification remains pending.

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

### M3-C — Notification package and platform foundation

**Goal:** Initialize the plugin and verify one generic test notification on Android before implementing business scheduling.

The dependency/platform foundation batch has been implemented with `flutter_local_notifications: ^22.3.2` and `timezone: ^0.11.2` (resolved exact versions are in `frontend/pubspec.lock`). The Android app now enables core-library desugaring and declares the plugin's scheduled-notification receiver, plus boot/package-replacement recovery receiver and `RECEIVE_BOOT_COMPLETED`. The app's Flutter-provided compile SDK and current AGP already meet the plugin's stated minimums, so neither was changed. Exact-alarm, full-screen-intent, Do Not Disturb, and foreground-service permissions were not added.

The Dart startup initializer is now in `frontend/lib/data/notifications/local_notification_initializer.dart` and is awaited before the Flutter UI starts. It initializes the bundled IANA time-zone data, sets the default scheduling zone to `Asia/Kolkata`, and initializes Android/iOS plugin settings with iOS permission prompts disabled. It also creates Android's `Task reminders` channel. If setup fails, startup logs the error in debug output and still opens the task app. No notification is scheduled or displayed yet.

The Android initializer now creates the normal `Task reminders` channel with default importance. On iOS, `AppDelegate.swift` assigns the app delegate to `UNUserNotificationCenter` so foreground presentation and notification responses can be integrated with the plugin. These steps do not request permission or schedule reminders.

Still remaining in M3-C: wire a notification-tap callback to app navigation and show a generic test notification through an explicit user action. Android delivery and iOS source/build/runtime behavior still need platform verification; iOS compilation requires macOS/Xcode.

**Startup verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after startup initialization was added and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk`. The cached Android build completed in about 40 seconds. This verifies compilation, not runtime notification delivery; no automated tests or physical-device checks were run for this batch.

**Channel and delegate verification (18 October 2026):** The Android debug APK rebuilt successfully after channel creation was added. This confirms Android compilation of the channel setup. The iOS delegate edit could not be compiled in the Windows environment; verify it on macOS/Xcode before claiming iOS support.

The `FlutterLocalNotificationScheduler` adapter now maps reminder requests to generic, privacy-safe notification text, converts each UTC instant to an `Asia/Kolkata` zoned time, schedules with Android's inexact-while-idle mode, and uses stable IDs from the encrypted Drift ledger. It cancels obsolete OS notifications before removing their ledger rows, so failed cancellation can be retried. Riverpod exposes the scheduler and `ReconcileReminders` use case together. The adapter currently follows system sound/vibration settings; saved sound/vibration preferences are not applied yet.

Task create, edit, and delete, progress create/edit/delete, and task complete/reopen use cases now accept an application-owned change callback supplied by the Riverpod composition root. After a successful database write, it recalculates and replaces that profile's reminder schedule. Validation failures and no-op updates/deletes/transitions do not reconcile. Reminder/plugin failures are caught and logged so a committed user action is still reported as successful; the app does not yet have a centralized logging service. App startup/resume reconciliation and reminder-settings triggers remain to be wired.

`ReminderReconciliationObserver` now runs one reconciliation after the first app frame and whenever the app resumes. It serializes overlapping requests and repeats once if another resume occurs during a reconciliation. Profile/database/plugin failures are logged as best-effort reminder errors and do not block task navigation.

**Task-mutation verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after the callback wiring was formatted, producing `frontend/build/app/outputs/flutter-apk/app-debug.apk`. This confirms Android compilation only. No automated tests or physical-device reminder checks were run.

**Progress/lifecycle verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after progress and completion/reopen callbacks were wired. This confirms Android compilation only; no automated tests or physical-device reminder checks were run.

**Startup/resume verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after adding the reconciliation observer. This confirms Android compilation only; lifecycle behavior and actual notification delivery were not manually verified on a device.

**Adapter verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after formatting and the adapter syntax correction, producing `frontend/build/app/outputs/flutter-apk/app-debug.apk`. This confirms Android compilation only. No automated tests or device notification delivery checks were run.

**Verification (18 October 2026):** `flutter pub get` resolved the dependencies successfully, and `flutter build apk --debug --no-pub` completed successfully with the project JDK 25 and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk`. The first Android build took about 4.5 minutes while Gradle initialized/downloaded dependencies. No automated tests were run. This confirms Android compilation of the plugin/platform setup; it does not yet prove notification delivery or reboot recovery on a device.

**Learning:** Flutter plugins bridge Dart code to native Android/iOS APIs. Android notification channels are created once and users control their sound/visibility settings. Desugaring backports selected Java library APIs for older Android versions; it is separate from the Java runtime used by Gradle.

**Review gate:** Android debug build on the available Android 12 phone. Confirm no regression from the plugin's desugaring requirement. iOS source configuration can be prepared on Windows, but iOS build/runtime verification needs macOS/Xcode.

### M3-D — Reconciliation and scheduling adapter

**Goal:** Turn the domain's desired reminders into idempotent OS requests.

Implement the plugin adapter with stable request IDs, generic count-only content, `Asia/Kolkata` one-shot scheduling, cancellation/replacement, permission/channel-status checks, and error mapping. Use `inexactAllowWhileIdle` on Android. Schedule only remaining slots for today plus tomorrow. Reconcile on all task/progress/lifecycle/preference mutations, app startup/resume, and supported Android reboot/package update. Keep OS work best effort and do not expose task text in logs or payloads.

**Learning:** Reconciliation compares desired state with external state and applies only the changes needed. Stable IDs make retries safe when an operation is interrupted.

### M3-E — Permission onboarding and reminder settings

**Goal:** Let the owner understand and control reminders without blocking task use.

Add a reminder settings screen reachable from app settings; provide enable/disable, two no-task times, end-of-day time, optional quiet hours, sound/vibration controls where supported, current system permission/channel status, and a link to system settings after denial. Show an explanation before the OS permission request. Never repeatedly prompt after denial. Store preferences locally and reconcile after every change.

**Permission gateway implemented (18 October 2026):** `NotificationPermissionGateway` is the application-owned contract for reading permission status, requesting permission, and opening app notification settings. `FlutterNotificationPermissionGateway` adapts the installed `flutter_local_notifications 22.3.2` APIs for Android and iOS, and `notificationPermissionGatewayProvider` exposes it through Riverpod. This layer does not display an explanation or request permission automatically; no app startup behavior changed. The cross-platform state is intentionally `enabled`, `disabled`, or `unavailable`: the plugin does not consistently tell the app whether disabled permission was never requested or explicitly denied. The settings screen must explain this limitation and only call `requestPermission()` after a user action.

**Verification status (updated 18 October 2026):** The integrated Android debug build succeeded after the permission settings screen was added, and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk`. This confirms Android compilation of the permission gateway and settings screen. A targeted analyzer command could not start its analysis-server subprocess in the restricted environment; no standalone analyzer result is available. No automated tests or physical-device permission prompt checks were run.

**Learning:** App preference and OS permission are different states: a user can enable the feature in app settings while the operating system still blocks delivery.

**Permission and reminder settings implemented (18 October 2026):** The task-list app bar links to a reminder settings screen. It reads Android/iOS notification status through Riverpod, explains the reminder purpose and generic lock-screen content before a user-initiated permission request, and offers a shortcut to the operating system's notification settings. Its `Reminders in MyTasks` switch streams and stores the profile-scoped enabled preference. After a successful database save, the save use case triggers best-effort reconciliation; disabling reminders makes the desired schedule empty, so reconciliation cancels pending requests. Three IST time pickers configure the morning summary/no-task slot, midday no-task slot, and end-of-day progress-log slot; each preserves other preference values and triggers the same save-and-reconcile flow. Optional quiet hours can be enabled with start/end times; their initial window is 23:00–07:00 IST so the default 22:00 end-of-day reminder remains outside quiet hours. Equal start/end times are rejected because the existing rules interpret them as a disabled window. During a quiet period the existing rules defer a reminder to the end if it is later on the same day; if an overnight quiet window would defer it to the following day, it is suppressed instead. The app preference is displayed separately from OS permission, so a saved enabled choice does not claim that the device will deliver notifications. `flutter build apk --debug --no-pub` succeeded after quiet-hours controls were added and produced `frontend/build/app/outputs/flutter-apk/app-debug.apk` (about 67 seconds). Verify saving, schedule cancellation/restoration, time changes, quiet-hours deferral/suppression, prompt allow/deny paths, and returning from system settings on a physical device; automated UI checks were not run. iOS compilation/runtime verification still requires macOS/Xcode.

### M3-F — Notification tap routes and lifecycle recovery

**Quiet-hours implementation verification (18 October 2026):** Settings now reject equal quiet-hours start/end times in the UI and in `SaveReminderPreferences`, while requiring the values to be either both present or both absent. This avoids persisting a window that the existing domain rule would treat as disabled. `flutter build apk --debug --no-pub` succeeded after the quiet-hours controls and validation were added (about 67 seconds). No automated tests or physical-device quiet-hours checks were run.

**Goal:** Make a delivered reminder lead to the right useful screen and recover schedules after routine app/device changes.

**Notification tap routing implemented (18 October 2026):** Scheduled payloads now contain versioned JSON routing metadata (`contentKind` and the non-sensitive reminder identity); task names and other task text are never included. Warm-app responses are emitted through the notification initializer's tap stream. Cold-start responses are retained until the root Navigator is available. No-task prompts open the task form, whose start date defaults to today in IST; daily summaries and progress prompts open the Today task list. Invalid/old payloads are ignored safely. Verify foreground, background, and terminated-app taps on a device; iOS runtime verification requires macOS/Xcode.

No-task reminder taps open the new-task form with today's IST date as the start-date default. End-of-day taps open Today so the user can choose which task to log. Handle cold-start and warm-app taps. Restore the rolling schedule after launch/resume, device reboot, and package replacement on Android as supported by the plugin. Cancel past-date requests and avoid replaying missed prompts on the following day.

### M3-G — Device validation and release notes

**M3-F Android build verification (18 October 2026):** `flutter build apk --debug --no-pub` succeeded after notification payload routing and startup/tap handling were added; it produced `frontend/build/app/outputs/flutter-apk/app-debug.apk` in about 50 seconds. This verifies Android compilation only. Foreground, background, and terminated-app tap behavior remains to be checked on a device, and iOS build/runtime verification needs macOS/Xcode.

**Goal:** Demonstrate rule correctness and document platform limits before calling M3 complete.

Use an injectable clock or approved test harness to check each predicate, quiet-hours edge, date rollover, migration, duplicate reconciliation, cancellation, and tap route. Then manually verify permission allow/deny, app channel disabled, schedule changes, reboot, app update, foreground/background/terminated tap handling, task/progress mutations near dispatch, and privacy-safe lock-screen content.

Run device checks on the owner's Android 12 Xiaomi phone and, if available, a separate Android 13+ device/emulator. Xiaomi/MIUI background restrictions can delay or stop alarms; document the relevant battery/auto-start guidance without asking for broad battery exemptions. Record iOS source/build/runtime verification as pending until a Mac/Xcode device or simulator is available. Automated tests are not added or run unless the owner explicitly asks for that test batch.

## 6. Suggested change batches

These are expected groups, not blanket approval to edit them. Each will be presented for approval with the exact current file list before editing.

1. **M3-A rules/contracts:** approximately 3–5 new domain/application files.
2. **M3-B schema:** database table definitions, migration/generated code, repository/provider wiring, and plan update; split if it exceeds five files.
3. **M3-C plugin setup:** `pubspec.yaml`, `pubspec.lock`, Android Gradle/manifest files, and plan update; split Android and iOS setup into separate batches when needed.
4. **M3-D scheduler adapter:** plugin service, schedule mapping, adapter provider, reconciliation use case wiring, and plan update; keep each batch at five files or fewer.
5. **M3-E/F UI and routes:** settings/permission screens, app navigation, notification tap handling, and schedule triggers; split into independently reviewable batches.
6. **M3-G verification:** approved test batch if requested, Android device results, documented iOS limitation, and exit review.

## 7. Verification matrix

| Area | Required checks | Expected result |
|---|---|---|
| Eligibility | No task at 09:00/noon; active tasks at 09:00; task added before noon; future task only; overdue open task; all work completed | 09:00 shows one count-only summary or no-task prompt; noon shows only the still-eligible no-task prompt; adding a task cancels the noon prompt. |
| End-of-day logs | No logs; one of several tasks logged; all tasks logged; note/units/percentage log; 100% progress without completion | Reminder appears only while at least one active task lacks a same-day log; 100% progress remains separate from completion. |
| Lifecycle | Complete, reopen, delete before reminder | Reconcile removes or restores eligibility without deleting retained history except when the task is deleted. |
| Quiet hours | Off; inside window; window crossing midnight; quiet end same day/next day | Defer only to a permitted same-day time; otherwise suppress; no duplicate slot. |
| Idempotency | Reconcile repeatedly; task mutation during schedule; app restart | Stable request IDs replace/cancel prior requests; one pending request per unique identity. |
| Privacy/tap | Lock screen, notification shade, foreground, cold start, warm start | No task names appear; tap opens the expected Today/create view. |
| Permission | Allow, deny, later revoke, Android channel disabled, iOS setting changed | Task CRUD remains available; app reports actual delivery status and gives a settings route. |
| Platform lifecycle | Android reboot/update, idle mode, Xiaomi battery restriction, app force-stop; iOS background delivery | Reconcile when supported; never claim exact or guaranteed delivery; document observed OS behavior. |
| Migration | Upgrade existing encrypted schema v1 to v2 with user data | Existing guest records remain readable and reminder defaults are created without replacing the database key. |

## 8. M3 exit criteria

- Guest reminders work without network access and use the correct IST date and times.
- No-task prompts are sent only when there is no active open task for today.
- The 22:00 prompt appears only if one or more active tasks lack a same-day progress log; logs are evaluated per task.
- Preferences persist, quiet hours follow the documented same-day defer/suppress rule, and repeated reconciliation creates no duplicates.
- Schedules reconcile after relevant task/progress/lifecycle/preference changes, app restart/resume, and supported Android reboot/app-update events.
- Notification permission denial or OS-level channel/settings disablement never blocks core task functionality.
- Lock-screen content contains no task names; notification taps open the expected app destination.
- The app does not claim an uncloseable or exact-time notification. Android uses inexact scheduling by default; OEM and iOS delivery limits are documented.
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
| Foreground service | A long-running Android operation with an ongoing notification; it is not justified by this reminder feature. |
