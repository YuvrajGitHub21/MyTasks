# Functional Requirements Specification (FRS)

**Project:** Personal and public task planning mobile application  
**Status:** MVP baseline updated; alarm-style reminder behavior added; calendar scope remains deferred  
**Version:** 0.7  
**Date:** 18 October 2026

## 1. Purpose

Define the first buildable release of a mobile task-planning application. It captures tasks, highlights work planned for today, supports completion and progress logging, reminds the user to plan or report work, and presents current, future, and completed tasks. Calendar history and a study timer are recorded as later capabilities so the initial design can accommodate them without treating them as launch requirements.

This document is the approved product baseline for MVP planning. The app is intended for personal use first and later public distribution over the internet, initially targeting India. The answered [Open Questions](Open-Questions.md) and selected engineering defaults are reflected in the HLD and LLD.

## 2. Product vision and goals

The application should help an individual reliably decide what to work on today, see the load at a glance, record progress honestly, and understand when work finishes later than planned. It should be suitable for personal use first and capable of supporting a public user base later.

### Goals

- Create and organize tasks using a topic and optional subtopic.
- Plan task dates and effort with clear units.
- Make today's tasks easy to identify, with a green effort-based visual cue.
- Let users mark a task fully complete or record partial progress.
- Separate current, scheduled-for-later, and completed work.
- Offer configurable reminders for planning and end-of-day logging.
- Preserve a useful task and progress history for future calendar and reporting features.

### Out of scope for the initial release

- Study timer and automatic study-time tracking.
- Calendar screen and detailed planned-versus-actual calendar analysis.
- Team collaboration, shared projects, assignment to other people, or public task discovery; users' task data stays private.
- Social features, gamification, and advanced analytics.

“Public” means the app will later be hosted/distributed for anyone to download. It does not mean that users' task data is public or shared. Each user's tasks are private.

## 3. Users and assumptions

### Primary user

An individual who plans tasks for themselves, checks a daily list, and records completion or progress.

### Confirmed direction

- Android and iOS are target platforms. English is the initial language; India is the initial target market.
- Users can enter as a guest with data saved locally, or sign in with Google; account data is saved to a service. Offline use is required.
- Each user's task data is private. Start and planned end dates are mandatory.
- Effort is total estimated work in hours, separate from calendar duration. Actual time tracking is deferred to the study timer.
- The long-term aspirational target is 10,000,000 users in India; HLD should turn this into staged capacity and reliability targets.

## 4. Terminology

| Term | Meaning in this draft |
|---|---|
| Topic | Required, freely entered main point to complete. |
| Subtopic | Freely entered, more specific part of the topic; reusable categories may be added later. |
| Description | Optional explanatory text below the subtopic. |
| Start date | First date on which the task is planned to be active. |
| Planned end date | Current target finish date. |
| Maximum end date | Hard upper-bound date by which the task should be completed. It is distinct from the planned end date. |
| Effort | Total estimated work in hours; it is not calendar duration. |
| Current task | An incomplete task whose planned date range includes today, plus overdue incomplete tasks. |
| Partial completion | A dated progress update using one selected method: percentage, completed units, or note. Multiple logs are allowed; one log per task on a date is enough to satisfy that task's end-of-day reminder. |
| Task log | A dated record with progress information and optional note; actual time is not required in MVP. |

## 5. Scope and release outline

### Initial release (MVP)

1. User setup with local guest use or a cloud account. Google sign-in is supported on Android and iOS; iOS also offers Sign in with Apple.
2. Create, view, edit, complete, reopen, and delete tasks.
3. Current, scheduled-later, and completed task lists.
4. Today's effort-based green visual indicator and overdue red indication.
5. Full completion and partial progress logging.
6. A privacy-safe daily task summary plus configurable, alarm-style actionable reminders, subject to operating-system capabilities and user authorization.
7. Basic settings for reminder times, time zone behavior, and notification preferences.
8. Offline task access and edits, with synchronization for account users and user-mediated resolution when the same task field was changed on multiple offline devices.

