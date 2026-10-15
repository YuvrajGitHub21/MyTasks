# Phase-wise Implementation Plan

**Project:** MyTasks mobile application  
**Status:** Execution plan approved by project owner; M0 complete, M1 in progress

**Date:** 16 October 2026

**Related:** [Implementation Roadmap](Implementation-Roadmap.md), [FRS](FRS.md), [HLD](HLD.md), [LLD](LLD.md), [UI flow and preview](UI-Flow-and-Wireframe.md)

## How we will work

Each phase should produce a reviewable artifact or running increment. Keep scope small, record decisions in the relevant document, and finish a phase only when its exit checks are met. The currently approved preview is the visual direction; implementation should preserve its clear Today/Later/Completed navigation and effort-based green treatment while meeting the fuller requirements in the FRS.

## M0 — Product and UX readiness

### M0.1 — Baseline the approved direction

- Record that the current clickable preview is approved as the MVP visual baseline.
- Keep the HTML preview in `Documentation` as a reference artifact; it is not the production app.
- Check that the product naming and terminology are consistent across the FRS, UI flows, and preview.

**Review artifact:** documented approval and a clean link to the preview.

### M0.2 — Close MVP user journeys

Specify entry, loading, empty, error, validation, and success behavior for:

- First launch, guest use, sign-in, and later guest-to-account transfer.
- Task creation/editing, detail, deletion, and date validation.
- Partial progress, progress correction, completion, and reopening.
- Current, scheduled, and completed lists, including overdue tasks and empty states.
- Reminder setup and permission denied behavior.
- Offline changes, sync status, conflict resolution, and account deletion.

**Review artifact:** each journey maps to screens and the applicable FRS/LLD rules.

### M0.3 — Lock visible rules and accessibility

- Specify effort input precision/range and deterministic effort-to-green thresholds.
- Define overdue styling, progress indicators, task counts, sorting, and date labels.
- Ensure status is understandable without color alone; include text/icon cues and screen-reader labels.
- Define validation copy and confirm date/time behavior uses the agreed India Standard Time rules.
- Note platform limits for persistent notifications; do not imply that a mobile OS guarantees an unhideable notification.

**Review artifact:** concise component/state rules suitable for Flutter implementation.

### M0.4 — M0 exit review

Review the above against the FRS and UI prototype. Resolve contradictions in the source docs, mark remaining questions explicitly deferred, and update the roadmap revision/approval status.

**Exit gate:** every MVP journey has a reviewed flow, visible field rules and validation are defined, effort/overdue visuals are accessible, and unresolved decisions are recorded.

**M0 completion record — 16 October 2026:** The project owner approved the current preview as the visual baseline and approved all four execution decisions below. The wireframe now defines shared loading/empty/error behavior and field validation messages; effort thresholds and accessible labels are selected; notification scheduling is consistently defined in IST. Calendar and study timer remain deferred. The UI preview remains a design reference; accessibility contrast and device behavior will be verified during implementation on supported platforms.

| M0 phase | Result |
|---|---|
| M0.1 Baseline approved direction | Complete — preview approval recorded. |
| M0.2 MVP user journeys | Complete — required first-release flows and common state behavior are described in the UI document. |
| M0.3 Visible rules/accessibility | Complete — field limits, validation messages, effort scale, overdue treatment, and non-color cues are recorded. |
| M0.4 Exit review | Complete — IST reminder wording aligned across requirements; later features remain explicitly deferred. |

## M1 — Repository and engineering foundation

### M1.1 — Establish project structure and build conventions

Create and maintain these top-level areas:

```text
Documentation/   requirements, designs, decisions, and preview
frontend/        Flutter mobile app
backend/         Java Spring Boot API and worker
infrastructure/  infrastructure as code (add when provisioning starts)
```

Add root contribution/build notes, formatting conventions, and clear ownership boundaries. Keep secrets out of source control.

### M1.2 — Make local builds reproducible

- Set up Flutter stable and Android/iOS project configuration in `frontend/`.
- Select current stable compatible Flutter packages at scaffold time and commit `pubspec.lock`.
- Set up Java 25 LTS and Spring Boot in `backend/`, including Maven Wrapper and pinned dependency management.
- Add formatter/static analysis configuration and document exact build commands.
- Add a lightweight CI workflow for formatting, static analysis, and builds once repository hosting is selected.

**Review artifact:** documented clean-checkout build steps and lock/configuration files.

### M1.3 — Add development configuration and service skeleton

- Provide local development profiles with safe defaults and environment variable configuration.
- Add a versioned API contract baseline, structured error response shape, and health/readiness endpoints.
- Add the PostgreSQL development schema migration baseline and verify migration startup locally.
- Define API/worker entry points and module boundaries; defer production cloud provisioning until credentials, billing, and environment ownership are ready.
- Capture third-party license and SQLCipher Community notice requirements for the future app licenses screen.

**Review artifact:** app and backend start locally; backend health and database migration can be inspected; no secret is committed.

### M1.4 — M1 exit review

Use a clean checkout to follow the written setup instructions. Review dependency versions, API contract, configuration, and repository structure before feature work begins.

**Exit gate:** reproducible local Android/iOS and Java builds, documented commands, safe configuration patterns, API health endpoint, and working initial migration. Cloud resources are an explicit follow-on if local setup is complete first.

### M1 progress record — 16 October 2026

- M1.1: top-level `Documentation/`, `frontend/`, and `backend/` layout and root ignore rules are in place.
- M1.2: Java 25.0.4.1, Maven Wrapper 3.10.0, and Spring Boot 4.1.1 API/worker entry points are installed/configured. The backend compile-only build succeeds with tests skipped.
- M1.3: local PostgreSQL 18.6 Compose configuration, environment-variable database settings, Actuator health endpoints, and Flyway schema baseline are in place.
- M1.2: Flutter 3.47.7 / Dart 3.13.5 is installed; the Android/iOS scaffolds and `pubspec.lock` are in place. Flutter static analysis reports no issues, and an Android debug APK builds successfully. The first build installed the required Android NDK 28.2.13676358.
- M1.3: PostgreSQL 18.6 Compose configuration, environment-variable database settings, Actuator health endpoints, and Flyway schema baseline are in place. `docker compose config --quiet` succeeds. The Docker CLI is installed, but the Docker Desktop engine is not running, so the database migration could not yet be exercised against a running local database.
- Remaining before M1 exit: start the local Docker engine and exercise the PostgreSQL migration, verify setup from the documented commands, and perform iOS build verification on macOS/Xcode. Windows cannot produce an iOS build. No automated tests have been added or run.

## After M1 — First product increment

Follow the roadmap’s first implementation slice in `frontend/`: launch as guest, create a task, see it in the correct list with effort-based shading, record partial progress, complete it, and verify local persistence after restart. Keep the backend scaffold available, but avoid making basic task use depend on network or accounts. Add backend APIs and account sync after the local model and behavior are stable.

## Approved execution decisions

The project owner approved all four choices on 16 October 2026:

1. The approved HTML is a design reference; production UI is rebuilt in Flutter.
2. M0 includes finishing edge states/accessibility rules for flows beyond the basic preview.
3. M1 creates local reproducible builds first; cloud infrastructure is staged when environment ownership and credentials are ready.
4. The first product slice is guest/local-first, with backend account/sync work sequenced later as in the roadmap.
