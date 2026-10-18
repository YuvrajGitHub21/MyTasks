# Repository Guidelines

## Project Structure

- `frontend/` contains the Flutter app. Dart code lives in `lib/`, grouped into `app/`, `application/`, `domain/`, `data/`, and `features/`; platform projects are under `android/` and `ios/`.
- `backend/` contains the Java 25 / Spring Boot API and worker. Main code and Flyway migrations are in `src/main/java/` and `src/main/resources/db/migration/`.
- `Documentation/` holds the FRS, HLD, LLD, roadmap, and milestone plans. Update the relevant plan when implementation scope or decisions change.

## Architecture and Code Style

Follow Onion Architecture: dependencies point inward. Presentation calls application use cases; use cases depend on domain rules and repository/service contracts; outer data and platform adapters implement those contracts. Keep widgets/controllers free of SQL and business rules.

Use Dart `lower_snake_case.dart`, `UpperCamelCase` types, and `lowerCamelCase` members. Format with `dart format`; honor `frontend/analysis_options.yaml` and Flutter lints. Use Java packages under `com.mytasks`, `UpperCamelCase` classes, and `lowerCamelCase` methods/fields. Keep SQL migrations sequentially named, such as `V2__add_task_tables.sql`.

## Build, Run, and Verify

From `frontend/`, run `flutter pub get`, `flutter analyze`, `flutter test`, or `flutter run`. iOS builds require macOS and Xcode. Drift schema changes require regenerating generated code with `dart run build_runner build --delete-conflicting-outputs`.

From `backend/`, use Java 25 and run `docker compose up -d database`, then `./mvnw spring-boot:run` (Windows: `./mvnw.cmd spring-boot:run`). Run backend checks with `./mvnw test` (Windows: `./mvnw.cmd test`). Local API docs are at `/swagger-ui.html`; health is at `/actuator/health`. Avoid `docker compose down -v` unless you intend to delete the local database volume.

## Tests and Changes

Add Dart tests under `frontend/test/` with names ending `_test.dart`; add Java tests under `backend/src/test/java/` with `Test`-suffixed class names. Cover domain rules and use-case behavior, and run relevant checks for changed code. Do not commit generated build output or local secrets; keep required runtime assets and dependency lockfiles.

## Commits and Pull Requests

Use short, scoped Conventional Commit messages, for example `feat(m3): add Android alarm routing` or `fix(frontend): handle empty task list`. PRs should explain user impact, architecture or migration changes, verification performed, and include screenshots for UI changes. Never run Git commands unless the repository owner explicitly asks.

## Contributor Workflow

This is also a learning project: explain unfamiliar concepts and important commands plainly. Before edits, state the intended scope. Keep changes reviewable in small batches by default, but follow any broader scope the owner explicitly approves. After implementation, summarize each changed file and verification results. Do not add or run automated tests unless the owner asks.
