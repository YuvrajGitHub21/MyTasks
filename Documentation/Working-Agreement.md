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

## AI-DLC-informed delivery approach

We use the public [AWS Labs AI-DLC workflow](https://github.com/awslabs/aidlc-workflows) as a process reference, adapted to this learning project and the tools available in this workspace. This is a lightweight, human-reviewed approach; it is not a claim that the AI-DLC runtime is installed or that every AI-DLC stage is being executed.

### How we apply it

For a meaningful feature or milestone, work through these checkpoints:

1. **Frame the intent:** state the user outcome, scope, exclusions, and relevant FRS requirements.
2. **Understand the workspace:** inspect the existing code and docs before proposing architecture or edits; preserve existing decisions unless evidence shows a conflict.
3. **Design the change:** explain the data flow, important decisions, tradeoffs, and affected boundaries in beginner-friendly language.
4. **Plan small units:** identify files and the expected result for the next batch. Keep batches to at most five edited files and wait for owner approval before the next batch.
5. **Implement and verify:** explain commands and generated/persistent effects before running them; run only verification the owner has authorized; record actual results and limitations.
6. **Review and learn:** summarize changed files, requirement coverage, concepts learned, outstanding decisions, and the next suggested step.

The owner remains the decision-maker at scope, design, and batch approval points. A recorded approval applies only to the work it names. Existing rules remain in force: no Git commands without explicit authorization, and no adding or running automated tests unless the owner asks.

### Workflow depth by work type

- **M2:** use the AI-DLC **MVP** profile as a planning reference because M2 is a real first product increment. Apply requirements-to-design-to-small-implementation checkpoints, while keeping the detailed [M2 plan](M2-Implementation-Plan.md), five-file limit, and learning explanations. Do not import the full 23-stage runtime ceremony into routine conversations.
- **Small known defect:** use the focused **Bugfix** profile idea: reproduce/understand the issue, make a narrow change, and agree on verification.
- **Exploration or disposable prototype:** use the **Proof of concept** profile idea and label the result as a feasibility experiment, not production-ready work.
- **Infrastructure or release work:** use the **Infrastructure** or full **Feature** planning ideas as appropriate, with explicit operational and security review before changes.

### Runtime and tool boundary

AI-DLC documents a Codex CLI integration. This workspace conversation does not expose that CLI workflow command, and configuring the runtime would add project hooks/settings and alter the Windows user PATH. We therefore apply the methodology manually unless the owner later requests a separate installation/configuration review. Any such setup would be proposed first with the files and machine-level changes made explicit.
