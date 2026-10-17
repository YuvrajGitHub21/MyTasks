# M2 — Detailed Implementation Plan

**Project:** MyTasks mobile application  
**Purpose:** Build the first useful guest experience as a local-first Flutter app.  
**Status:** Complete — 17 October 2026. Android task journeys, persistence, accessibility review, Flutter analysis, and debug build passed. iOS device/build validation remains pending because macOS/Xcode is not available.
**Owner:** Project owner and assistant, working in approved batches of at most five edited files.  
**Baseline:** [FRS](FRS.md), [HLD](HLD.md), [LLD](LLD.md), [Implementation Roadmap](Implementation-Roadmap.md), [UI flows and wireframes](UI-Flow-and-Wireframe.md), and [Working Agreement](Working-Agreement.md).

## 1. What M2 delivers

M2 turns the Flutter scaffold into a useful guest task app. A guest can create and manage tasks without an account or network connection. The app stores data on the device, shows tasks in Today, Later, and Completed, records partial progress and completion history, and restores data after the app is closed and reopened.

The M2 boundary is the local guest experience. It does not add sign-in, a task API, cloud synchronization, notifications, a study timer, or a calendar. The Java backend remains a foundation for later account and sync milestones. M2 should shape the local repository and data model so later synchronization can be added without making screens depend directly on SQLite.

## 2. Current M2 snapshot

| Area | State | Notes |
|---|---|---|
| Flutter dependency for state management | Complete | Riverpod is in `pubspec.yaml` and its resolved versions are in `pubspec.lock`. |
| App bootstrap | Complete | `ProviderScope` is the Riverpod root. |
| App shell and navigation | Complete on Android | Material 3 theme and Today/Later/Completed navigation; each view is connected to the profile-scoped task stream and create form. |
| Guest profile | Implemented foundation | `LocalProfileStore` creates or reuses a UUID-backed guest profile; the app composition root supplies profile-scoped application actions. Screens do not import local repository providers. |
| Onion boundaries | Implemented foundation | Task, progress, and lifecycle contracts are domain-owned; application use cases depend on those contracts; Drift repositories implement them; app-level Riverpod providers compose the outer adapters. Backend entry point and HTTP error handling are in bootstrap/adapter packages; backend feature domain/use-case code will be added with M4 features. |
| Task domain model and validation | Implemented | `Task`, `ProgressEntry`, `LifecycleEvent`, `TaskDate`, and reusable rules match the LLD; task creation validation runs through an application use case. |
| Encrypted local persistence | Android verified | Encrypted Drift connection, version-1 tables, database/profile providers, and profile-scoped task/progress CRUD plus atomic completion/reopen history operations are implemented; Android restart preserved local data. |
| Task lists and task journeys | Complete on Android | Task creation, live Today/Later/Completed lists, task detail, editing, confirmed deletion, progress logging/history with correction/deletion, and complete/reopen actions with dated lifecycle history passed the owner's Android journey checks. |
| Automated tests | Not part of the current work agreement | Do not add or run tests unless the owner asks. Use the agreed analysis/build/manual checks and explain any verification limitation. |

The first app-shell batch changed `frontend/pubspec.yaml`, `frontend/pubspec.lock`, `frontend/lib/main.dart`, `frontend/lib/app/my_tasks_app.dart`, and `frontend/lib/app/app_shell.dart`. Flutter analysis passed and an Android debug APK built successfully after that batch. These checks verify the shell compiles; they do not verify task behavior or persistence.

### Architecture boundary in M2

```text
features/tasks/presentation -> application use cases -> domain entities/rules/contracts
app composition root -------------------------------> data adapters (outer layer)
data/local Drift adapters --------------------------> domain repository contracts
```

Feature screens use application actions through app-level providers. Application code owns task/progress/lifecycle orchestration and generated event identity; domain owns rules and persistence contracts; Drift owns SQL and transaction details. The backend currently has bootstrap and inbound HTTP adapter foundations. Add backend domain/application packages with the first real backend feature instead of creating empty placeholder classes.

## 3. Product and technical rules M2 must preserve

### Task fields and validation

