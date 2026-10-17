# Implementation Roadmap

**Project:** Personal and public task planning mobile application  
**Status:** Proposed delivery sequence based on the approved requirements and design  
**Version:** 0.3  
**Date:** 16 October 2026  
**Sources:** [FRS.md](FRS.md) v0.5, [HLD.md](HLD.md) v0.4, [LLD.md](LLD.md) v0.4

## 1. Purpose

This roadmap turns the agreed product and technical designs into an ordered, reviewable build plan. It defines what to implement, the dependency order, and the evidence required to call each milestone complete. It does not estimate calendar duration; that requires a decision about developer availability and working cadence.

## 2. Delivery principles

- Build the core task experience locally first so a user can get value without an account or network.
- Add the backend and account features after the task model and local behavior are stable.
- Prove offline synchronization and conflict handling with a small end-to-end slice before expanding it to every operation.
- Keep API and worker deployments modular but independently scalable; do not introduce microservices or database sharding without measured need.
- Treat Android and iOS notification behavior as platform-specific and best effort, and test each on real devices before release claims are made.
- Keep account data private by default. “Public” means public app availability, not public task visibility.
- Ship the study timer and calendar as later scope, while preserving task date and progress history needed to support them.

## 3. MVP release boundary

The first usable release includes:

- Android and iOS app with guest use and Google sign-in; iOS also supports Sign in with Apple.
- Task creation, viewing, editing, deletion, completion, reopening, and the current, scheduled, and completed lists.
- Required topic, start date, planned end date, effort estimate, optional subtopic/description, and optional maximum end date.
- Today/overdue classification, deterministic effort-based green shades, and overdue styling with accessible text/icon cues.
- Partial progress logs, progress history, and correction/deletion of logs.
- India Standard Time rules, configurable reminders, guest local reminders, signed-in push reminders, and privacy-safe notification previews.
- Offline access and edits for signed-in users, durable sync, guest-to-account transfer, and user-mediated same-field conflict resolution.
- Account deletion with the documented retention behavior, basic operational monitoring, and release support information.

Study timer, calendar view, data export, collaboration, recurring tasks, and advanced analytics are outside this MVP.

## 4. Milestones

### M0 — Product and UX readiness

**Goal:** Turn the approved requirements into concrete first-release screen and behavior specifications.

**Work:**

- Confirm the MVP user journeys: guest onboarding, sign-in, task create/edit, daily list, task detail, progress log, completion/reopen, reminder setup, sync conflict, and account deletion.
- Create low-fidelity screen flows and a compact visual system for typography, spacing, buttons, fields, status, colors, and accessibility. First pass: [UI Flow and Wireframes](UI-Flow-and-Wireframe.md).
- Select deterministic effort-to-green thresholds and accessible overdue/current visual treatments.
- Confirm the user-facing effort entry/display as hours and apply the chosen range and precision from the LLD.
- Carry the selected behavior and validation rules from the FRS/LLD into the screen flows; keep calendar and timer questions explicitly deferred.
- Use Android 7.0/API 24 and iOS 15.0 as minimum supported OS versions. Target current SDK levels required by Google Play and App Store Connect at submission time.
- At scaffold, use latest stable compatible Flutter packages (no prereleases) and commit the exact resolved versions in `pubspec.lock`.

**Exit criteria:** Every MVP journey has a reviewed screen flow; all user-visible field rules and validation messages are defined; green/overdue styling is specified without relying on color alone; unresolved product questions are either answered or explicitly deferred.

### M1 — Repository and engineering foundation

**Goal:** Create reproducible Android/iOS and Java backend builds with clear boundaries.

**Work:**

- Establish a repository layout for the Flutter app, Java Spring Boot API/worker, infrastructure, and project documentation.
- Pin supported Flutter and Java 25 LTS toolchains; use Maven Wrapper and committed dependency lock/configuration files.
- Create local, development, staging, and production configuration patterns. Keep credentials out of source control.
- Add formatting/static analysis conventions, environment configuration, structured error handling, and a versioned API contract baseline.
- Provision development Google Cloud resources using infrastructure-as-code, including Cloud Run, Cloud SQL PostgreSQL, Cloud Tasks, Secret Manager, and logging/monitoring.
- Record SQLite3MultipleCiphers MIT notices and third-party license handling for an in-app licenses screen.

**Exit criteria:** A clean checkout can build the mobile app and backend using documented commands; development deployments run with non-production credentials; API health checks, database connectivity, secret loading, and schema migration are observable.

### M2 — Local-first task app (guest MVP core)

