# Low-Level Design (LLD)

**Project:** Personal and public task planning mobile application  
**Document status:** Implementation baseline selected  
**Version:** 0.5
**Date:** 16 October 2026  
**Parent documents:** [FRS.md](FRS.md) v0.5 and reviewed [HLD.md](HLD.md) v0.4

## 1. Purpose and design boundary

This document turns the approved HLD into implementable modules, records, endpoint behavior, state transitions, sync rules, and reminder evaluation. The user delegated remaining implementation choices; this revision selects a recommended stack and operating defaults. Names and SQL below define a logical contract; migrations may adapt details while preserving these behaviors.

## 2. Design principles

- The local database is the app's immediate source of truth for display and offline work.
- Signed-in cloud data is the synchronization source of truth after accepted server mutations.
- Every hosted data operation is scoped to the authenticated internal user ID.
- Date-only task fields are dates in India Standard Time (IST), not UTC timestamps.
- Progress and lifecycle changes are events; task status and list membership are derived from task dates plus completion state.
- Same-field divergent offline edits require explicit user resolution. Different-field edits may merge after validation.
- Task deletion removes task history. A minimal sync tombstone exists only long enough to propagate that deletion to devices.
- UI state management, database, API transport, notifications, and authentication are hidden behind app services/repositories.

## 3. Proposed module structure

### 3.1 Flutter client

```text
lib/
  app/                 app bootstrap, routes, dependency setup
  features/
    tasks/              task list/editor/detail, task view models
    progress/           partial log and completion/reopen flows
    reminders/          preferences UI and schedule coordinator
    account/            guest, Google/Apple sign-in, transfer, deletion
    settings/           time and notification preferences
  domain/
    entities/           Task, ProgressLog, ReminderPreferences
    rules/              date classification, validation, reminder predicates
    repositories/       repository contracts
  data/
    local/              SQLite DAOs and migrations
    remote/             HTTPS API client and DTOs
    sync/               outbox, upload, pull cursor, conflicts
    notifications/      Android/iOS notification adapters
    auth/               Google/Apple sign-in adapters and secure token storage
  shared/               errors, date/number formatting, accessibility helpers
```

Use a presentation layer, domain rules, and data repositories. A repository coordinates local and remote sources; widgets do not issue SQL or network calls directly. Flutter's architecture guidance recommends clear UI/data layers and repositories as the source of truth for app data. [Flutter app architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)

### 3.2 Hosted backend

```text
server/
  api/                  HTTP routes, authentication middleware, validation
  modules/
    identity/           provider token exchange, sessions, account deletion
    tasks/              task CRUD, date classification, lifecycle transitions
    progress/           progress log CRUD and validation
    sync/               idempotency, versions, conflict responses, delta feed
    devices/             device registration and push token lifecycle
    reminders/           due checks, notification job creation
  persistence/          repositories, SQL migrations, transaction helpers
  worker/                queue consumers and reminder delivery
  contracts/             OpenAPI spec, shared error codes, payload schemas
```

Deploy API and worker as separate processes from the same modular codebase initially. Keep domain services independent of Spring MVC and JDBC implementation details.

### 3.3 Selected implementation stack

