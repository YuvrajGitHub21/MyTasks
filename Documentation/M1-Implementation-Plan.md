# M1 — Detailed Implementation Plan

**Purpose:** Finish and understand the project foundation before building task features.  
**Status:** In progress. The code is pushed; local database startup, API contract baseline, clean-setup walkthrough, and CI remain.  
**Owner:** Project owner and assistant, working in reviewable batches of at most five edited files.

## 1. What M1 delivers

M1 makes the repository reproducible and gives us a working local development environment. At its end, a developer should be able to check out the project, build the Android app and Java backend, start the local PostgreSQL database, see Flyway apply the initial migration, and understand how the API reports health and errors.

M1 does not implement task creation, account sign-in, cloud hosting, or production infrastructure. Those belong to later phases. The first product feature slice is M2.

## 2. Current completion snapshot

| Area | State | Evidence or remaining work |
|---|---|---|
| Repository layout and ignore rules | Complete | `Documentation/`, `frontend/`, and `backend/` are present; build outputs and local secrets are ignored. |
| Java / Spring Boot scaffold | Complete | Java 25, Maven Wrapper 3.10.0, Spring Boot 4.1.1 API and worker entry points; compile-only build succeeded. |
| Flutter scaffold | Complete | Flutter 3.47.7 / Dart 3.13.5, Android and iOS project files, committed package lockfile. |
| Flutter static analysis | Complete | `flutter analyze` reported no issues. |
| Android debug build | Complete | `flutter build apk --debug` produced an APK. The first build installed Android NDK 28.2.13676358. |
| Docker Desktop engine | Complete | Read-only client/server version check succeeded; both report Docker 29.4.1. |
| Compose file validation | Complete | `docker compose config --quiet` succeeded. |
| PostgreSQL container and Flyway startup | Complete | Docker Desktop 29.4.1; PostgreSQL 18.6 reported healthy; API health returned `UP`; Flyway history records V1 as successful and schema `app` exists. |
| API contract/error baseline | Foundation complete | Springdoc 3.1.1 exposes `/v3/api-docs` with MyTasks title and `v1` metadata; `X-Request-ID` is returned. Error envelope and handlers compile. The spec has no business paths yet, and error handling awaits a business endpoint for runtime verification. |
| Clean setup instructions and CI | Pending | Walk through documented commands; add CI now that the GitHub repository exists. |
| iOS native build | Mac/Xcode required | The project files exist. Build on a Mac or a macOS CI runner when available. |

## 3. Work sequence

### M1-A — Start and understand local PostgreSQL

**Status: Complete — 16 October 2026.** The Docker image was pulled, the database became healthy, the API started, and Flyway applied V1 successfully. The API and container were stopped after verification. The named volume remains, preserving the local database and migration history.

**Goal:** Run the same database service locally that the backend expects, without involving a cloud database.

**What we will do:**

1. From `backend/`, start only the database service with `docker compose up -d database`.
2. Check `docker compose ps` until the database reports healthy; inspect `docker compose logs database` if it does not.
3. Start the API with `mvnw.cmd spring-boot:run` on Windows. On startup, Spring Boot connects to PostgreSQL and Flyway reads versioned files under `src/main/resources/db/migration`.
4. Check `http://localhost:8080/actuator/health` and confirm the `app` schema exists in PostgreSQL.
5. Stop the API and database cleanly after recording the result.

**What you will learn:** A Docker *image* is the packaged template for PostgreSQL; a *container* is the running instance; a *volume* keeps database files when the container stops or is recreated. Flyway is the migration runner: it applies each numbered SQL change once and records which version ran.

**Data note:** The Compose file uses a named volume so local database data survives normal container restarts. `docker compose down -v` deletes that volume and its local database contents; do not use it unless you intentionally want to reset the database.

**Expected result:** PostgreSQL is healthy, the API starts, the health endpoint responds, and the migration-created `app` schema is visible. This is an environment verification, not an automated test suite.

### M1-B — Make backend API behavior reviewable

**Status: Foundation complete — 16 October 2026.** Springdoc 3.1.1 is configured with the API title, version, and `/v1` server base. `GET /v3/api-docs` returned HTTP 200 with the expected metadata, and the response included `X-Request-ID`. The shared validation/unexpected-error response classes compile. The spec currently has an empty `paths` object because no business endpoints exist yet; runtime error behavior will be verified when such an endpoint is added.

**Goal:** Establish predictable API documentation and errors before task endpoints are implemented.

**What we will do:**