**Status: Complete — 17 October 2026.** Android guest task journeys, local persistence, accessibility review, Flutter analysis, and debug build passed. The IST day refresh was added and verified after app resume. iOS build/device validation remains pending until macOS/Xcode is available. See [detailed M2 implementation plan](M2-Implementation-Plan.md).

**Goal:** Deliver a reliable, useful task application before depending on the network.

**Work:**

- Implement app bootstrap, guest profile, navigation, local repository boundaries, and encrypted Drift/SQLite storage.
- Implement task create/read/update/delete and validation in the domain layer and local store.
- Implement current, scheduled, and completed lists with IST date classification, overdue handling, and incremental loading for completed history.
- Implement task detail, completion/reopen history, progress logs, correction/deletion, and empty states.
- Implement accessible effort-green mapping and overdue red treatment from M0.
- Implement profile isolation and local database key lifecycle through platform secure storage.

**Exit criteria:** Guest can create and manage tasks offline; list membership matches the agreed date rules; invalid values are rejected consistently; progress/completion history is preserved as specified; app relaunch keeps data; profiles cannot see one another's local data; screens meet the agreed accessibility review.

### M3 — Reminders and platform behavior

**Status: Plan prepared; implementation not started.** See [detailed M3 implementation plan](M3-Implementation-Plan.md).

**Goal:** Deliver local guest reminders and validate notification expectations on Android and iOS.

**Work:**

- Add notification permission onboarding, privacy-safe task summary, deep links to today's list, reminder preferences, and quiet hours.
- Schedule guest reminders for no-task times (09:00 and 12:00 IST) and the end-of-day logging check (default 22:00 IST).
- Recompute local reminders after task/progress/preference changes, app start, day rollover, and device restart where supported.
- Prototype Android ongoing-notification behavior only if a valid foreground use case exists; retain the documented platform limitation.
- Test permission denied, notification disabled, reboot, timezone configuration, duplicate prevention, and task changes near dispatch time.

**Exit criteria:** Guest reminder predicates match the FRS; duplicate reminders are prevented; notifications reveal no task names by default; app behavior remains usable when permission is denied; Android/iOS behavior and limitations are documented from device validation.

### M4 — Java backend and signed-in account

**Goal:** Provide a secure server-side account and task API on the chosen stack.

**Work:**

- Implement Java 25 LTS / Spring Boot modular monolith with API and worker entry points, DTO validation, OpenAPI, Flyway migrations, and JDBC repositories.
- Add Google and Apple identity-token verification and application sessions with 15-minute access tokens and rotating refresh tokens. Google sign-in is available on Android/iOS; Sign in with Apple is available on iOS. Do not auto-link accounts by matching email.
- Implement owner-scoped task, progress, lifecycle, preference, and device APIs with idempotency and pagination limits from the LLD.
- Add database constraints, indexes, transaction boundaries, account state, and session revocation.
- Add structured logs, correlation IDs, health/readiness endpoints, metrics, and secret management without logging task contents or tokens.
- Deploy the API and worker separately to Cloud Run and connect to Cloud SQL through the Java connector.

**Exit criteria:** Signed-in users can securely create/read/update/delete their own cloud data; another account cannot read or mutate it; Google and Apple tokens are verified server-side; migrations work on a clean database and a prior schema; API errors and operational health are observable.

### M5 — Offline sync, guest transfer, and conflict resolution

**Goal:** Safely reconcile local edits with cloud state across reconnects and devices.

**Work:**

- Implement a durable local outbox, idempotent mutation IDs, ordered bounded batches, delta pull cursor, and tombstone handling.
- Implement task-field versions and same-field conflict responses; present both values and let the user choose.
- Allow disjoint-field updates to merge only after server validation of the resulting task.
- Implement guest-to-account transfer with duplicate detection, progress/history transfer, retry, and a clear completion/failure state.
- Ensure deletes, account deletion, late offline writes, and conflict resolution do not resurrect removed data.
- Add sync status, pending changes, retry, and sign-in recovery UI.

**Exit criteria:** Offline create/edit/delete and progress changes eventually sync exactly once; retry does not duplicate records; same-field concurrent edits require user resolution; separate-field updates preserve both valid changes; transfer can resume safely after interruption; tombstones prevent deleted tasks from returning.

### M6 — Signed-in reminders and production readiness

**Goal:** Complete account-based reminders and prepare a safe private pilot/public release.

**Work:**

