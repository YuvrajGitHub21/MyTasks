# M4 — Detailed Implementation Plan: Java Backend and Signed-in Accounts

**Project:** MyTasks mobile application
**Status:** Planned. No M4 domain implementation has started.
**Date:** 18 October 2026
**Owner:** Project owner and assistant. Use the project teaching approach and five-file implementation batches in [Working Agreement](Working-Agreement.md).
**Baseline:** [FRS](FRS.md), [HLD](HLD.md), [LLD](LLD.md), [Implementation Roadmap](Implementation-Roadmap.md), and the completed [M3 plan](M3-Implementation-Plan.md).

## 1. Goal

Build the first real Java/Spring Boot backend for MyTasks. A person can sign in with Google or, on iOS, Apple; the API verifies that identity, creates an internal account session, and stores tasks and their progress/completion history under that account. Every read and write is isolated to the authenticated account. The mobile app can use these cloud features when online while guest mode continues to use the encrypted local database.

M4 provides the online account foundation. Offline account edits, retryable synchronization, conflict resolution, and transfer of guest data are M5 work. Until M5, the signed-in experience must clearly report when cloud data cannot be reached; it must not imply that an offline edit was saved.

## 2. Current starting point

- The backend is a Java 25 / Spring Boot modular-monolith scaffold with separate API and worker entry points.
- Spring JDBC, PostgreSQL, Flyway, Jakarta validation, Actuator, and springdoc OpenAPI UI are already in the Maven build.
- The existing `V1` migration creates the `app` schema only. It does not create accounts, sessions, tasks, progress, or lifecycle tables.
- The API currently has request-ID and baseline error handling, but no account authentication or domain endpoints.
- The mobile app has guest profiles, encrypted local task data, progress, lifecycle history, and reminder preferences. The local guest store must remain isolated from cloud accounts until the owner chooses the M5 transfer flow.
- The roadmap assigns offline sync, guest transfer, and field-level conflict resolution to M5. M6 owns push delivery, account deletion operations, and public-release readiness.

## 3. Scope boundaries

### Included in M4

- Onion-style backend modules: domain rules and application use cases inside; HTTP and PostgreSQL adapters outside.
- Versioned PostgreSQL migrations and owner-scoped JDBC repositories.
- Google and Apple identity-token verification on the server.
- Short-lived application access tokens, rotating refresh tokens, logout, and revocation.
- Owner-scoped task CRUD, progress CRUD, completion/reopen history, account reminder preferences, and minimal device/session registration.
- Stable API errors, request correlation, validation, OpenAPI descriptions, pagination, idempotency, optimistic concurrency, and security-conscious logs.
- Flutter sign-in/session handling and an online account-data path. Guest mode remains local and unchanged.
- Local development and deployment configuration for the planned Cloud Run + Cloud SQL architecture, subject to a separately authorized cloud-cost/security review before creating paid resources.

### Explicitly deferred

- Offline account writes, durable sync outbox, delta sync, field-level merge, conflict UI, and guest-to-account transfer: **M5**.
- FCM/APNs token delivery, scheduled reminder workers, push fan-out, deletion worker, public deletion website, privacy/store submission, and pilot operations: **M6**.
- Automatic provider-account linking by matching email: never allowed.
- Uploading guest tasks merely because the user signs in: never allowed. Transfer requires a distinct, explicit M5 action.

## 4. Selected implementation decisions

