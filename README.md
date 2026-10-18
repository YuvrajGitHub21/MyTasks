# MyTasks

A cross-platform task planning app, designed for guest use first and account sync later.

## Project layout

- [`Documentation/`](Documentation/Implementation-Plan.md) — requirements, architecture, detailed design, UI preview, implementation plan, and [project working agreement](Documentation/Working-Agreement.md).
- [`frontend/`](frontend/README.md) — Flutter Android/iOS application.
- [`backend/`](backend/README.md) — Java 25 / Spring Boot API and worker.
- `infrastructure/` — to be added when development cloud resources are ready to be managed as code.

## Current status

The current release target is V1: a polished, offline-first Flutter app with encrypted local task, reminder, and study-session storage. The Study timer is implemented with task linking, timed breaks, daily focus totals, and session history. Flutter tests and an Android debug build are part of the V1 verification flow. Android real-device regression checks, an accessibility walk-through, iOS build/runtime validation on macOS/Xcode, and public-release privacy/store review remain before V1 is release-ready. The Java/Spring Boot backend, accounts, and cloud sync are V2. See the [V1 implementation plan](Documentation/V1-Implementation-Plan.md) and [project working agreement](Documentation/Working-Agreement.md).

## Run the Flutter app

From `frontend/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

The encrypted Drift database is local to the app installation. A Study session uses saved timestamps, so elapsed time is reconstructed after the process is closed; it does not keep a background service running. Scheduled break-end alerts are ordinary OS notifications and depend on notification permission. iOS builds require macOS and Xcode.
