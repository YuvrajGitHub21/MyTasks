# MyTasks

A cross-platform task planning app, designed for guest use first and account sync later.

## Project layout

- [`Documentation/`](Documentation/Implementation-Plan.md) — requirements, architecture, detailed design, UI preview, implementation plan, and [project working agreement](Documentation/Working-Agreement.md).
- [`frontend/`](frontend/README.md) — Flutter Android/iOS application.
- [`backend/`](backend/README.md) — Java 25 / Spring Boot API and worker.
- `infrastructure/` — to be added when development cloud resources are ready to be managed as code.

## Current status

The HLD and LLD technology direction is approved, and the current UI preview is approved as the visual baseline. M0 product/UX readiness is complete. M1 scaffolding is in progress: the Java backend compiles, Flutter analysis is clean, and an Android debug APK builds. Local PostgreSQL migration verification and iOS build verification on macOS remain before the M1 exit review. See [`Documentation/Implementation-Plan.md`](Documentation/Implementation-Plan.md).
