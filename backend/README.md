# Backend — Java / Spring Boot

This folder contains the Java 25 LTS Spring Boot modular monolith. The API and worker have separate process entry points and will share domain services as later milestones add behavior.

## Local development

Prerequisites: Java 25 and Docker Desktop.

### Windows PowerShell

The Maven Wrapper uses `JAVA_HOME` to find Java. Point it to your Java 25 JDK folder (the folder that contains `bin`), not to the `bin` folder itself. Set it for the current PowerShell window and confirm the version:

```powershell
$env:JAVA_HOME = 'C:\Path\To\jdk-25'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
& "$env:JAVA_HOME\bin\java.exe" -version
```

Replace `C:\Path\To\jdk-25` with the location where Java 25 is installed. These assignments last for the current window. To make `JAVA_HOME` persist for your Windows user, run this once with your actual path, then open a new PowerShell window:

```powershell
[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Path\To\jdk-25', 'User')
```

Then, from this `backend` folder:

```powershell
docker compose up -d database
.\mvnw.cmd spring-boot:run
```

The Maven plugin starts the API entry point by default. Check health at `http://localhost:8080/actuator/health`, open the interactive API page at `http://localhost:8080/swagger-ui.html`, or inspect its OpenAPI JSON at `http://localhost:8080/v3/api-docs`.

To start the worker entry point instead, run `./mvnw spring-boot:run -Dspring-boot.run.main-class=com.mytasks.worker.MyTasksWorkerApplication` (Windows: `mvnw.cmd spring-boot:run -Dspring-boot.run.main-class=com.mytasks.worker.MyTasksWorkerApplication`). Scheduled jobs are added in later milestones.

Stop the database container with `docker compose down`. This preserves its named data volume; `docker compose down -v` also deletes the local database data.

### Linux and macOS

From this `backend` folder, run `docker compose up -d database`, then `./mvnw spring-boot:run`. The Maven Wrapper uses the Java version available through `JAVA_HOME` or `PATH`.

The local database defaults are development-only and bind to localhost. Copy `.env.example` to `.env` only if you need to override Docker Compose values. Never reuse these defaults outside local development.

## Layout

- `src/main/java/com/mytasks/api` — HTTP application entry point.
- `src/main/java/com/mytasks/worker` — non-web worker entry point.
- `src/main/resources/db/migration` — Flyway migrations. `V1` creates the application schema; domain tables are introduced in their feature milestone.
- `compose.yaml` — local PostgreSQL service.

The initial project uses Spring Boot 4.1.1, the Maven Wrapper, JDBC, Flyway, PostgreSQL, validation, and Actuator. API modules and worker behavior follow the [LLD](../Documentation/LLD.md).