### Later release candidates

- Calendar view showing assigned tasks and planned versus actual end dates/delay. User's initial visual intent: planned start/end interval is opaque and the extension after planned end is translucent until completion; details remain to clarify.
- Study timer with standalone sessions or sessions linked to a task.
- Reusable categories, reports, filters, recurring tasks, subtasks/checklists, tags, search, widgets, data export, shared tasks, and other capabilities requested by the user. Scope and sequencing are for a later roadmap.

## 6. Functional requirements

Priority labels: **Must** = required for the first usable release; **Should** = desirable for that release; **Later** = not required in MVP.

### 6.1 Task creation and editing

| ID | Priority | Requirement |
|---|---|---|
| TASK-001 | Must | The user can create a task with a required topic. |
| TASK-002 | Must | The user can add a freely entered subtopic and optional description. Reusable category dropdowns are a later candidate. |
| TASK-003 | Must | The user must set a start date and planned end date. The system validates date order. |
| TASK-004 | Must | The user enters total planned effort in hours. Effort is not elapsed date span. |
| TASK-005 | Must | The user can create, view, edit, and delete task details. Changes to dates or effort are reflected in list placement and visual effort cues. Deleting a task also deletes its progress and completion history. |
| TASK-006 | Should | The user can add notes, subject to a decision on whether notes are needed in the initial release. |
| TASK-007 | Must | The system records creation/update timestamps and dated progress/completion/reopen events while the task exists, preserving the original planned dates needed for later calendar comparisons. Deleting a task also deletes its associated history; history is not automatically pruned while the task exists. |
| TASK-008 | Must | The user may set a maximum end date as a hard upper bound. It must be on or after the planned end date; the task should be completed by this date. |

### 6.2 Task lists and status

| ID | Priority | Requirement |
|---|---|---|
| LIST-001 | Must | The app provides distinct views for current tasks, tasks scheduled for later, and completed tasks. |
| LIST-002 | Must | Incomplete tasks with `start date <= today <= planned end date` are current. Incomplete tasks past planned end date remain in the current list as due/overdue. Tasks with a future start date are scheduled for later. Completed tasks appear only in the completed view. “Today” uses India Standard Time for the initial release. |
| LIST-003 | Must | An empty list presents a clear empty state and a suitable next action, such as creating or scheduling a task. |
| LIST-004 | Should | Additional sorting and filtering beyond the required task views is deferred; completed history supports incremental loading and search/filter. |
| LIST-005 | Must | Users can open a task from a list to view its dates, effort, status, and progress history. |
| LIST-006 | Must | The completed view shows recent completions first and supports search/filter for older completed tasks. History should be loaded incrementally as needed. |

### 6.3 Today and effort visualization

| ID | Priority | Requirement |
|---|---|---|
| VIS-001 | Must | Tasks classified as current for the local date are visibly identifiable as today's work. |
| VIS-002 | Must | Today's tasks use a green visual scale where greater planned effort maps to a darker shade. |
| VIS-003 | Must | Shade mapping is deterministic and understandable; users must not have to infer effort from color alone. Show a numeric effort value and unit or another accessible label. |
| VIS-004 | Must | The green scale remains readable for users with color-vision deficiencies and in supported light/dark themes. Color is supplementary to text/icon cues. |
| VIS-005 | Must | Since effort is entered in hours, the system maps hours to green shade using fixed thresholds: the same effort value maps to the same shade regardless of other tasks. Exact thresholds are set during UI design. |
| VIS-006 | Must | An overdue incomplete task is visibly red and remains in today's task list. Red overdue styling takes precedence over the green effort shade. |

### 6.4 Completion and progress