- Topic is required, trimmed, and at most 200 characters.
- Subtopic is optional and at most 200 characters; description is optional and at most 5,000 characters.
- Start date and planned end date are required. Planned end date must be on or after start date.
- Maximum end date is optional; when provided it must be on or after the planned end date.
- Estimated effort is a decimal number of hours, greater than zero, at most 99,999.99, with 0.01-hour precision. It means planned effort, not elapsed time or date duration.
- Progress notes are at most 2,000 characters.

Validation belongs in reusable domain/application logic, not only in form widgets. The form should show the same actionable messages as the UI flow document and preserve entered values when validation fails.

### Date classification and list membership

Use the current calendar date in `Asia/Kolkata` (IST). Store task dates as date-only values; do not turn them into UTC timestamps and risk shifting a date across time zones.

```text
if task is completed: Completed
else if start date is after today: Later
else: Today
```

An incomplete task whose planned end date is before today remains in Today and is visibly overdue. Do not move its planned end date forward automatically. A maximum-end-date breach can be shown as a separate status cue. Completed tasks appear only in Completed.

### Effort and status appearance

Use the five fixed effort bands and color tokens in `UI-Flow-and-Wireframe.md`. The same effort always maps to the same band regardless of the other tasks in the list. Current tasks use the green cue, while overdue red styling takes precedence. Always show numeric effort and a text label/icon so color is not the only signal. Scheduled and completed tasks do not use the current-task green scale.

### Progress and lifecycle history

A partial progress entry chooses exactly one method:

- Percentage: integer or supported numeric value from 0 through 100. A 100% entry does not complete the task.
- Units: completed and total units are both positive; completed cannot exceed total.
- Note: required non-empty text up to 2,000 characters.

A task can have multiple dated progress entries. Users can review, correct, or remove them. Full completion and reopening are separate lifecycle events; reopening does not erase the earlier completion event. Deleting a task removes its progress and lifecycle history too.

## 4. Work sequence and teaching notes

Work is split into small code batches. Before each batch, explain the files and purpose; edit no more than five files; then report what changed and what was checked. Ask before starting another file batch. A package or generated lockfile change counts as a file edit. Do not run Git commands unless the owner explicitly asks.

### M2-A — App shell (complete)

**Goal:** Have a runnable app with the agreed primary navigation before adding task behavior.

**Implemented:** Added Riverpod dependency and app-level `ProviderScope`; set the Material 3 theme; added Today, Later, and Completed navigation and first-pass empty states.

**What you learn:** Flutter starts at `main()`, builds a widget tree, and uses `MaterialApp` to provide navigation/theme defaults. Riverpod's `ProviderScope` is the root container where providers can later expose shared app state. A navigation shell gives each screen a stable place without putting database code in the navigation widget.

**Verification recorded:** `flutter analyze` passed and an Android debug APK built. These are build checks, not automated behavior tests.

### M2-B — Task rules and local profile foundation

**Goal:** Define data and rules in plain Dart before storage and forms rely on them.

**Planned work:**

1. Define immutable task, progress-entry, and lifecycle-event types with locally generated UUIDs.
2. Define a stable guest profile identifier and an explicit active-profile boundary. Keep every local query scoped to that profile, even though only guest mode is initially visible.
3. Implement input validation for task and progress values using the approved LLD limits.
4. Implement pure date classification and effort-band selection so the same input always produces the same result.
5. Keep date-only values separate from timestamps for event occurrence/creation.

**What you learn:** A domain model describes product concepts independently of Flutter screens or the database. Pure functions are easier to reason about because the same input produces the same output. UUIDs allow a task to keep its identity when offline and later sent to a server.

**Review checkpoint:** Compare the model and validation cases with the FRS/LLD; correct any mismatch before storage is built around them.

### M2-C — Encrypted local persistence

**Goal:** Store guest data durably on device and provide a repository API the UI can use without knowing SQL.

**Planned work:**

