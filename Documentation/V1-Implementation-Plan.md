# V1 — Polished Offline App and Study Tracking

**Status:** Implementation in progress; core local study tracking and the first visual refresh are implemented
**Release boundary:** V1 is the Flutter Android/iOS app using encrypted local storage. The Java backend, accounts, cloud sync, and guest transfer are V2.
**Design input:** Owner-provided `DESIGN.md` at `F:\YUVRAJ\Download\DESIGN.md`; translate its cream/coral/teal palette, Nunito Sans typography, generous spacing, rounded components, and bold Solar-style icon language into Flutter. The file's HTML/Tailwind snippets are visual references, not a request to build a website.

## 1. Goal and scope

V1 should feel like one finished product: task planning, progress, local alarm reminders, and explicit study-session tracking work together, remain usable offline, and protect existing guest data. Improve the current Flutter app in place. Do not replace Flutter with a website or introduce backend dependencies.

V1 does not monitor which other apps the user opens. That would require separate OS permissions/APIs and is not part of the requested stopwatch. Calendar analytics remain later scope. Keep full-screen/wake-screen alarms and volume-button snooze in the deferred alarm-improvement list; they are not prerequisites for the timer plan unless a separate product decision changes that.

## 2. Recommended user experience

Add **Study** as a first-class destination, reachable from the main navigation without obscuring Today/Later/Completed. Before a session starts, the user chooses one of: link an existing non-completed task, create a task, or study without a task. Keep the unlinked path available for general study.

The active screen shows a large elapsed-time display, linked task when present, and clear **Take a break** and **Stop session** actions. Break choices are 10 minutes, 20 minutes, or a custom duration. During a break, freeze focused-study time and show a separate countdown. When the countdown ends, alert the user; require an explicit Resume tap so break time cannot be accidentally counted as study. Stopping during a break saves only focused time.

On stop, show a concise session summary and add a dated history entry. A linked session does not automatically change task progress; offer the existing progress flow as a separate explicit action. The study history shows daily focused total, session duration, break duration, date/time, and optional task title.

## 3. Local data and timing design

Store sessions and break intervals in the encrypted Drift database, scoped by local profile, with foreign-key behavior that preserves the existing isolation guarantees. Use a versioned schema migration and generated Drift code; never reset the user's existing database/key to add these tables.

Represent session state explicitly (running, on break, stopped). Persist each transition with UTC timestamps and a stable session ID. Derive elapsed time from the saved start/resume and break intervals; do not increment a counter only in widget memory or keep a permanent background service alive. On process recreation, reconstruct the active state. Allow one active session per profile. Keep session duration immutable after stop in V1; editing/deleting history can be assessed separately.

The break-end alert should use a scheduled local notification when permission is available and an in-app alert while the app is foregrounded. A denied notification permission must not prevent study timing. Cancel or replace the alert when the user ends the break early. This is a reminder, not a Clock alarm guarantee.

## 4. Phased implementation

### V1-A — Product and visual audit

- Use the installed existing-project redesign skill after restarting Codex so it is available to the session.
- Audit the actual Flutter screens/states against `DESIGN.md` and existing task behavior. Record the strongest fixes before changing UI.
- Define Flutter theme tokens, typography, component states, navigation treatment, and accessibility rules; resolve any conflict between the visual reference and task usability explicitly.
- Capture a baseline on Android and maintain the current guest database and reminder schedules during development.

### V1-B — Design foundation and task-flow polish

- Implement shared theme/components in small batches, then update task list, task create/edit, task detail, progress/lifecycle, and reminder settings.
- Improve loading, empty, error, validation, pressed/disabled, and accessibility states.
- Preserve task rules, alarm behavior, secure database opening, and date handling. Avoid decorative treatments that reduce contrast or consume small-screen space.

### V1-C — Study-session domain and persistence

- Define session and break domain records, state transitions, calculations, and repository contracts before screen work.
- Add the Drift migration and repository adapters; verify upgrade path preserves existing profiles/tasks/history.
- Add application use cases for start, take break, resume, stop, recover active session, and read history/totals.

### V1-D — Study timer UI and task linking

- Add Study navigation and pre-session task selection/create/unlinked choices.
- Add active, break, recovered-session, stopped-summary, empty-history, and failure states.
- Wire a break-end notification through the existing notification boundary; do not couple study UI directly to platform channels or SQLite.

### V1-E — Release hardening and V1 review