| ID | Priority | Requirement |
|---|---|---|
| PROG-001 | Must | The user can mark a task fully complete. The system records completion date/time and updates its status and list placement. |
| PROG-002 | Must | The user can record partial completion without closing the task. |
| PROG-003 | Must | A partial update records date/time and exactly one selected progress method: percentage, completed units, or note. A note may be included as the selected method; adding a note alongside another method is not currently required. Users may add progress logs over time; one log on a given day is sufficient to satisfy the end-of-day logging reminder for that task. |
| PROG-004 | Must | The user can review prior progress updates for a task. |
| PROG-005 | Must | The user can correct or remove an erroneous progress update. |
| PROG-006 | Must | If the planned end date passes before full completion, the task remains due/current until completed, appears in today's list in red, and retains its fixed planned end date. The system does not move the planned end date forward each day. |
| PROG-007 | Should | The user can reopen a completed task, with the system preserving the completion event in history. |

### 6.5 Notifications and reminders

| ID | Priority | Requirement |
|---|---|---|
| NOTIF-001 | Must | With user authorization, the app can show a privacy-safe daily task summary for today's current tasks. This informational summary may use the standard dismissible notification presentation. |
| NOTIF-002 | Must | Actionable reminder content is concise and privacy-aware. An alarm action can open task creation or today's task list, as appropriate; it must not include task names on the lock screen by default. |
| NOTIF-003 | Must | The user can enable/disable reminders and configure supported reminder times. Explain and request required notification/alarm authorization only in context; task functionality remains usable if authorization is declined. |
| NOTIF-004 | Must | When there are no active tasks today, present an alarm-style prompt to assign today's work at 9:00 AM and 12:00 PM (noon), in India Standard Time. The user delegated the choice; noon follows their explicit “1200 in 24 hr clock” response. |
| NOTIF-005 | Must | At a configurable end-of-day time, default 10:00 PM, present an alarm-style prompt to log today's work if active incomplete work has no progress log dated today. One log for a task today is sufficient to suppress the reminder for that task. |
| NOTIF-006 | Must | Reminder scheduling uses the initial-release India Standard Time date/time rules and avoids duplicate reminders for the same user, device, reminder type, and date. Support for travel and other time zones is deferred. |
| NOTIF-007 | Must | Actionable reminders use the platform's supported alarm-style presentation: sustained/repeating audible alert until Stop or Snooze, subject to platform limits, plus actions to open the relevant app screen, snooze, and stop/dismiss. A full-screen/lock-screen presentation is used only where the OS and distribution policy permit it. The app must not run a foreground service solely to keep its scheduler alive. |
| NOTIF-008 | Must | If the user denies notification or alarm authorization, core task functionality remains available and the app provides a route to the relevant system settings. |
| NOTIF-009 | Must | Lock-screen daily summary uses a privacy-safe count, e.g. “You have 3 tasks today,” without task names. |
| NOTIF-010 | Must | Users can customize reminder times and quiet hours. Sound and vibration follow user-controlled OS alarm/channel settings. Reminder date/time behavior initially uses India Standard Time; broader travel/time-zone behavior is out of scope for now. |
| NOTIF-011 | Must | The app requests any platform-specific alarm authorization with an explanation. If exact alarm or AlarmKit authorization is unavailable, it reports the limitation and offers a standard-notification fallback only as an explicit user choice; it must not silently replace an alarm with a notification or claim Clock-level delivery guarantees. |
| NOTIF-012 | Must | Tapping “Open” on a no-task alarm opens task creation with today's date selected; tapping “Open” on an end-of-day alarm opens Today. Snoozing delays that alarm by 10 minutes; stopping/dismissing acknowledges the current occurrence without disabling future reminders. |

### 6.6 Future calendar and study timer foundations

| ID | Priority | Requirement |
|---|---|---|
| FUT-001 | Later | Calendar view will show task assignments by date and distinguish original planned end date from actual completion date. |
| FUT-002 | Later | Calendar/reporting will calculate and display schedule extension using a clearly defined comparison (for example, completion date minus original planned end date). |
| FUT-003 | Later | Study timer will let the user track a study session, optionally linked to a task, and persist elapsed duration. Pause, background, interruption, and manual-edit behavior require separate requirements. |
| FUT-004 | Later | Data design should retain the original target date and dated progress/completion events so these features can be added without reconstructing history from current task values. |
| FUT-005 | Later | The user can export all their data in a documented, portable format. This is not required for the first release. |