| Layer | Decision | Reason |
|---|---|---|
| Mobile SDK | Flutter stable channel; pin the stable SDK in CI and commit dependency lockfiles | Supports both requested app platforms with one product codebase. Use current stable releases at scaffold time rather than pinning an obsolete SDK in this document. |
| State and dependency wiring | `flutter_riverpod` | Separates UI state from repository/domain services and handles async loading/error states. |
| Local persistence | Drift + SQLite3MultipleCiphers through `sqlite3` 3.x build hooks | Typed relational queries, transactions, migrations, and encrypted local storage. Drift currently recommends SQLite3MultipleCiphers for new encrypted databases; its default `sqleet` cipher is ChaCha20-Poly1305. Include the SQLite3MultipleCiphers MIT notice in the app license notices. [Drift encryption guide](https://drift.simonbinder.eu/platforms/encryption/), [sqlite3 build hooks](https://pub.dev/documentation/sqlite3/latest/topics/hook-topic.html), [SQLite3MultipleCiphers license](https://github.com/utelle/SQLite3MultipleCiphers/blob/main/LICENSE) |
| Networking | `dio` | Centralized timeouts/interceptors and cancellation for authenticated REST calls. |
| Authentication | `google_sign_in` plus `sign_in_with_apple` | Native Google flow on Android/iOS and Apple flow on iOS; backend verifies both provider tokens. Apple's App Review rules require an equivalent option when a third-party provider is used for primary sign-in. [Apple guideline 4.8](https://developer.apple.com/app-store/review/guidelines/) |
| Secret storage | `flutter_secure_storage` | Store account tokens and the local database key through platform secure storage. |
| Notifications | `firebase_messaging` for account push; `flutter_local_notifications` for local guest reminders | Separate remote delivery from local scheduled alerts and platform-specific behavior. |
| Backend language/runtime | Java 25 LTS, updated on a planned security cadence | Long-lived LTS baseline with a mature server ecosystem. [Java SE roadmap](https://www.oracle.com/java/technologies/java-se-support-roadmap.html) |
| Backend framework | Spring Boot 4.1, using Spring MVC | Mature dependency injection, validation, HTTP, and operational conventions; supported with Java 25. [Spring Boot requirements](https://docs.spring.io/spring-boot/system-requirements.html) |
| Database access | JDBC repositories + Cloud SQL Java Connector + parameterized SQL | Explicit transactions/row locks make field-level sync conflict semantics clear; avoids hiding concurrency in generic ORM behavior. [Cloud SQL Java connector](https://cloud.google.com/sql/docs/postgres/connect-connectors) |
| Migrations/API validation | Flyway SQL migrations; Jakarta Bean Validation; OpenAPI via `springdoc-openapi` | Versioned SQL is transparent and API contracts remain reviewable. |
| Build | Maven wrapper; dependency versions managed through Spring Boot dependency management | Reproducible builds without relying on a system Maven installation. |
| Cloud | Google Cloud Run, Cloud SQL for PostgreSQL, Cloud Tasks, Cloud Scheduler, Secret Manager, Cloud Logging/Monitoring; `asia-south1` (Mumbai) for app compute/database | Same-cloud identity/push tooling, managed Postgres, and an India region. [Cloud Run locations](https://cloud.google.com/run/docs/locations), [Cloud SQL region support](https://cloud.google.com/sql/docs/postgres/region-availability-overview) |
| Push sending | Firebase Admin Java SDK; APNs credentials configured for iOS through Firebase | Server sends signed-in reminders through FCM's supported server SDK. [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup), [FCM send](https://firebase.google.com/docs/cloud-messaging/send/admin-sdk) |

Use the latest supported Java 25 security patch. Spring Boot 4.1.1 requires at least Java 17 and supports Java through 26; pin compatible Spring Boot and library versions in Maven configuration. Commit the Maven wrapper and Flutter `pubspec.lock`. Minimum OS is Android 7.0 (API 24) and iOS 15.0. Target Android API 36 or the newer Google Play requirement active at submission; use the current Xcode/iOS SDK required by App Store Connect. Flutter's current matrix supports Android API 24+ and iOS 15+. [Flutter supported platforms](https://docs.flutter.dev/reference/supported-platforms), [Google Play target API policy](https://support.google.com/googleplay/android-developer/answer/11926878)

## 4. Domain model and state rules

### 4.1 Task fields

| Field | Type | Rule |
|---|---|---|
| `id` | UUID | Generated by client on create so offline-created tasks retain identity. |
| `owner_id` | UUID | Internal account ID on server; local profile ID on device. Never accepted as authoritative from a client request. |
| `topic` | String | Required, trimmed, non-empty; maximum 200 characters. |
| `subtopic` | String, nullable | Freely entered; optional; maximum 200 characters. |
| `description` | String, nullable | Optional; maximum 5,000 characters. |
| `start_date` | Date | Required, interpreted in `Asia/Kolkata`. |
| `planned_end_date` | Date | Required; must be on or after `start_date`. Fixed after it passes; never rolled forward automatically. |
| `maximum_end_date` | Date, nullable | Optional hard upper bound; if set, must be on or after `planned_end_date`. |
| `effort_hours` | Decimal | Required total estimate in hours; greater than zero, at most 99,999.99, precision 0.01 hour. Use decimal arithmetic, not binary floating point, in the API/database. |
| `status` | Enum | `OPEN` or `COMPLETED`; list category is derived. |
| `completed_at` | Timestamp, nullable | Set when completed; cleared on reopen. Completion/reopen event remains while task exists. |
| `row_version` | Integer | Monotonically increments for each accepted task mutation. |
| `field_versions` | Map field name to integer | Version at which each mutable field last changed; used for field-level conflict detection. |
| `created_at`, `updated_at` | Timestamp | UTC instants. |

These selected limits are enforced in both client and API. Progress notes are capped at 2,000 characters. The selected five-level green thresholds and accessible card treatment are documented in [UI-Flow-and-Wireframe.md](UI-Flow-and-Wireframe.md); implement them consistently.

### 4.2 Derived task categories

Given `today` in `Asia/Kolkata`:

```text
if status == COMPLETED:
    category = COMPLETED
else if start_date > today:
    category = SCHEDULED
else if planned_end_date < today:
    category = DUE        // shown in Current list, red
else:
    category = CURRENT    // shown in Current list, effort-green
```

This follows the accepted rule that an overdue open task remains in today's Current list. A maximum-end-date breach can be exposed as a separate “past maximum date” flag; it does not change the task's completion state or erase the original dates.

### 4.3 Progress model

Each progress log uses exactly one method:

| Method | Required values | Validation |
|---|---|---|
| `PERCENT` | `percent_complete` | 0–100 inclusive. A log of 100% does not itself complete the task; user chooses Full Complete separately. |
| `UNITS` | `completed_units`, `total_units` | Both positive; completed units cannot exceed total units. |
| `NOTE` | `note` | Non-empty after trim; maximum 2,000 characters. |

Each log has a stable UUID, task ID, user ID, client occurrence time, server receipt time, and row version. Multiple progress logs are allowed over time. One log for a task on the current IST date is sufficient to satisfy the end-of-day reminder condition for that task.

### 4.4 Lifecycle transitions

| Action | From | To | Side effects |
|---|---|---|---|
| Create task | — | `OPEN` | Validate fields; set version 1; create sync change. |
| Partial log | `OPEN` | `OPEN` | Append a progress log; update task `updated_at`/version only if task fields are also changed by the same operation. |
| Full complete | `OPEN` | `COMPLETED` | Set `completed_at`; append `COMPLETED` lifecycle event; bump version. |
| Reopen | `COMPLETED` | `OPEN` | Clear current `completed_at`; append `REOPENED` event; preserve prior lifecycle event. |
| Edit | Either | Same status | Validate resulting task as a whole, including date/max-date relations; bump version and changed-field versions. |
| Delete | Either | Removed | Delete task, progress logs, lifecycle events in one transaction; write sync tombstone/change marker. |

Deletion is hard for the user-visible task and its associated history. A sync tombstone is retained only to tell offline devices not to re-create it; deletion and tombstone retention are separated from task history.

## 5. Persistence design

### 5.1 PostgreSQL logical schema

The following SQL is illustrative PostgreSQL DDL. Migration scripts are authoritative after implementation review.

```sql
CREATE TYPE task_status AS ENUM ('OPEN', 'COMPLETED');
CREATE TYPE progress_method AS ENUM ('PERCENT', 'UNITS', 'NOTE');
CREATE TYPE lifecycle_event_type AS ENUM ('COMPLETED', 'REOPENED');

CREATE TABLE app_users (
  id               uuid PRIMARY KEY,
  email            text,
  account_state    text NOT NULL DEFAULT 'ACTIVE'
                   CHECK (account_state IN ('ACTIVE', 'DELETION_PENDING')),
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE external_identities (
  id               uuid PRIMARY KEY,
  owner_id         uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  provider         text NOT NULL CHECK (provider IN ('GOOGLE', 'APPLE')),
  provider_subject text NOT NULL,
  email            text,
  email_verified   boolean NOT NULL DEFAULT false,
  created_at       timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, provider_subject)
);
CREATE INDEX external_identities_owner_idx ON external_identities (owner_id);

CREATE TABLE app_sessions (
  id                 uuid PRIMARY KEY,
  owner_id           uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  refresh_token_hash bytea NOT NULL UNIQUE,
  device_id          uuid,
  expires_at         timestamptz NOT NULL,
  last_used_at       timestamptz NOT NULL DEFAULT now(),
  revoked_at         timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX app_sessions_owner_active_idx
  ON app_sessions (owner_id, expires_at) WHERE revoked_at IS NULL;

CREATE TABLE tasks (
  id                 uuid PRIMARY KEY,
  owner_id           uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  topic              varchar(200) NOT NULL CHECK (length(trim(topic)) > 0),
  subtopic           varchar(200),
  description        varchar(5000),
  start_date         date NOT NULL,
  planned_end_date   date NOT NULL,
  maximum_end_date   date,
  effort_hours       numeric(7,2) NOT NULL CHECK (effort_hours > 0),
  status             task_status NOT NULL DEFAULT 'OPEN',
  completed_at       timestamptz,
  row_version        bigint NOT NULL DEFAULT 1 CHECK (row_version > 0),
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT task_date_order CHECK (planned_end_date >= start_date),
  CONSTRAINT task_max_date_order
    CHECK (maximum_end_date IS NULL OR maximum_end_date >= planned_end_date),
  CONSTRAINT task_completion_consistency CHECK (
    (status = 'OPEN' AND completed_at IS NULL) OR
    (status = 'COMPLETED' AND completed_at IS NOT NULL)
  ),
  CONSTRAINT tasks_id_owner_unique UNIQUE (id, owner_id)
);

CREATE TABLE task_field_versions (
  task_id       uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  field_name    text NOT NULL,
  field_version bigint NOT NULL CHECK (field_version > 0),
  PRIMARY KEY (task_id, field_name)
);

CREATE TABLE progress_logs (
  id                uuid PRIMARY KEY,
  owner_id          uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  task_id           uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  method            progress_method NOT NULL,
  percent_complete numeric(5,2),
  completed_units   numeric(12,2),
  total_units       numeric(12,2),
  note              varchar(2000),
  occurred_at       timestamptz NOT NULL,
  received_at       timestamptz NOT NULL DEFAULT now(),
  row_version       bigint NOT NULL DEFAULT 1,
  CONSTRAINT progress_owner_task_fk
    FOREIGN KEY (task_id, owner_id) REFERENCES tasks(id, owner_id) ON DELETE CASCADE,
  CONSTRAINT progress_method_values CHECK (
    (method = 'PERCENT' AND percent_complete BETWEEN 0 AND 100
      AND completed_units IS NULL AND total_units IS NULL AND note IS NULL) OR
    (method = 'UNITS' AND completed_units > 0 AND total_units > 0
      AND completed_units <= total_units AND percent_complete IS NULL AND note IS NULL) OR
    (method = 'NOTE' AND length(trim(note)) > 0
      AND percent_complete IS NULL AND completed_units IS NULL AND total_units IS NULL)
  )
);

CREATE TABLE task_lifecycle_events (
  id          uuid PRIMARY KEY,
  owner_id    uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  task_id     uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  event_type  lifecycle_event_type NOT NULL,
  occurred_at timestamptz NOT NULL,
  received_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT lifecycle_owner_task_fk
    FOREIGN KEY (task_id, owner_id) REFERENCES tasks(id, owner_id) ON DELETE CASCADE
);

CREATE TABLE user_devices (
  id             uuid PRIMARY KEY,
  owner_id       uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  platform       text NOT NULL CHECK (platform IN ('ANDROID', 'IOS')),
  push_token     text,
  notifications_enabled boolean NOT NULL DEFAULT true,
  last_seen_at   timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (owner_id, id)
);

CREATE TABLE reminder_preferences (
  owner_id             uuid PRIMARY KEY REFERENCES app_users(id) ON DELETE CASCADE,
  time_zone            text NOT NULL DEFAULT 'Asia/Kolkata',
  no_task_time_1       time NOT NULL DEFAULT '09:00',
  no_task_time_2       time NOT NULL DEFAULT '12:00',
  end_of_day_time      time NOT NULL DEFAULT '22:00',
  quiet_start          time,
  quiet_end            time,
  sound_enabled        boolean NOT NULL DEFAULT true,
  vibration_enabled    boolean NOT NULL DEFAULT true,
  updated_at           timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sync_changes (
  change_id    bigserial PRIMARY KEY,
  owner_id     uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  resource_type text NOT NULL CHECK (resource_type IN ('TASK', 'PROGRESS', 'LIFECYCLE')),
  resource_id  uuid NOT NULL,
  task_id      uuid NOT NULL,
  operation    text NOT NULL CHECK (operation IN ('UPSERT', 'DELETE')),
  resource_version bigint NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sync_idempotency (
  owner_id       uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  idempotency_key uuid NOT NULL,
  request_hash   bytea NOT NULL,
  response_body  jsonb NOT NULL,
  created_at     timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (owner_id, idempotency_key)
);

CREATE TABLE sync_tombstones (
  owner_id    uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  task_id     uuid NOT NULL,
  deleted_at  timestamptz NOT NULL DEFAULT now(),
  delete_version bigint NOT NULL,
  PRIMARY KEY (owner_id, task_id)
);
```

Enforce ownership in service queries for every operation. PostgreSQL row-level security can be added as defense in depth; it must be enabled with policies and tested with the actual application database role, since table owners normally bypass policies unless configured otherwise. [PostgreSQL row security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)

### 5.2 Indexes and common query shapes

```sql
CREATE INDEX tasks_owner_status_start_idx
  ON tasks (owner_id, status, start_date);

CREATE INDEX tasks_owner_status_end_idx
  ON tasks (owner_id, status, planned_end_date);

CREATE INDEX progress_owner_task_time_idx
  ON progress_logs (owner_id, task_id, occurred_at DESC);

CREATE INDEX lifecycle_owner_task_time_idx
  ON task_lifecycle_events (owner_id, task_id, occurred_at DESC);

CREATE INDEX sync_changes_owner_cursor_idx
  ON sync_changes (owner_id, change_id);

CREATE INDEX reminder_jobs_candidate_idx
  ON user_devices (notifications_enabled, owner_id);
```

These are starting indexes, to be confirmed against query plans and production-like data. Multicolumn index order should follow actual query predicates; PostgreSQL documents that leading columns are especially important for B-tree multicolumn indexes. [PostgreSQL multicolumn indexes](https://www.postgresql.org/docs/current/indexes-multicolumn.html)

### 5.3 Local SQLite schema

M2 schema version 1 contains four tables. `local_profiles` owns each local profile; `local_tasks` references its profile; and `local_progress_entries` and `local_lifecycle_events` each reference both their profile and task. Deleting a profile or task cascades to its dependent records. Child tables carry `profile_id` as well as `task_id`, and a composite task/profile foreign key prevents a child row from being attached to a task from another profile.

Store task calendar dates as ISO `YYYY-MM-DD` text, effort as integer hundredths of an hour, and UTC event times as integer Unix timestamps through Drift's `DateTimeColumn`. Profile-scoped indexes support the Today/Later and per-task history queries. Turn SQLite foreign-key enforcement on whenever the database connection opens.

Sync outbox and cursor tables are deferred to M5, when sync behavior is implemented. They are not part of the M2 guest-only database schema.

```text
local_profiles(
  id TEXT PRIMARY KEY,
  profile_type TEXT NOT NULL,           -- GUEST/ACCOUNT
  created_at_utc INTEGER NOT NULL,
  updated_at_utc INTEGER NOT NULL
)

local_tasks(
  id TEXT PRIMARY KEY,
  profile_id TEXT NOT NULL REFERENCES local_profiles(id) ON DELETE CASCADE,
  topic TEXT NOT NULL,
  subtopic TEXT NULL,
  description TEXT NULL,
  start_date TEXT NOT NULL,             -- ISO YYYY-MM-DD
  planned_end_date TEXT NOT NULL,
  maximum_end_date TEXT NULL,
  effort_hundredths INTEGER NOT NULL,
  status TEXT NOT NULL,
  completed_at_utc INTEGER NULL,
  created_at_utc INTEGER NOT NULL,
  updated_at_utc INTEGER NOT NULL,
  UNIQUE(id, profile_id)
)

local_progress_entries(
  id TEXT PRIMARY KEY,
  profile_id TEXT NOT NULL REFERENCES local_profiles(id) ON DELETE CASCADE,
  task_id TEXT NOT NULL,
  method TEXT NOT NULL,
  percent_complete INTEGER NULL,
  completed_units INTEGER NULL,
  total_units INTEGER NULL,
  note TEXT NULL,
  occurred_at_utc INTEGER NOT NULL,
  created_at_utc INTEGER NOT NULL,
  updated_at_utc INTEGER NOT NULL,
  FOREIGN KEY(task_id, profile_id) REFERENCES local_tasks(id, profile_id) ON DELETE CASCADE
)

local_lifecycle_events(
  id TEXT PRIMARY KEY,
  profile_id TEXT NOT NULL REFERENCES local_profiles(id) ON DELETE CASCADE,
  task_id TEXT NOT NULL,
  event_type TEXT NOT NULL,              -- COMPLETED/REOPENED
  occurred_at_utc INTEGER NOT NULL,
  FOREIGN KEY(task_id, profile_id) REFERENCES local_tasks(id, profile_id) ON DELETE CASCADE
)

Indexes:
  local_tasks(profile_id, start_date, status)
  local_progress_entries(profile_id, task_id, occurred_at_utc)
  local_lifecycle_events(profile_id, task_id, occurred_at_utc)
)
```

Use a SQLite transaction for each task mutation and its associated progress or lifecycle record when they must be atomic. Use database migrations with a monotonically increasing schema version. Keep guest and account records partitioned by `profile_id`; switching profiles must never query across profiles.

## 6. API contracts

All authenticated endpoints use HTTPS and an internal account session. UUIDs are opaque. API version is `/v1`. Requests carry `X-Request-ID`; writes carry `Idempotency-Key` and `If-Match`/base version where applicable.

### 6.1 Authentication

`POST /v1/auth/google/session`

Request:

```json
{ "googleIdToken": "<signed-google-id-token>" }
```

Response:

```json
{
  "accessToken": "<short-lived-app-access-token>",
  "refreshToken": "<rotating-refresh-token>",
  "expiresInSeconds": 900,
  "user": { "id": "uuid", "email": "user@example.com" }
}
```

`POST /v1/auth/apple/session` accepts `{ "appleIdentityToken": "<signed-apple-identity-token>" }` and returns the same application-session response. For both providers, the server verifies token signature, audience, issuer, expiry, nonce where applicable, and subject, then maps the `(provider, sub)` pair to an internal user ID. Never accept an email or user ID sent by the client as proof of identity. Do not automatically merge accounts because their email addresses match; linking a second provider requires an authenticated existing session and explicit user action. Google recommends sending its ID token over HTTPS and verifying it server-side. [Google backend authentication](https://developers.google.com/identity/sign-in/ios/backend-auth), [Apple authentication](https://developer.apple.com/documentation/signinwithapple/authenticating-users-with-sign-in-with-apple)

### 6.2 Task endpoints

| Method / path | Behavior |
|---|---|
| `GET /v1/tasks?view=current&date=YYYY-MM-DD&cursor=...` | Returns paginated tasks for the requested view/date; date must be today in IST for reminder-sensitive views. |
| `POST /v1/tasks` | Creates task using client-generated UUID. Requires idempotency key. Returns version 1 and server field versions. |
| `GET /v1/tasks/{taskId}` | Returns task and optionally recent progress/lifecycle events. |
| `PATCH /v1/tasks/{taskId}` | Applies only supplied fields if `baseRowVersion` and relevant `baseFieldVersions` match. Returns 409 conflict on same-field divergent edits. |
| `DELETE /v1/tasks/{taskId}` | Hard-deletes task and related logs/events transactionally; returns a deletion cursor/tombstone token. |
| `POST /v1/tasks/{taskId}/complete` | Completes open task and appends lifecycle event; idempotent if already complete. |
| `POST /v1/tasks/{taskId}/reopen` | Reopens completed task and appends lifecycle event; idempotent if already open only if caller requests current state. |
| `GET /v1/tasks/{taskId}/progress?cursor=...` | Returns paginated logs. |
| `POST /v1/tasks/{taskId}/progress` | Creates one progress log using exactly one method. |
| `PATCH /v1/progress/{logId}` | Edits a log if owned by authenticated user and task still exists. |
| `DELETE /v1/progress/{logId}` | Deletes a log; recomputes whether today's reminder condition is now true. |

### 6.3 Conflict request and response

Example task update:

```json
{
  "baseRowVersion": 12,
  "baseFieldVersions": {
    "plannedEndDate": 7,
    "effortHours": 4
  },
  "changes": {
    "plannedEndDate": "2026-10-20",
    "effortHours": "3.50"
  }
}
```

If only `plannedEndDate` changed on the server since version 7, return HTTP 409:

```json
{
  "code": "FIELD_CONFLICT",
  "resourceId": "uuid",
  "conflicts": [
    {
      "field": "plannedEndDate",
      "baseValue": "2026-10-18",
      "serverValue": "2026-10-19",
      "clientValue": "2026-10-20",
      "serverFieldVersion": 9
    }
  ],
  "currentResource": { "...": "..." }
}
```

If `effortHours` has not changed, the server can merge that field while reporting the date conflict. The client presents the conflicting values; user choice is submitted as a new mutation with the latest base version.

### 6.4 Sync endpoints

`POST /v1/sync/mutations` accepts an ordered batch of local outbox records, up to 100 mutations:

```json
{
  "deviceId": "uuid",
  "mutations": [
    {
      "mutationId": "uuid",
      "resourceType": "TASK",
      "resourceId": "uuid",
      "operation": "PATCH",
      "baseRowVersion": 12,
      "baseFieldVersions": { "topic": 1 },
      "changes": { "topic": "Complete Graph playlist" }
    }
  ]
}
```

Response returns one result per mutation: `APPLIED`, `ALREADY_APPLIED`, `CONFLICT`, `REJECTED_VALIDATION`, or `RESOURCE_DELETED`, plus new versions/cursors. Idempotency key is the mutation ID; same key with a different request hash is rejected.

`GET /v1/sync/changes?deviceId={id}&after={cursor}&limit=...` returns ordered changes and a next cursor. An upsert includes current resource state; a delete includes only resource ID, type, and delete version. The server never returns another user's records, even if the client guesses a UUID.

### 6.5 Standard error envelope

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "plannedEndDate must be on or after startDate",
    "fieldErrors": { "plannedEndDate": "DATE_ORDER_INVALID" },
    "requestId": "uuid"
  }
}
```

Stable codes include `AUTH_REQUIRED`, `FORBIDDEN`, `NOT_FOUND`, `VALIDATION_ERROR`, `FIELD_CONFLICT`, `RESOURCE_DELETED`, `RATE_LIMITED`, `RETRYABLE_UNAVAILABLE`, and `IDEMPOTENCY_KEY_REUSED`.

## 7. Sync and conflict algorithms

### 7.1 Mutation application

```text
applyMutation(user, mutation):
  begin transaction
  if idempotency record exists:
    verify request hash; return stored response

  load resource FOR UPDATE and verify owner
  if deleted tombstone exists:
    return RESOURCE_DELETED

  validate request shape and allowed fields
  for each changed field:
    compare mutation.baseFieldVersion[field] with current.fieldVersion[field]
    if different and proposed value differs from current value:
      mark field conflict

  if conflicts exist:
    apply non-conflicting fields only if cross-field invariants remain valid
    otherwise return whole mutation conflict
  else:
    apply all changes

  validate merged task (date order, max date, effort, text)
  if invalid:
    rollback; return validation result

  increment row version
  set field version for each applied field to new row version
  append sync change
  store idempotent response
  commit
```

Each mutation is atomic and processed in batch order. The response reports an outcome for every mutation; one invalid/conflicting mutation does not roll back earlier accepted mutations. If an update includes related fields whose combined values violate a constraint (for example, moving planned end beyond maximum end), reject that mutation with `VALIDATION_ERROR` and leave the resource unchanged.

API list routes default to 50 rows and cap at 100. Enforce a 1 MiB maximum request body before JSON parsing; reject larger payloads with `413 PAYLOAD_TOO_LARGE`.

### 7.2 Conflict UX states

```text
SYNCED -> PENDING -> SYNCED
                  -> CONFLICT -> USER_RESOLVED -> PENDING -> SYNCED
                  -> RETRY_WAIT -> PENDING
                  -> DELETED_ON_SERVER
```

Conflict screen must identify the task and field, show server and local values, and offer retain-server/retain-this-device choices. For date fields, validate the final merged task before allowing save. Never show an unbounded spinner; a conflict remains visible until resolved or the user discards the local change.

### 7.3 Pull cursor and compaction

- Cursors are opaque and scoped to one account/device.
- Pull is ordered by monotonically increasing `change_id`.
- Client applies a page and saves the new cursor in the same local transaction.
- If a cursor is older than retained change history, return `CURSOR_EXPIRED`; client performs a paginated full snapshot and then resumes delta sync.
- Tombstones remain until all active devices have advanced past deletion or a bounded expiry is reached. Devices absent past expiry must full-resync before writing.

## 8. Notification evaluation

### 8.1 Predicates

For IST date `D` and user `U`:

```sql
-- Task counts as active/due today if open and its start date has arrived.
active_or_due(U, D) := EXISTS (
  SELECT 1 FROM tasks
  WHERE owner_id = U AND status = 'OPEN' AND start_date <= D
);

-- No-task reminder is eligible when the predicate above is false.
-- End-of-day is eligible if at least one open task started by D has no log on D.
end_of_day_eligible(U, D) := EXISTS (
  SELECT 1 FROM tasks t
  WHERE t.owner_id = U AND t.status = 'OPEN' AND t.start_date <= D
    AND NOT EXISTS (
      SELECT 1 FROM progress_logs p
      WHERE p.owner_id = U AND p.task_id = t.id
        AND (p.occurred_at AT TIME ZONE 'Asia/Kolkata')::date = D
    )
);
```

The 10 PM notification is sent once per user/date/device when at least one active incomplete task lacks a same-day log. One log suppresses the reminder for that task; it does not suppress a reminder for another active task with no log. This matches the per-task FRS rule.

### 8.2 Scheduling and idempotency

- A scheduler creates reminder jobs for the next service window at each user's configured times.
- The worker reevaluates task/progress state immediately before dispatch; queued jobs may become ineligible after a task/log change.
- Unique key: `(owner_id, device_id, reminder_type, local_date, configured_time)`.
- Task/progress writes enqueue a recomputation signal for that user/date; the worker can cancel or supersede not-yet-dispatched jobs.
- Push payload contains notification type, local date, and a count only. It does not contain task names or descriptions.
- Invalid push tokens are marked inactive after provider feedback. Provider outages use retries with backoff and expiry; expired reminders are dropped rather than delivered the next day.
- Guest local scheduling recomputes after task/progress mutation, app launch, and account transfer. Permission-denied state is shown in settings; task use remains available.

Quiet-hour rule: defer a reminder to the next permitted time on the same local date. If quiet hours end on the following date, suppress that reminder. Configure this in preferences logic, not in task domain rules.

## 9. Authentication, device, and account lifecycle

### 9.1 Provider sign-in

1. The user chooses guest mode, Google sign-in, or (on iOS) Sign in with Apple.
2. The native provider flow returns a signed identity token; client sends it over HTTPS to the matching session endpoint.
3. Backend verifies signature, audience, issuer, expiry, nonce where applicable, and subject using maintained provider libraries/JWKS.
4. Backend maps `(provider, subject)` to `external_identities` and an internal `app_users.id`, then issues a short-lived application access token plus rotating refresh token.
5. API authorization uses internal user ID from the verified application session; never accept `owner_id` from the request body.

Never merge identities based only on matching email addresses. Adding another provider to an existing account requires recent authentication and explicit confirmation. Verify every provider token on the server; do not trust client-provided user IDs or email addresses.

### 9.2 Guest mode and profile separation

- Guest profile has a local UUID and no cloud credentials.
- Each local row includes `profile_id`; repositories always query one active profile.
- Switching account/profile locks the previous profile view and clears UI state before loading the next.
- Guest transfer uploads idempotently; local records remain until successful server confirmation.
- If guest and cloud contain duplicate IDs, preserve one resource ID and use conflict resolution rather than silently dropping either version.

### 9.3 Account deletion

- Require authenticated confirmation and recent re-authentication.
- Mark account `DELETION_PENDING`, revoke refresh sessions, deactivate push tokens, and enqueue deletion job.
- Delete account data in bounded batches where necessary; delete sessions, external identities, tasks and their child rows, preferences, devices, sync metadata, and idempotency responses.
- Return accepted status and a request ID. Revoke sessions immediately and delete active primary data within 7 calendar days. Backups expire within 30 days. Maintain a minimal deletion ledger for 90 days and replay it after any backup restore so deleted accounts do not reappear. Disclose this retention window in-app and on the web deletion page.
- The operational deletion job must be idempotent and auditable without retaining task text or progress contents.
- Provide deletion initiation inside the app and through a public web page; Google Play listing metadata must point to that web request resource. Apple also requires in-app deletion for account-creating apps. [Google Play requirements](https://support.google.com/googleplay/android-developer/answer/13327111), [Apple requirements](https://developer.apple.com/help/app-review/guideline-reference/5-1-1-account-deletion/)
- The web deletion page authenticates the user with a linked Google or Apple provider before accepting a request, returns a request receipt, and does not reveal whether an email/account exists. The app and web page display the 7-day primary deletion and 30-day backup expiry windows.

## 10. Client notification and local database details

- Store notification preference and scheduled request IDs locally for each profile/device.
- Reconcile schedules after task create/update/delete, progress create/update/delete, completion/reopen, reminder preference changes, and day rollover.
- On Android, use normal scheduled notifications for reminders. An ongoing task-list notification is a separate platform-specific feature and only while a valid foreground operation justifies it; do not make the core list depend on it.
- On iOS, use standard local/push notifications and app badges where supported; do not promise a permanently visible notification.
- Store the local database in app-private storage encrypted with SQLite3MultipleCiphers using its default `sqleet` ChaCha20-Poly1305 cipher. Generate a cryptographically random database key and keep it in platform secure storage, separate from the database. Verify that the cipher build is active before opening user data. Exclude database/key material from OS cloud backup; signed-in data can be resynced and guest data remains intentionally device-local. Protect access and refresh tokens in platform secure storage. SQLite3MultipleCiphers is MIT-licensed and its notice must be included in app license notices.
- On sign-out, retain or clear account cache according to a user-visible policy; never surface it in guest mode. Recommended default: retain encrypted local cache for re-login on the same device, but lock access behind account identity and clear on account deletion.

## 11. Validation and invariants

Validate on both client and server; server is authoritative for account state.

- Topic is trimmed and non-empty.
- Start and planned end dates are present; end is on/after start.
- Maximum end date, if present, is on/after planned end date.
- Effort is a decimal hour value > 0 and <= 99,999.99, with at most two decimal places.
- Completed tasks have a completion timestamp; open tasks do not.
- Progress method matches exactly one valid value set.
- Progress log owner matches task owner.
- Every task, log, lifecycle event, device, and sync record is authorized by authenticated owner.
- Dates and local reminder date use `Asia/Kolkata`; event instants are stored as UTC timestamps.
- Deletion removes all task-linked progress and lifecycle history transactionally.

## 12. Failure and retry behavior

| Condition | Client behavior | Server behavior |
|---|---|---|
| No network | Save locally, show pending state, retry with backoff. | No operation. |
| 401 / expired session | Keep local outbox; refresh token or request sign-in again. | Reject request without revealing resource existence. |
| 403 / owner mismatch | Show access error; do not retry automatically. | Record security event without sensitive payload; return generic forbidden/not-found policy. |
| 409 field conflict | Preserve local edit, show conflict UI. | Return current versions/values; do not silently overwrite. |
| 422 invalid fields | Keep draft editable and show field-specific error. | Reject atomically; no partial write. |
| 429 rate limit | Retry after server `Retry-After`; retain outbox. | Apply per-user/device/API limits. |
| 5xx/network timeout | Retry idempotently; exponential backoff with jitter. | Mutation ID prevents duplicate application. |
| Push provider failure | No task-data change; retry transient errors, disable invalid tokens. | Track attempts, error class, expiry, and queue lag. |
| Account deletion pending | Block new writes, show deletion status. | Revoke sessions and continue idempotent deletion workflow. |

## 13. Selected implementation defaults and remaining planning inputs

The stack and defaults in this document are the implementation baseline. The following values are selected:

| Area | Selected default |
|---|---|
| Text limits | Topic 200, subtopic 200, description 5,000, progress note 2,000 characters. |
| Effort | Greater than zero through 99,999.99 hours, two decimal places. |
| API bounds | List page defaults to 50 rows and caps at 100; sync mutation batches cap at 100; request body cap is 1 MiB. |
| Authentication | Access token expires after 15 minutes. Rotating refresh token expires after 30 days of inactivity; server stores only a secure hash and revokes previous token on rotation. |
| Database key | Random per-install SQLite3MultipleCiphers key in platform secure storage; local database excluded from OS backup. |
| Quiet hours | Defer to a permitted time on the same local date, otherwise suppress. |
| Transient retries | Exponential backoff with jitter, capped at 5 minutes, up to 10 attempts or 24 hours of job age; drop expired reminder jobs. |
| Cloud SQL availability | Zonal for development; regional high availability for public production once launch SLO and budget are approved. |
| Account deletion | Sessions revoked immediately; active primary data removed within 7 calendar days; backups expire within 30 days; minimal deletion ledger retained 90 days and replayed after restore. |
| Data retention | Account task data remains until user deletion; guest data is device-local; operational logs 30 days; security/audit events 90 days; invalid or 90-day inactive push tokens are removed. |
| Privacy and analytics | No ads, cross-app tracking, or product analytics in MVP. Optional crash diagnostics are off until opt-in and must redact task text, tokens, and identifiers not needed to diagnose crashes. |
| Store submission | Maintain current Play Data safety disclosures and privacy-policy links; include in-app and web account deletion; re-check store policy and required SDKs before each submission. |

At scaffold, select latest stable compatible Flutter package releases (no prereleases), verify support for Android API 24/iOS 15 and required provider flows, and commit exact versions in `pubspec.lock`; update on a planned cadence. Remaining engineering inputs are measured DAU/peak load, availability/latency and RPO/RTO targets, sync history/inactive-device retention, and production cost budget. Privacy-policy text, retention disclosures, and final compliance with India's phased DPDP Act/Rules and app-store policies remain a pre-public-launch review gate; this design does not claim legal compliance. [MeitY DPDP Rules Gazette](https://www.meity.gov.in/static/uploads/2025/11/53450e6e5dc0bfa85ebd78686cadad39.pdf)

## 14. Source notes

- Drift recommends SQLite3MultipleCiphers for new encrypted databases; the `sqlite3` 3.x build hook enables its native cipher library. The separate `sqlcipher_flutter_libs` package is obsolete for this setup. [Drift encryption guide](https://drift.simonbinder.eu/platforms/encryption/), [package notice](https://pub.dev/packages/sqlcipher_flutter_libs).

- Flutter's architecture guidance supports UI/data separation and repository boundaries: [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations).
- Google recommends sending the ID token over HTTPS and verifying its integrity on the backend: [Google sign-in backend authentication](https://developers.google.com/identity/sign-in/ios/backend-auth).
- Apple documents verification of identity tokens issued by Sign in with Apple: [Apple authentication](https://developer.apple.com/documentation/signinwithapple/authenticating-users-with-sign-in-with-apple).
- PostgreSQL row-level security applies only when enabled and configured; table owners normally bypass it unless forced: [PostgreSQL row security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html).
- PostgreSQL multicolumn index usefulness depends on the leading columns and query predicates: [PostgreSQL multicolumn indexes](https://www.postgresql.org/docs/current/indexes-multicolumn.html).
- Cloud Tasks queues expose dispatch and retry controls, and quotas/schedule horizons must be included in capacity planning: [queue configuration](https://docs.cloud.google.com/tasks/docs/configuring-queues), [quotas](https://docs.cloud.google.com/tasks/docs/quotas).

## 15. Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 14 October 2026 | Initial implementation-level design based on reviewed HLD v0.1 and FRS v0.4. |
| 0.2 | 15 October 2026 | Selected stack and implementation defaults using the user's delegation; aligned domain limits, persistence, auth, retry, reminder, and operational choices. |
| 0.3 | 15 October 2026 | Switched backend implementation from NestJS/TypeScript to Java 25 LTS and Spring Boot at the user's direction. |
| 0.4 | 16 October 2026 | Set OS/package policy and privacy/retention defaults; added Apple identity support, account deletion web path, and store submission decisions. |
| 0.5 | 16 October 2026 | Confirmed UI effort thresholds as selected design rules for implementation. |