1. Use the contract already recorded in `LLD.md`: API path version `/v1`, request identifiers, and the standard error envelope with a stable code and optional field errors.
2. Add the smallest useful OpenAPI baseline or generated API documentation, consistent with the LLD and Spring Boot dependencies.
3. Add a shared backend error response handler for failures that can occur in the scaffold, without implementing task CRUD or authentication endpoints.
4. Keep Actuator health routes separate from business API routes.

**What you will learn:** An API contract is the agreement about request and response shapes. Versioning lets clients and servers evolve without silently changing the meaning of existing routes. A shared exception handler keeps each controller from inventing a different error format.

**Expected result:** A developer can inspect the API shape and understand a stable error response before feature APIs arrive in later milestones.

### M1-C — Walk through repeatable local builds

**Goal:** Make the setup instructions usable by another developer, not just by the machine that generated the scaffold.

**What we will do:**

1. Follow the documented prerequisites and commands from the repository root on this Windows development machine.
2. Confirm Flutter package resolution uses the committed `pubspec.lock`; run static analysis and an Android debug build.
3. Confirm the backend compiles with the committed Maven Wrapper and Java 25.
4. Explain generated output: APKs, Gradle caches, Dart build folders, and Maven `target/` are recreated locally and ignored by Git. Source code, configuration templates, migrations, and app assets stay in the repository.
5. Adjust only documentation or configuration that is actually incorrect during the walkthrough.

**What you will learn:** A lockfile records the exact compatible package versions selected for this project. A wrapper gives the project a known Maven version without requiring a globally installed Maven. Static analysis catches common Dart issues before runtime; a debug build confirms the Android toolchain can package the app.

**Expected result:** The setup instructions work from a clean checkout using the documented toolchains. The debug APK is a local build artifact, not a source file to commit.

### M1-D — Add continuous integration

**Goal:** Have GitHub automatically repeat the core checks when code changes.

**What we will do:**

1. Add a small GitHub Actions workflow for Flutter analysis, Android debug build, and backend compile.
2. Pin toolchain versions to the versions selected for M1.
3. Run the workflow on pull requests and pushes to the main development branch.
4. Defer iOS CI to a macOS runner decision; the current Windows machine cannot run Xcode.

**What you will learn:** CI is a clean, automated machine that performs the same quality checks after a change. It reduces “works on my machine” problems. An iOS job needs a macOS runner because Xcode provides Apple's compiler, simulator, and signing tools.

**Expected result:** GitHub can verify Android and Java scaffolds without relying on files or SDK caches from this workstation.

### M1-E — Review and close M1

Review the checklist and confirm each item has evidence. Update the implementation plan and READMEs with the actual result. Keep unresolved platform-specific work explicit: iOS native verification remains open until a Mac/Xcode environment is available.

**M1 exit criteria:**

- Backend compiles and starts against local PostgreSQL.
- Flyway applies the baseline migration and the schema can be inspected.
- Health endpoint responds and the API contract/error baseline is documented.
- Flutter analysis and Android debug build succeed from documented commands.
- CI runs Flutter analysis, Android build, and backend compile.
- iOS project/toolchain limitation and the required Mac/Xcode follow-up are documented.
- No development secret or generated build output is included in source control.

## 4. Platform clarification: iOS and macOS

We can write and review shared Dart code on Windows. Flutter's supported iOS target setup uses Xcode on macOS to compile and run the iOS app. Therefore, a Mac is needed to build the iOS simulator/device app, use the iOS simulator, and produce a signed release package. The app's shared Flutter source does not need to be rewritten on a Mac. We can verify iOS later on a Mac or suitable macOS CI runner. [Flutter iOS setup](https://docs.flutter.dev/platform-integration/ios/setup)

## 5. How we will work through M1

- Before each substantial step, I will explain the commands, what they change, and the expected outcome.
- I will edit no more than five files in one batch. If the next step needs more, I will show the completed batch and ask before editing the next files.
- I will explain new Java, Flutter, database, and CI concepts in plain language; familiarity with them will not be assumed.
- I will not run Git commands unless you explicitly request them. A local commit and a push are separate actions.
- I will not add or run automated tests unless you ask. M1 uses the planned compile, analysis, build, health, and migration checks.

## 6. Mini glossary

| Term | Plain-language meaning in this project |
|---|---|
| Scaffold | The starter files and wiring needed before real application features exist. |
| Migration | A numbered SQL change that updates a database in a repeatable order. |
| Health endpoint | A small HTTP route used to ask whether the service is running and ready. |
| Lockfile | A record of exact dependency versions so different machines resolve the same packages. |
| CI | An automated build/check run by GitHub when code changes. |
| Native iOS build | The app compiled by Apple's Xcode toolchain for simulator, device, or store distribution. |
