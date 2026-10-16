# Backend — Java / Spring Boot

This folder contains the Java 25 LTS Spring Boot modular monolith. The API and worker have separate process entry points and will share domain services as later milestones add behavior.

## Local development

Prerequisites: Java 25 and Docker Desktop.

1. Start PostgreSQL: `docker compose up -d database`
2. Run the API: `./mvnw spring-boot:run` (Windows: `mvnw.cmd spring-boot:run`). The Maven plugin is configured to start the API entry point by default.
3. Check health at `http://localhost:8080/actuator/health`.
4. To start the worker entry point instead, run `./mvnw spring-boot:run -Dspring-boot.run.main-class=com.mytasks.worker.MyTasksWorkerApplication` (Windows: `mvnw.cmd spring-boot:run -Dspring-boot.run.main-class=com.mytasks.worker.MyTasksWorkerApplication`). Scheduled jobs are added in later milestones.

The local database defaults are development-only and bind to localhost. Copy `.env.example` to `.env` only if you need to override Docker Compose values. Never reuse these defaults outside local development.

## Layout

- `src/main/java/com/mytasks/api` — HTTP application entry point.
- `src/main/java/com/mytasks/worker` — non-web worker entry point.
- `src/main/resources/db/migration` — Flyway migrations. `V1` creates the application schema; domain tables are introduced in their feature milestone.
- `compose.yaml` — local PostgreSQL service.

The initial project uses Spring Boot 4.1.1, the Maven Wrapper, JDBC, Flyway, PostgreSQL, validation, and Actuator. API modules and worker behavior follow the [LLD](../Documentation/LLD.md).