- Register and retire device push tokens; connect Cloud Scheduler and Cloud Tasks to reminder evaluation and Firebase Admin/APNs delivery.
- Re-evaluate task/log state before sending; deduplicate by user/device/reminder/date/time; expire stale jobs; configure retry and queue limits.
- Implement in-app and provider-authenticated web account deletion, immediate session revocation, active primary-data removal within 7 calendar days, 30-day backup expiry, and 90-day deletion-ledger replay after restore.
- Publish a privacy policy in-app and in store listings, provide a public web account-deletion request page, and complete Google Play Data safety/deletion disclosures.
- Implement the privacy baseline: no ads, cross-app tracking, or product analytics; optional crash diagnostics off by default and content-redacted; routine operational logs retained 30 days, security/audit events 90 days, and inactive/invalid push tokens 90 days.
- Configure backups, restore procedure, monitoring/alerts, rate limits, crash reporting/privacy controls, and release rollback.
- Complete security and privacy review, app-store disclosures, operational ownership, support path, and public data-retention explanation.
- Run a private pilot and measure active usage, peak sync load, queue fan-out, database growth, crash rate, and support issues before public scale commitments.

**Exit criteria:** Reminder delivery is best effort, correctly deduplicated, and measured; deletion is operationally demonstrable including restore behavior; backup restore and rollback procedures have been rehearsed; no cross-account data leakage is observed in security review; pilot metrics support an approved availability, recovery, and capacity plan.

## 5. Dependency order

```text
M0 Product/UX readiness
  └─ M1 Build foundation
       └─ M2 Local-first task app
            ├─ M3 Guest reminders
            └─ M4 Backend and signed-in account
                 └─ M5 Offline sync and guest transfer
                      └─ M6 Signed-in reminders and release readiness
```

M3 and M4 can overlap after M2 defines stable task/progress contracts. M5 depends on both the local model and backend mutation semantics. M6 depends on signed-in identity, device registration, and reminder rules.

## 6. First implementation slice

The first coding slice should be one end-to-end guest task journey, not broad scaffolding across every feature:

1. Launch into guest mode.
2. Create a task with topic, dates, and effort.
3. See it in the correct current/scheduled list with its visual state.
4. Open it, record one partial-progress entry, and see that entry in history.
5. Complete the task and see it move to Completed.
6. Restart the app and verify the task and history persist.

This slice validates routing, screen patterns, local data modeling, date rules, visual design, and persistence before backend sync adds complexity.

## 7. Cross-cutting completion standards

Each milestone is complete only when:

- The product behavior matches the relevant FRS requirement IDs.
- User-facing loading, empty, validation, error, and offline states are handled.
- Accessibility is checked for screen readers, scalable text, contrast, and color-only cues.
- Sensitive data and credentials are excluded from logs and analytics.
- API/database changes are versioned and migration behavior is documented.
- Operationally relevant failures are visible through safe logs/metrics.
- Documentation and decision records reflect the implementation.

## 8. Deferred after MVP

The following should be estimated and planned as separate roadmap increments after MVP feedback:

- Calendar view with original planned interval, actual completion date, and extension visualization.
- Study timer with session pause/background/recovery rules and optional task linkage.
- Portable data export, recurring tasks, checklists/subtasks, reusable categories, richer search/filter, widgets, and advanced reports.
- Collaboration or shared tasks only if the product direction changes; private per-user task data remains the MVP default.

## 9. Selected defaults and production review gates

These defaults are selected and should be implemented as stated:

- Minimum OS: Android 7.0/API 24 and iOS 15.0.
- Flutter package policy: latest stable compatible versions at scaffold; commit exact resolved versions in lockfiles and update on a planned cadence.
- Privacy baseline and retention windows from the FRS/LLD: no ads or product analytics; opt-in redacted crash diagnostics; 30-day routine logs, 90-day security/audit logs, 90-day inactive/invalid push tokens; active account data remains until user deletion; account backups expire within 30 days.
- Account deletion: in-app and provider-authenticated public web request paths; active primary data removed within 7 days, backups expire within 30 days, Google Play Data safety disclosures and app-store privacy-policy links.

Production planning inputs and external review gates:

- DAU, peak concurrent requests, push opt-in rates, expected task/progress history volume, availability/latency and RPO/RTO targets, queue backlog target, support response target, cloud budget, and disaster-recovery expectations.
- Qualified review of current India privacy-law commencement/applicability and final privacy, processor, and retention disclosures before public launch. India's DPDP Rules have phased commencement; engineering defaults do not determine legal compliance.
- Re-check store policies, required SDK levels, and package maintenance status before each public release.