### 6.7 Account and data lifecycle

| ID | Priority | Requirement |
|---|---|---|
| ID-001 | Must | The user can continue as a guest with task data stored locally, or use Google sign-in on Android/iOS. On iOS, Sign in with Apple is also offered as an equivalent sign-in option. Signed-in data is associated with that user's private account. |
| ID-002 | Must | A guest can transfer local task data to a Google or Apple account. The transfer must avoid duplicate tasks and report success/failure clearly. |
| ID-003 | Must | A signed-in user can request account deletion; sessions are revoked immediately, active primary data is removed within 7 calendar days, and backups expire within 30 days, as disclosed to the user. |
| ID-004 | Must | Deleting a task removes its associated progress and completion history. |
| ID-005 | Must | Account and task data remain private to the owning user. |
| ID-006 | Must | Account deletion can be initiated in the app and through a public web deletion page. The user is told active primary data is removed within 7 calendar days and backups expire within 30 days. |
| ID-007 | Must | The app provides a clear privacy notice before cloud account creation and an accessible privacy-policy link in the app. The notice describes data categories, purposes, identity/push/cloud providers, retention, deletion, and a contact route. Store disclosures match the actual app and SDK behavior. |

## 7. Key business rules to finalize

1. **Calendar:** Calendar is an uncommitted later feature; detailed visual behavior is deferred until the user confirms it is in scope.
2. **Completed view:** Recent completions first with search/filter for older tasks; history is loaded incrementally and remains until task/account deletion.
3. **Data export:** Confirmed as a later feature, not a first-release requirement.

## 8. Non-functional requirements

These are target requirements for design discussion; numerical service targets need product approval.

### Scalability and reliability

- Support personal use and grow toward a public multi-user service, with a long-term aspirational target of 10 million users in India, without exposing one user's data to another. HLD must convert this into staged capacity and reliability targets.
- Keep user data partitioned by authenticated identity; enforce authorization on every server-side read/write if a backend is used.
- Use durable storage and a documented backup/restore approach for synced data.
- Guest users can use local storage without an account and can later transfer their data to a Google or Apple account. Account users can access and edit tasks offline; conflicting edits to the same task field require a user choice during sync.
- Notification scheduling must recover after device restart/app update as permitted by each operating system.
- Define availability, recovery point, and recovery time targets before production launch.

### Performance

- Common task-list and task-detail interactions should feel responsive on supported devices.
- Paginate or incrementally load history as user data grows; do not require downloading a user's entire lifetime history to render today's list.
- Set measurable response-time budgets during technical design after selecting local-only versus synchronized architecture.

### Security and privacy

- Collect only data needed for task planning and operation.
- Protect data in transit and at rest when a service or cloud backup is used.
- Provide account deletion that removes associated cloud data. Remove active primary account data within 7 calendar days after a verified request; backups expire within 30 days, and this timing is disclosed at request time. Users can delete tasks, including their progress and completion history. Full-data export is planned for a later release.
- Keep notification previews configurable because task names can be sensitive.
- Do not expose personal tasks publicly by default.

### Accessibility and usability

- Do not use green shade as the sole indicator of effort or status.
- Support screen readers, scalable text, adequate contrast, and touch targets on supported platforms.
- Use explicit dates and units; avoid ambiguous abbreviations such as “m” for months/minutes.

### Compatibility and operations

