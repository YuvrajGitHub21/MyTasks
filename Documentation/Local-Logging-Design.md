# Local Diagnostic Logging Design

**Status:** Implemented and independently reviewed; Android debug build starts on the connected phone. Owner walkthrough and iOS runtime verification remain.
**Date:** 18 October 2026

## 1. Goal and scope

Help diagnose issues reported from another phone without requiring the owner to reproduce them. The app records important state changes and errors locally on that device. Logs are not uploaded, and the logger does not record screen contents, other-app usage, task titles, topics, descriptions, progress notes, or other user-entered text.

## 2. Architecture and data flow

```text
Flutter framework/platform errors + application use cases + startup
                              |
                       DiagnosticLogger
                              |
                 event allowlist and redaction
                              |
                  serialized fire-and-forget queue
                              |
       separate encrypted SQLite diagnostics database
                              |
     7-day UTC pruning; 2 MiB database page limit
```

The domain-facing contract is `DiagnosticLogger`; `LocalDiagnosticLogger` and `EncryptedDiagnosticLogStore` are infrastructure adapters. Application actions do not wait for writes. Queue ordering prevents records from interleaving. Failures are caught inside the logger and reported to the developer console without recursively logging them or changing the result of a task, reminder, progress, lifecycle, or study action.

The diagnostics database is a separate file in the app-private support directory. It has its own random 256-bit key in Android/iOS secure storage and does not reuse the task database key. SQLite3MultipleCiphers protects database pages with the configured `chacha20` ChaCha20-Poly1305 cipher. A severity/time index supports a separate error query. Diagnostic storage can fail without opening or modifying the task database.

## 3. Record format and privacy

Each decrypted record contains schema version, UTC timestamp, random event ID, severity, stable event name, feature, and allowlisted structured attributes. Error records also contain a safe error type, a generic privacy message, and a bounded stack trace with path-like or quoted frames removed. Raw exception messages are omitted because platform and database errors can echo personal data.

Event names are stable values such as `task.create.succeeded`, `reminder.schedule.failed`, and `study.session.start.succeeded`. Activity records describe completed or failed use-case operations; they do not record widget rebuilds or every tap. Attribute names and values are allowlisted and constrained. Task IDs and free-form text are not logged.

## 4. Initialization and error capture

`main` installs Flutter framework and `PlatformDispatcher` error hooks before initializing diagnostics and before `runApp`. Flutter framework errors still use `FlutterError.presentError`; uncaught async errors are printed to the console after being submitted to the local logger. Diagnostic initialization runs before the task database can open. Notification setup and database-open failures are also recorded with feature context.

Logging is best effort. If secure storage or encrypted database setup fails, the app continues and reports the logging failure through the console. If the key is missing while the log database already exists, the logger does not create a replacement key or overwrite those records.

## 5. Retention and storage bound

On initialization and before writes, records older than seven days are deleted using UTC timestamps. Android and iOS do not guarantee that a closed app will be woken just to run cleanup, so an unused device can retain expired encrypted rows until the next app launch; reads still exclude records outside the seven-day window. The encrypted database is capped at 512 4-KiB pages (2 MiB). If a write reaches the cap, SQLite auto-vacuum reclaims deleted pages; oldest debug/info records are evicted first, then warnings. Errors are retained while lower-severity records can be dropped. Old errors are evicted only to make room for a new error/fatal record after lower-severity records are gone. If there is no eligible space, the new record is dropped; app operations still succeed.

## 6. Current event coverage and limits

The app records task create/update/delete, progress create/update/delete, task complete/reopen, reminder preference saves, snooze-event imports, reminder reconciliation, study start/break/resume/stop, reminder-initializer failures, database-open failures, Flutter framework errors, and uncaught platform async errors. Reminder times, alarm IDs, snooze payloads, and task IDs are omitted. A future screen/export action may read recent records and errors; no UI export or Java upload is included in this phase.

No log can be guaranteed for abrupt process termination, device power loss, or native crashes before Flutter regains control. These records explain useful app operations; they are not a complete replay of user activity.

## 7. Future export and backend upload

Backend upload is out of scope. Later, add an explicit review/export flow that explains what will be shared, lets the user inspect the date range, and requires a deliberate action. Export data should be decrypted only in memory, redacted again, and include a schema version. A Java endpoint must use authentication, size limits, and reviewed consent and retention rules. Logs must never upload automatically by default.

## 8. Verification

Focused tests cover ciphertext at rest, readback, UTC seven-day pruning, missing-key preservation, concurrent queued writes, sensitive-text exclusion, logger-failure isolation, and the 2 MiB size bound. The full Flutter suite passes 27 tests. `flutter analyze` reports no errors or warnings and 20 info-level `prefer_initializing_formals` suggestions.

The Android debug APK built successfully, installed with `adb install -r` on the connected M2102J20SI, and launched. The app-private diagnostics database was created at `files/mytasks-diagnostics.sqlite` (24 KiB); no Flutter, database, or cipher startup error appeared in the inspected logcat window. This verifies Android startup and encrypted-store initialization, but not every error-hook path by manual device interaction. The owner should complete the checklist below before calling V1 diagnostics accepted. iOS behavior still requires macOS/Xcode runtime verification.

### Owner phone walkthrough

1. Open **Study**, tap **Start studying**, and confirm the task-choice sheet appears immediately.
2. Start linked and unlinked sessions; verify they stay responsive and saved task/session data remains intact after restarting the app.
3. Create/update/delete a task; add/edit/delete progress; complete/reopen a task; change a reminder setting; trigger a reminder/snooze path. Confirm expected app behavior is unchanged.
4. Background and reopen the app; check active study time and reminders still behave as before.
5. Report any visible failure with the screen and action. The logger stores diagnostics locally, but there is no log viewer/export yet; log retrieval is a later explicit sharing feature.