1. Use the selected compatible stable packages: Drift 2.35.2, drift_flutter 0.3.1, sqlite3 3.7.1, flutter_secure_storage 11.2.0, path 1.9.1, path_provider 2.1.6, uuid 4.6.0, drift_dev 2.35.1, and build_runner 2.16.2. `pubspec.lock` pins the resolved versions. The `sqlite3` build hook selects SQLite3MultipleCiphers (`source: sqlite3mc`); its default `sqleet` ChaCha20-Poly1305 scheme uses the runtime pragma name `chacha20`. The project includes its MIT license notice in the future app license screen.
2. Define versioned local tables for profile, task, progress entries, and lifecycle events. Preserve original planned dates and event timestamps. Schema version 1 is implemented; sync outbox/cursor tables are deferred to M5.
3. Generate Drift code with `dart run build_runner build`; create all version-1 tables on a new database and enable SQLite foreign keys whenever it opens.
4. Generate a cryptographically random database encryption key and retrieve it through platform secure storage; do not hard-code or log it. If the key is missing or secure storage was reset, fail closed and explain that the local database cannot be opened; never silently replace the key and present unreadable guest data as an empty database.
5. Task repository supports profile-scoped create/read/watch/update/delete. Updates preserve lifecycle state; deletes rely on foreign-key cascades.
6. Progress repository supports profile-scoped create/read/watch/update/delete; validate each entry with `TaskRules` and keep its task association fixed during correction.
7. Lifecycle repository supports profile-scoped completion and reopening; each status update and lifecycle event is saved in one transaction and validated through `TaskRules`.
8. Scope every task, progress, and lifecycle operation by the active local profile ID.
9. Implemented: create or retrieve the stable guest profile in a transaction and expose the initialized database and profile-scoped task, progress, and lifecycle repositories through Riverpod providers.

**What you learn:** Drift maps typed Dart code to SQLite tables and queries. A database migration changes a user's local schema safely as the app evolves. Encryption protects the database file at rest; secure storage protects the key. A repository hides the storage mechanism from UI code, which makes future remote sync easier to add.

**Review checkpoint:** Confirm the SQLite3MultipleCiphers `cipher` pragma is available before opening the database, a record survives app restart, profile scoping is explicit, encrypted storage opens on the supported Android target, and schema upgrade behavior is understood before task UI depends on it. Missing encryption support or key material must fail closed. iOS native verification requires macOS/Xcode and remains a separate platform check.

### M2-D — Task create/read/update/delete journey

**Goal:** Complete the first end-to-end task journey from form to local database to list/detail.

**Planned work:**

1. Add the task creation form with the required topic, dates, and effort; optional subtopic, description, and maximum end date.
2. Use date pickers and an explicitly labeled numeric effort input in hours. Keep date-only values as date-only domain values.
3. Validate before saving; show field-specific messages and retain the user's input after errors.
4. Save through an application/provider layer into the repository, then show the new task in its derived list.
5. Implemented: task cards open task details through an application query; the edit form reuses task validation while the use case preserves ID, profile, creation time, and lifecycle state; task details offer confirmed deletion with an explicit warning that progress/lifecycle history is removed too.
6. Handle loading, empty, saved, and recoverable error states without blocking unrelated navigation.

**What you learn:** A form is a presentation layer; validation and save rules belong in reusable application/domain code. A provider can connect UI state to a repository. SQLite transactions keep related changes together if a write fails midway.

**Review checkpoint:** Create a task with valid data; reject each invalid boundary; edit dates/effort and observe list membership/appearance update; confirm deletion warns about history and removes the task with its dependent entries.

### M2-E — Today, Later, and Completed lists

**Goal:** Make the three top-level views display repository data using one shared classification rule.

**Planned work:**

1. Replace placeholder empty screens with provider-backed lists and useful first-task actions.
2. Today contains open tasks whose start date is today or earlier, including overdue tasks. Show overdue text/icon and red styling where applicable.
3. Later contains open tasks with a future start date. Sort by start date, then planned end date.
4. Completed sorts most recently completed first. Add incremental loading and search/filter if necessary to meet the agreed completed-history scope; retain responsive existing content while fetching another page from local storage.
5. Apply fixed effort bands only to non-overdue current tasks, with accessible labels and numeric hour values.
6. Recompute date-based membership when the app resumes or the IST calendar day changes.