- Minimum OS: Android 7.0 (API 24) and iOS 15.0. Build and target the latest platform SDKs required by the stores at submission time.
- English is the initial language and India is the initial target market.
- MVP does not use advertising or cross-app tracking and does not collect product analytics. Optional crash diagnostics must be disclosed, content-redacted, and off until the user opts in.
- The app provides an accessible privacy notice before cloud account creation, a privacy-policy link in the app and store listings, and an in-app account-deletion flow. Google Play also receives a public web deletion-request URL.
- Initial data retention: account task data remains until the user deletes it or deletes the account; guest data remains only on the device until user deletion/app removal; account deletion removes active primary data within 7 calendar days and backups expire within 30 days; routine operational logs expire within 30 days, security/audit events within 90 days, and invalid or 90-day inactive push tokens are removed.
- Production release should include crash monitoring, operational alerting, and a support path, with privacy controls.

## 9. Data concepts (logical, not physical schema)

- **User:** Google or Apple identity, or a local guest profile; locale/time zone, preferences, notification choices.
- **Task:** owner/local profile, topic, subtopic, optional description, mandatory start date, planned end date, optional maximum end date as a hard upper bound, total effort in hours, status, timestamps, original planned date history.
- **Progress event:** task, timestamp, selected progress method/value, optional note; retains event history and supports user corrections.
- **Completion event:** task, completion timestamp, and reopening history if supported.
- **Reminder preference/event:** user preference and enough scheduling state to prevent duplicate reminders. Exact persistence and platform scheduling are design decisions.

This is a conceptual starting point. It does not prescribe database tables or a particular backend.

## 10. Acceptance criteria for MVP readiness

- A user can create and edit a task with validated topic, dates, and effort.
- Current, later, and completed lists follow approved rules, including overdue tasks; start and planned end dates are mandatory.
- Today's tasks have an effort-based green cue with a readable numeric effort label and accessible non-color cue.
- Full completion moves the task to completed and records when it happened.
- Partial progress is saved as a dated event and leaves the task open.
- Reminder behavior follows approved schedules and rules when permission is granted; it degrades clearly when permission is unavailable.
- The user can change notification preferences and does not lose task access after denying notifications.
- Guest mode works locally; Google- or Apple-account mode supports offline access and sync without exposing one user's data to another. iOS presents both Google and Sign in with Apple account choices.
- Users can export their data if export is included in the approved release scope; permanent deletion behavior follows the approved lifecycle policy.

## 11. Dependencies and constraints

- Mobile OS notification policies and user permission choices limit persistent notification behavior.
- Guest alarm prompts use local OS scheduling; signed-in alarm prompts use the device's latest synchronized local state, with backend push available for supplemental summaries. Delivery remains subject to OS authorization and restrictions.
- Public availability implies release operations, privacy disclosures, support, and potentially account/data lifecycle requirements; the exact obligations depend on release markets and platform choices.
- The FRS, HLD, LLD, and [Implementation Roadmap](Implementation-Roadmap.md) form the current MVP planning baseline; update them together when scope changes.

## 12. Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 13 October 2026 | Initial draft based on the user's feature notes; unresolved decisions listed separately. |
| 0.2 | 13 October 2026 | Incorporated answers on platforms, Google and guest modes, required dates, hour estimates, offline use, overdue styling, lock-screen privacy, and long-term India scale target. |
| 0.3 | 13 October 2026 | Incorporated answers on upper-bound date, fixed overdue date, selected progress method, India time-zone scope, guest migration, sync conflict resolution, account/task deletion, completed history, and export timing. |
| 0.4 | 13 October 2026 | Set no-task reminders to 9 AM and noon, captured the end-of-day log suppression rule, and selected fixed effort-to-color thresholds. Calendar remains deferred. |
| 0.5 | 16 October 2026 | Selected Android/iOS minimum versions, privacy-minimizing MVP defaults and retention windows; added iOS Sign in with Apple, in-app/web account deletion, and clarified task-history retention. |
| 0.6 | 16 October 2026 | Aligned reminder scheduling with the selected IST-only MVP behavior; other time zones are deferred. |
| 0.7 | 18 October 2026 | Changed actionable no-task and end-of-day reminders from ordinary notifications to authorized alarm-style alerts with open, snooze, and dismiss behavior; retained the daily summary as informational. |