| Topic | M4 decision | Why |
|---|---|---|
| Architecture | Keep a modular monolith with Onion dependency direction: HTTP adapter → application use case → domain/ports; PostgreSQL adapters implement ports. | One deployable is easier to operate now; the boundaries keep business rules testable and storage/HTTP replaceable. |
| Database access | Use Spring JDBC / `NamedParameterJdbcTemplate`, explicit SQL, and Flyway. | The project already chose JDBC; explicit SQL makes ownership predicates, transactions, and indexes visible for learning and review. |
| Provider tokens | Verify Google/Apple ID tokens on the backend using maintained provider/JWT libraries and provider key discovery. Never trust a client-supplied email or user ID. | Identity proof must be checked by the service that protects the data. Avoid implementing cryptographic signature verification by hand. |
| Access token | Issue a signed, short-lived application token for API calls (15-minute target from the LLD). Validate issuer, audience, expiry, signature, and account state. | Short lifetime limits exposure if a token leaks; the API can authorize requests without a database lookup on every call if the token key and account state policy allow it. |
| Refresh token | Generate a high-entropy opaque token; store only a cryptographic hash; rotate on each refresh and revoke the token family on detected reuse. | Long-lived credentials should be revocable and never stored in plaintext in the database. |
| Account identity | Use internal UUID account IDs. Link provider identities by verified `(provider, subject)` with a unique constraint. Email is profile data, not an account key. | Email can be absent, changed, or shared; provider subject is the stable identity key. |
| Authorization | Derive `owner_id` only from the verified application session. Every repository query and mutation includes the authenticated owner. Return a non-disclosing not-found response for another account's resource. | Controller checks alone are easy to forget; ownership belongs in the application/repository query boundary too. |
| Mutation safety | Require idempotency keys for create/retry-sensitive writes and a row version for update concurrency. Add field-level conflict merging in M5. | M4 prevents duplicate requests and lost whole-row updates; M5 adds offline-specific field merge. |
| Mobile transitional behavior | Signed-in cloud task operations require connectivity until M5. Show an explicit offline state and retain guest data in its guest profile. | Avoid pretending account edits were saved offline before an outbox/sync engine exists. |
| API docs | Continue the existing springdoc Swagger UI. Document Bearer auth and use local development tokens only; never expose a production token in a shared Swagger session. | The package already exists, and the UI will help the owner learn and manually inspect endpoint contracts. |
| Cloud | Keep local development on Docker Compose PostgreSQL. Prepare Cloud Run/Cloud SQL configuration, but require a separate cost/security approval before provisioning or deploying paid resources. | Cloud infrastructure can incur cost and needs explicit environment, secrets, network, backup, and budget review. |

At scaffold time, verify compatible stable package releases and pin them in `pom.xml`; do not upgrade unrelated dependencies as part of feature work.

## 5. Backend module shape

Keep modules inside the existing `com.mytasks` root and follow the same direction in each feature:

```text
com.mytasks
├── bootstrap/                         # API and worker composition roots
├── identity/
│   ├── domain/                         # account, provider identity, session rules
│   ├── application/                    # sign-in, refresh, revoke use cases
│   └── adapters/
│       ├── in/http/                     # auth controllers and request/response DTOs
│       └── out/postgres/                # account/session repositories
├── tasks/                              # task, progress, lifecycle, preference modules
│   ├── domain/
│   ├── application/
│   └── adapters/{in/http,out/postgres}/
├── shared/
│   ├── domain/                         # shared IDs, clock, page types
│   └── adapters/in/http/                # request ID, error mapping, security filters
└── worker/                             # separate process entry point; no M6 job yet
```

HTTP controllers translate transport DTOs into use-case inputs and map outputs to HTTP. They do not contain SQL or account business rules. Domain/application code depends on repository and provider-verification interfaces, not Spring MVC or JDBC classes. Spring configuration wires interfaces to concrete adapters.

## 6. Data model and migration plan

Keep `V1` immutable. Add reviewed, forward-only migrations; never edit a migration after it has been applied to a shared database.

| Table | Purpose and important rules |
|---|---|
| `app.app_users` | Internal UUID, account state, timestamps. A deleted/pending account cannot create new sessions or mutate data. |
| `app.external_identities` | Provider + provider subject unique pair, internal owner, verified email as optional profile data. No unique constraint on email. |
| `app.app_sessions` | Session/device IDs, refresh-token hash, expiry, last use, revocation time, rotation-family metadata. Never store raw refresh tokens. |
| `app.tasks` | Owner, topic/subtopic/description, date-only start/end/max dates, effort, status, completion timestamp, row version, timestamps. Foreign key to owner and indexes for owner/date/status. |
| `app.progress_entries` | Owner and task foreign keys, exactly one progress method, method-specific values, client event time, server receipt time, created/updated timestamps. Enforce task-owner consistency. |
| `app.lifecycle_events` | Owner/task, completed/reopened kind, occurred/recorded timestamps; append history as specified by the LLD. |
| `app.reminder_preferences` | Per-account reminder times, enabled state, quiet hours, and explicit standard-notification fallback choice. Validate same rules as client. |
| `app.devices` | Stable app device ID, owner, platform, app version/time-zone metadata, last seen, revocation. Do not store FCM/APNs tokens until M6. |
| `app.idempotency_records` | Owner, key, request hash, response status/body reference, expiry. Reusing a key with a different request is rejected. |