**What you learn:** A list category is derived from task status and dates, rather than being a second status users must maintain. This avoids stale category values when midnight passes. Pagination loads history in manageable chunks instead of reading an unlimited history into memory.

**Review checkpoint:** Review boundary dates (start today, end today, starts tomorrow, end yesterday, completed) and verify every task appears in exactly one correct view.

### M2-F — Progress, completion, and reopening

**Goal:** Preserve the user's work history while making partial progress and full completion distinct actions.

**Implementation and Android journey verification complete.** Progress can be logged as a percentage, completed/total units, or a note; task details show dated history, and entries can be corrected or deleted. Confirmed completion and reopening actions update task state atomically with lifecycle events; task details show the dated events, retaining prior completions after reopening. The owner reported that the progress, completion, and reopening journeys passed on the connected Android phone.

**Implemented behavior:**

1. Implemented: task details show a live progress history and a form with three mutually exclusive progress methods.
2. Implemented: progress is validated and persisted with an application-generated stable ID and occurrence time; multiple entries can be recorded.
3. Implemented: correct a progress entry while preserving its ID, task/profile ownership, occurrence time, and creation time; confirmed deletion removes only the selected entry.
4. Implemented: a separate confirmed Full Complete action updates task status and writes a lifecycle event atomically.
5. Implemented: completed tasks can be reopened after confirmation; the prior completion event remains in the dated history.
6. Implemented: a 100% partial progress entry leaves status OPEN until the user separately chooses Full Complete.

**What you learn:** An event/history record captures what happened and when. Current task status is the latest state, while lifecycle events preserve how it reached that state. A transaction protects the relationship between state and its history.

**Review checkpoint:** Verify partial progress never auto-completes, completion/reopen events are ordered and retained, and correcting/deleting a progress entry affects only that entry.

### M2-G — Persistence and accessibility review

**Goal:** Check the complete guest journey on Android and close M2 with clear known limitations.

**Build evidence (2026-10-17):** Flutter analysis completed with `No issues found!` after the IST-refresh change. The Android debug APK rebuilt successfully using the project JDK (`C:\Users\yuvra\develop\MyTasksToolchains\jdk-25.0.4.1+1`), was installed on the connected Android 12 phone, and launched without database or Flutter exceptions. The owner verified that current and future tasks remained in the expected views after the update and that the accessibility and app-resume checks passed. The machine-level `JAVA_HOME` points to the installed project JDK; for this PowerShell session, the build command can set it explicitly:

```powershell
$env:JAVA_HOME = 'C:\Users\yuvra\develop\MyTasksToolchains\jdk-25.0.4.1+1'
& 'C:\Users\yuvra\develop\MyTasksToolchains\flutter\bin\flutter.bat' build apk --debug --no-pub
```

The project owner manually verified task creation, Today and Later list membership, viewing, editing, progress, completion, reopening, increased display/font size, screen-reader labels, and app resume on the connected Android phone and reported that all checks passed. The assistant independently confirmed that the Today task remained visible after force-stopping and relaunching the app, and found no database or Flutter exceptions in the app process logs. App data was not reset. Code review found that the task category date had been captured when the database stream started, so an open app could keep stale Today/Later membership across IST midnight. The task-list provider now schedules a refresh at the next IST midnight and invalidates when the app resumes. The corrected APK built, installed, and opened successfully; the owner confirmed the post-update checks passed. An exact midnight transition was not observed in real time; the fixed IST scheduling calculation and resume refresh were reviewed, and the Android build was verified. Android journey, persistence, and accessibility checks are complete. iOS device/simulator verification remains pending until macOS/Xcode is available.

**M2-G verification record:**

1. Complete: the owner exercised task creation, Today/Later membership, viewing, editing, progress, completion, and reopening; persistence after restart was confirmed.
2. Complete: Android accessibility review covered enlarged text/display, screen-reader labels, touch controls, contrast, and text/icon cues; the owner reported no issues.
3. Complete: Flutter analysis reported `No issues found!`; the post-fix Android debug APK built, installed, and opened without database or Flutter exceptions.
4. Complete: Today/Later recomputation is scheduled for the next IST midnight and on app resume. The owner confirmed the post-update list and resume checks passed. The exact midnight instant was not observed in real time; iOS device/simulator verification remains pending until macOS/Xcode is available.

