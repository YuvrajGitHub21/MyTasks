# Project Working Agreement

This project is both a public task application and a learning project for its owner, a software developer with about 1.5 years of experience who wants to learn Java and other software engineering concepts.

## Teaching approach

- Explain concepts in plain language before or alongside using them. Do not assume the owner already knows a framework, tool, or design pattern.
- When making a technical choice, say what was chosen, why it fits this project, and what reasonable alternatives would mean when that distinction helps learning.
- Explain important commands and their effects, especially commands that create build artifacts, containers, images, cloud resources, or persistent data.
- Make the work reviewable in small increments. Avoid silently expanding a task into extra setup or build steps.

## Work updates and file limits

- Before starting a task that changes files or runs substantial setup, summarize the intended actions and expected outcome.
- Work in batches of at most five edited files. If more files need changes, finish the current batch, report the proposed next batch and why it is needed, then get the owner's approval before editing additional files.
- At the end of a batch, list the changed files, explain the important changes, and say what was verified and what remains.
- Explain build or infrastructure actions before running them, including the purpose and any generated or persistent artifacts.

## Git boundary

- Do not run Git commands unless the owner explicitly asks for them. This includes read-only commands such as `git status` and `git diff`.
- Ask before committing, pushing, or otherwise changing Git history or remotes.

## Current guidance

- The owner approved Flutter for the mobile app and Java/Spring Boot for the backend.
- Keep generated build output and local caches out of source control, but keep runtime source assets (such as Android and iOS app icons) in source control unless a documented generation step recreates them.
- Prefer explaining each small phase so the owner can follow and learn the architecture as it grows.