- Walk task creation/edit/delete, progress, completion/reopen, alarms, study start/break/resume/stop, app background/relaunch, and database upgrade on Android.
- Review screen reader labels, text scaling, contrast, touch targets, and color-independent status cues.
- Validate iOS build and runtime behavior on macOS/Xcode; document any iOS-only limitations.
- Review privacy notice, local-data/backup behavior, store metadata, required SDK versions, dependency licenses, and support contact before public distribution.
- Freeze V1 scope and begin the existing M4/M5/M6 Java/backend work only as V2.

## 5. Acceptance criteria

- Existing guest task data remains readable after app upgrade and after the study schema migration.
- Only one session can be active per profile; every allowed state transition is persisted and recoverable.
- Focused duration excludes break intervals and remains correct after backgrounding or process recreation under normal device-clock behavior.
- The user can link/create/select a task or start unlinked; no task progress changes without explicit user action.
- Break end is communicated when possible, while denied notification permission does not block timing.
- Task, reminder, and study screens follow a consistent adapted visual system and remain accessible at larger text sizes.
- Android acceptance is recorded on a real device. iOS acceptance requires a Mac/Xcode build and device or simulator run.

## 6. Decisions selected for this plan

| Decision | V1 default | Reason |
|---|---|---|
| Study tracking type | User-started stopwatch, not device-wide app usage | Matches the described study intent and avoids asking for sensitive Usage Access/Screen Time permissions. |
| Task link | Optional; allow standalone study | Users may study without a task, while task linkage supports useful summaries. |
| Break counting | Break time excluded; explicit Resume after alert | Prevents accidental study-time inflation if the user is away when a break ends. |
| Task progress | No automatic progress update | Elapsed study time does not reliably imply task completion. |
| Concurrent sessions | One active session per profile | Keeps totals understandable and prevents overlapping time. |
| Backend order | Java is V2, after V1 review | Stabilizes the mobile experience and local model before remote/account complexity. |

## 7. Learning outcomes

The implementation should teach Flutter theming and accessibility, state machines, elapsed-time calculation, persisting long-lived state, Drift schema migration, repository/use-case boundaries, scheduled local notifications, and release checks. Keep explanations and file batches small enough for the owner to follow.

## 8. Implementation record (18 October 2026)

- **V1-A — Design audit:** Completed. The `design-taste-frontend` workflow is website-only, so the installed existing-project redesign skill and owner-supplied `DESIGN.md` were used to adapt its visual direction to native Flutter. Nunito Sans is bundled with its SIL Open Font License. Bright accent colors use dark ink for readable contrast; the task effort greens remain a separate semantic scale.
- **V1-B — Core visual refresh:** Implemented in code. A shared cream/coral/teal theme, four-destination navigation, revised task-list cards and states, responsive task details, human-readable IST dates, consistent forms, notification settings, progress/lifecycle history, safe user-facing error messages, and an in-app font license disclosure are in place. Screen-reader validation across every screen remains part of V1-E.
- **V1-C — Study domain and storage:** Implemented. Drift schema version 5 adds profile-scoped study sessions and break intervals. One active session per profile is enforced in application logic and a partial unique index. Task deletion unlinks a session while retaining its history. Focus seconds are derived from UTC intervals and daily totals use the fixed IST day boundary.
- **V1-D — Timer and task linking:** Implemented in code. The Study destination supports choosing an open task, creating a task, or starting without a task; offers 10-minute, 20-minute, and 1–240-minute custom breaks; requires explicit resume; and provides stop plus session history. Break-end alerts are ordinary scheduled notifications and require OS notification permission; denied access does not block timing. No always-running background service is used.
- **Automated verification:** Domain state rules, IST midnight splitting, break exclusion, start/break/resume/stop persistence, profile isolation, task deletion unlinking, schema-upgrade preservation, empty Study UI, and large-text Study UI are covered by Flutter tests. Run `flutter test` from `frontend/`.
- **Android build/install:** `flutter build apk --debug` completed and the APK was installed with `adb install -r` on the connected M2102J20SI. The `-r` install preserves app data. Android started the app process without a surfaced database/cipher error. The phone remained on its lock screen, so visual and tap-through checks still need the owner to unlock it.
- **Still needed for V1-E:** Real-device Android walkthrough of the study flow and existing task/alarm regression checks, screen-reader review of all refreshed screens, and iOS build/runtime validation on macOS with Xcode. Confirm public-release privacy, retention, store metadata, and bundled license disclosures with responsible owners before publishing.

The stored times are UTC instants. The display and daily summaries use Asia/Kolkata. As with any wall-clock stopwatch, a manual device clock change can affect elapsed-time calculations; V1 does not request device-wide usage access or run a persistent study service.