**What you learn:** Manual verification checks the user journey end to end; static analysis and builds catch different classes of problems. Accessibility review checks that information remains understandable for users who do not perceive color or use default text size.

## 5. M2 exit criteria

M2 completion record — all Android guest MVP exit criteria were demonstrated or reviewed on 17 October 2026. iOS validation is a documented platform follow-up that requires macOS/Xcode.

- Guest can create, view, edit, and delete tasks without an account or network connection.
- Topic, optional fields, date order, maximum date, and effort validation match the LLD.
- Today, Later, and Completed membership follows the IST rules, including overdue open tasks remaining in Today.
- Current effort styling uses the selected fixed five-level mapping; overdue styling takes precedence; status and effort are understandable without color alone.
- Partial progress supports percentage, units, or note as exactly one method; entries can be reviewed, corrected, and deleted.
- Full completion and reopening are separate from partial progress, with lifecycle history retained while the task exists.
- Local data survives app restart; task and related history changes behave consistently; data access is scoped to the active local profile.
- Android Flutter analysis and debug build succeed using documented commands; manual Android journey and accessibility observations are recorded.
- No sign-in, backend API dependency, sync, reminders, timer, or calendar has accidentally become a requirement for guest task use.
- iOS verification status and the Mac/Xcode requirement are explicit.

## 6. Commands and what they do

Run from the repository root in PowerShell unless a command says otherwise. These commands can create or update local package/build artifacts; they do not commit or push code.

```powershell
cd "F:\MY PROJECT\MyTasks\frontend"
& "C:\Users\yuvra\develop\MyTasksToolchains\flutter\bin\flutter.bat" pub get
```

`pub get` resolves packages from `pubspec.yaml` and updates the tracked `pubspec.lock` when dependencies change. Review that lockfile change as part of the same approved file batch.

```powershell
& "C:\Users\yuvra\develop\MyTasksToolchains\flutter\bin\flutter.bat" analyze
```

`analyze` checks Dart/Flutter code for static issues; it does not launch the app or prove runtime behavior.

```powershell
& "C:\Users\yuvra\develop\MyTasksToolchains\flutter\bin\flutter.bat" build apk --debug
```

`build apk --debug` compiles and packages a development Android APK under `frontend/build/`. The build output is generated locally and ignored by Git; it is not the release/store build.

If a later batch adds Drift code generation, the exact generator command and generated files will be documented before running it. Do not run database-reset/deletion commands as a routine check; they can erase guest data.

## 7. Out of scope and handoff

- **M3:** local reminders, permission onboarding, notification privacy, scheduling/recovery, platform behavior. Android ongoing notifications are not promised to be unhideable.
- **M4:** Java task/account APIs, authentication, cloud deployment, and server-owned task data.
- **M5:** outbox, sync, guest transfer, and conflict resolution.
- **Later:** study timer and calendar view, with original-versus-actual schedule reporting.

The local task IDs, profile boundary, progress/lifecycle history, original planned dates, and repository interface should support these later phases. Do not implement speculative sync queues or backend endpoints as part of M2.

## 8. Mini glossary

| Term | Meaning in M2 |
|---|---|
| Domain model | Dart types and rules that describe tasks independently of UI and storage. |
| Repository | An interface/layer the rest of the app uses to read and change data without depending directly on SQL. |
| Drift | A Dart library that generates typed database access code for SQLite. |
| SQLite3MultipleCiphers | An SQLite-compatible encryption extension; the selected default cipher is sqleet ChaCha20-Poly1305. |
| Migration | A versioned change to local database structure that preserves/updates existing user data. |
| Provider | A Riverpod-managed value or operation that UI can observe and use. |
| Event history | Dated records such as progress, completion, and reopening, retained alongside the current task state. |
| IST date-only value | A calendar date interpreted in India Standard Time, without a UTC time component. |
