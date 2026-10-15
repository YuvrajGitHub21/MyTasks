# Backend — Java

The hosted backend will use Java 25 LTS and Spring Boot as a modular monolith, with API and worker entry points as described in [`../Documentation/HLD.md`](../Documentation/HLD.md) and [`../Documentation/LLD.md`](../Documentation/LLD.md).

## Planned setup

M1 will add the Maven Wrapper, pinned dependency configuration, API health endpoint, local development profile, and migration baseline. Backend product endpoints are sequenced after the local-first guest task experience; do not add cloud credentials to this folder or commit them.