Migration review must cover CHECK constraints, foreign keys, decimal precision, date-only SQL `DATE` fields, indexes, and transaction boundaries. Child progress/lifecycle rows must not be attachable to another user's task. Account-scoped list indexes begin with `owner_id`; add measured indexes later from query plans rather than indexing every column.

## 7. API contract for M4

All account APIs use `/v1`, HTTPS outside local development, an application Bearer access token, `X-Request-ID`, bounded request bodies, and stable JSON errors from the existing error baseline.

### Identity and sessions

| Endpoint | Purpose |
|---|---|
| `POST /v1/auth/google/session` | Verify Google ID token and create/resume an internal account session. |
| `POST /v1/auth/apple/session` | Verify Apple identity token and create/resume an internal account session. |
| `POST /v1/auth/refresh` | Rotate a valid refresh token and return a new access/refresh pair. |
| `POST /v1/auth/logout` | Revoke the current device session. |
| `POST /v1/auth/logout-all` | Revoke all sessions for the authenticated account. |
| `GET /v1/me` | Return safe account/profile and session information. |

Provider validation includes signature/key rotation, issuer, audience, expiry, subject, and nonce when the platform flow supplies one. The service must reject missing/invalid claims and never create an account from an unverified client email.

### Cloud task data

| Endpoint | Purpose |
|---|---|
| `GET /v1/tasks?view=current&date=YYYY-MM-DD&cursor=...` | Owner-scoped, bounded page of tasks for a date/view. Date-only values remain dates; server uses the agreed Asia/Kolkata calendar rules. |
| `POST /v1/tasks` | Create a client-UUID task; idempotent retry returns the original result. |
| `GET /v1/tasks/{taskId}` | Read only if owned by the authenticated account. |
| `PATCH /v1/tasks/{taskId}` | Validate partial changes; require row version; return conflict if stale. |
| `DELETE /v1/tasks/{taskId}` | Transactionally delete task and user-visible child history; M5 adds sync tombstone behavior. |
| `POST /v1/tasks/{taskId}/complete` / `reopen` | Apply valid state transition and append lifecycle event in one transaction. |
| `GET/POST /v1/tasks/{taskId}/progress` | Read a bounded page or add a progress entry with exactly one method. |
| `PATCH/DELETE /v1/progress/{entryId}` | Edit/delete only an entry owned by the account and task. |
| `GET/PUT /v1/reminder-preferences` | Read or replace account preferences; validate times and quiet-hour fields server-side. |
| `POST/DELETE /v1/devices/{deviceId}` | Register/retire a session device without push tokens; FCM/APNs registration is M6. |

Do not implement `/v1/sync/*`, server cursors/tombstones, cross-device field merge, or guest transfer in M4. Keep the API model aligned with the LLD; any proposed contract change should update the LLD and API documentation together before implementation.

## 8. Phase-by-phase implementation

Each phase is reviewed in small approved batches of at most five files. The file list is proposed immediately before each batch so the owner can follow and approve it.

### M4-A — Local backend foundation and API contract

- Confirm the current Maven/JDK/toolchain and local PostgreSQL compose service.
- Organize the Java package boundary without changing existing API error/request-ID behavior.
- Configure Spring Security entry points, JSON validation/error mapping, actuator health/readiness, and OpenAPI Bearer auth description.
- Keep local-only secrets in environment variables; retain `.env.example` with safe placeholders.
- Deliverable: API starts locally, Swagger UI describes the auth/task contract, and existing health/error behavior stays stable.

### M4-B — Schema, domain rules, and JDBC ports

- Add Flyway `V2` tables and constraints for accounts, identities, sessions, tasks, progress, lifecycle, preferences, devices, and idempotency records (split across migrations if review size warrants it).
- Add domain records/value objects and validation rules that match `TaskRules`/`ReminderRules` and the LLD.
- Add application-owned repository interfaces and transactional use-case boundaries.
- Implement JDBC adapters with explicit owner predicates and row mapping.
- Deliverable: migration works on both a clean database and the existing V1 schema; no HTTP endpoint yet relies on unreviewed SQL.

### M4-C — Provider verification and account sessions

- Add Google and Apple verifier adapters using maintained libraries; use provider JWKS/key rotation safely.
- Implement account lookup/create, session issuance, refresh rotation, logout, logout-all, and `GET /me` use cases.
- Sign 15-minute app access tokens with a managed/rotatable key configuration; validate issuer/audience/expiry on every protected request.
- Hash opaque refresh tokens before persistence, rotate them after use, detect reuse, and revoke the affected family.
- Add rate limits at a suitable edge or application boundary for auth/refresh endpoints; return generic auth failures that do not disclose account existence.
- Deliverable: invalid, expired, wrong-audience, revoked, and replayed tokens fail; valid Google/Apple identities map to one internal account without email-based auto-linking.

### M4-D — Authenticated task, progress, and lifecycle APIs

- Add REST adapters and DTOs with Jakarta validation; controllers remain thin.
- Implement owner-scoped list/create/read/update/delete and progress/lifecycle operations.
- Enforce row-version optimistic concurrency, idempotency keys, bounded pagination/body size, and transactional task-history writes.
- Ensure a valid ID for another owner returns the documented non-disclosing result and cannot modify anything.
- Add reminder preference/device endpoints without push delivery.
- Deliverable: a signed-in account can create and manage cloud records through Swagger/cURL and cannot access another account's data.

### M4-E — Flutter authentication and online account mode

- Add provider sign-in choices: Google on Android/iOS, Apple on iOS, and continue as guest.
- Add a platform secure token store, refresh-on-expiry coordinator, logout behavior, and Riverpod session state.
- Implement the Dio auth/API adapters and remote task repository behind existing repository contracts, preserving the current guest Drift repositories.
- Make account mode clearly online-only until M5; show an actionable offline state and never report an unacknowledged write as saved.
- Do not copy guest rows into cloud on sign-in. Display a separate, explicit “transfer guest data” entry only when the M5 transfer feature exists; until then, explain that guest tasks stay in the guest profile.
- Deliverable: user can sign in/out, see account mode and cloud data online, retain guest data separately, and recover a session without exposing tokens in logs or SQLite.

### M4-F — Operational baseline and deployment preparation

- Add structured log fields (request ID, route template, status, duration) while redacting provider tokens, app tokens, refresh tokens, topics, descriptions, and progress notes.
- Add health/readiness and database connectivity indicators without exposing SQL/secret details; add useful metrics for request/error/DB pool behavior.
- Review connection-pool sizing and transaction timeout for Cloud Run concurrency; keep the service stateless and all session state in PostgreSQL.
- Prepare Cloud Run API/worker and Cloud SQL configuration for `asia-south1`, secret references, backups, and cost controls. Actual provisioning/deployment is a separate owner-approved operation.
- Deliverable: local acceptance and a reviewed deployment package; no production claim until provider configuration, privacy, secrets, backup/restore, and cost review pass.

## 9. Verification and security review

Plan for the following checks. Automated test code or test runs are a separate owner-approved batch under the working agreement; do not run them without that approval.

| Area | Scenarios | Required result |
|---|---|---|
| Migration | Empty DB to V2; existing V1 to V2; restart after migration | Both paths succeed; migrations are repeatable through Flyway and prior data is preserved. |
| Identity | Valid/invalid Google and Apple tokens; wrong issuer/audience; expiry; invalid signature; key rotation; missing subject; nonce mismatch | Only verified provider subjects create sessions; failures reveal no account enumeration detail. |
| Sessions | Access expiry; refresh rotation; refresh reuse; logout; logout-all; account disabled | Expired/revoked/reused tokens are rejected; rotation and revocation are atomic. |
| Tenant isolation | User A reads/patches/deletes User B task/progress/preference/device IDs; tamper with owner ID in request | No cross-account data or mutation; owner always comes from the verified session. |
| Task rules | Date bounds, positive effort, status transitions, progress method combinations, 100% vs completion | Backend rejects invalid data consistently with the local domain rules. |
| Retry/concurrency | Repeat same idempotency key/body; same key/different body; retry after timeout; stale row version | Safe replay returns the original outcome; conflicting key/body or stale update is rejected clearly. |
| Privacy | Request/error logs, health endpoints, OpenAPI examples, token failures | Tokens and user-entered task content are absent from logs and public health details. |
| API docs | Swagger Bearer auth, request/response examples, validation errors, pagination | Local developer can exercise the API; production docs do not accept/log a real user's token. |
| Mobile mode | Guest use offline; account mode online/offline; sign-out/sign-in; separate guest/account tasks | Guest remains usable; account offline state is explicit; no implicit guest upload or cross-profile display. |
| Operational | DB unavailable, pool exhausted, API startup, worker startup, shutdown | Readiness goes unhealthy on DB dependency failure; API stops accepting work cleanly; worker remains a separate process. |

## 10. Learning objectives

M4 is intended to teach these concepts in the code, not just name them:

- **Onion architecture:** business use cases depend on interfaces; Spring wiring connects them to HTTP/JDBC adapters.
- **Authentication vs authorization:** provider token proves identity; app session establishes MyTasks credentials; owner-scoped checks decide which rows the user may access.
- **JWT vs refresh token:** short-lived signed access proof vs random, stored-hash, rotating session credential.
- **Database transactions and constraints:** keep task/history changes atomic and reject invalid relationships even if application validation is missed.
- **Flyway migrations:** evolve deployed schemas forward rather than editing old SQL or recreating the database.
- **Idempotency and concurrency:** retries do not duplicate creates; row versions detect stale writes.
- **Stateless service scaling:** any API instance can handle a request because durable state is in PostgreSQL, not process memory.
- **Observability:** correlate an API request with logs using request IDs without recording private content.

## 11. Local developer commands

From `backend/` in PowerShell. Set `JAVA_HOME` only in the current terminal if needed; the command uses the project JDK and does not change the machine-wide Java setting.

```powershell
$env:JAVA_HOME = 'C:\Path\To\jdk-25'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
& "$env:JAVA_HOME\bin\java.exe" -version

# Start the local PostgreSQL container; data stays in its named Docker volume.
docker compose up -d database

# Start the Spring Boot API using the Maven Wrapper.
.\mvnw.cmd spring-boot:run
```

Use `http://localhost:8080/swagger-ui.html` for the interactive local API documentation, `http://localhost:8080/v3/api-docs` for its OpenAPI JSON, and `http://localhost:8080/actuator/health` for the local health endpoint. `docker compose down` stops the database and retains its volume; `docker compose down -v` deletes that volume and is not a routine cleanup command.

The normal verification command will be documented once the approved test/build workflow is implemented. Do not run an integration suite against a personal or production database.

## 12. M4 exit criteria

- Google sign-in on Android/iOS and Apple sign-in on iOS create verified, internal account sessions.
- Refresh rotation, logout, revocation, expiry, and replay detection work.
- Signed-in users can create/read/update/delete their own tasks, progress, history, preferences, and device records online.
- Cross-account access and owner-ID tampering fail without exposing another user's data.
- Domain constraints, authorization predicates, migrations, pagination, idempotency, and row-version concurrency are enforced.
- Guest-local data remains encrypted and separate; sign-in never implicitly uploads it.
- Account mode reports offline limitations honestly until M5 provides outbox/sync.
- Swagger UI and health/readiness are useful locally without exposing secrets; logs omit tokens and task contents.
- Cloud deployment configuration is reviewable; paid provisioning is performed only after explicit budget/security approval.
- Test evidence and known limitations are recorded. M4 is not a public-release security/compliance claim.

## 13. Risks and pre-implementation checks

- Verify the existing Apple/Google provider setup, OAuth client IDs, bundle ID/application ID, signing configuration, and callback/deep-link behavior before UI implementation. Do not paste client secrets or production credentials into chat or source.
- Confirm Spring Boot 4.1.1, springdoc 3.1.1, PostgreSQL, and Java 25 compatibility against official release documentation when the implementation batch begins; update exact dependencies only with a reviewed reason.
- Keep auth cryptography delegated to established libraries and test key rotation/issuer/audience values before connecting a mobile client.
- The user's Xiaomi device is Android 12; it cannot verify Android 13+ notification permission behavior and is not a substitute for iOS provider sign-in verification.
- Do not configure Google/Apple credentials or Cloud resources until the owner supplies the required project identifiers and explicitly approves any external console/cloud changes.

## 14. Change history

| Version | Date | Change |
|---|---|---|
| 0.1 | 18 October 2026 | Initial phase-by-phase M4 plan based on the M4 roadmap, FRS, HLD, LLD, and current backend scaffold. |
