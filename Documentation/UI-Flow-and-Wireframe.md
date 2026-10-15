# UI Flow and First-Pass Wireframes

**Project:** Personal and public task planning mobile application  
**Status:** Current clickable preview approved as the visual baseline; detailed MVP flows remain implementation references  
**Version:** 0.1  
**Date:** 16 October 2026  
**Basis:** [FRS.md](FRS.md) v0.5, [HLD.md](HLD.md) v0.4, [LLD.md](LLD.md) v0.4, [Implementation-Roadmap.md](Implementation-Roadmap.md) v0.3

## 1. Purpose and scope

This document turns the agreed MVP requirements into a screen map and simple wireframes. It is a design artifact for review before detailed visual styling or Flutter implementation. It covers the first release only; the calendar and study timer remain deferred.

Open the [clickable browser preview](app-preview.html) to explore the Today, Later, and Completed views and the task flows described here.

## 2. Navigation model

Use a three-destination bottom navigation bar matching the three required task views. Keep task creation available from each destination. Put account, notification, privacy, and app settings behind the profile/settings control in the top bar.

```mermaid
flowchart TD
    Launch[Launch] --> Setup[Guest or sign in]
    Setup --> Today[Today / Current]
    Today <-->|Bottom navigation| Later[Later / Scheduled]
    Today <-->|Bottom navigation| Completed[Completed]
    Later <-->|Bottom navigation| Completed
    Today --> Create[Create task]
    Later --> Create
    Completed --> Detail[Task details]
    Today --> Detail
    Later --> Detail
    Detail --> Progress[Log partial progress]
    Detail --> Finish[Complete or reopen]
    Today --> Settings[Settings and account]
    Later --> Settings
    Completed --> Settings
    Settings --> ReminderSettings[Reminder preferences]
    Settings --> Account[Sign in, sync, deletion]
    Account --> Conflict[Resolve sync conflict]
```

### Global navigation decisions

- Bottom tabs: **Today**, **Later**, **Completed**. Use text labels and icons; the selected tab is not indicated by color alone.
- A floating **+** action opens the task editor. From Today, the start date defaults to today; from Later, it defaults to the next available future date. The user can change either date.
- The app bar shows the screen title, a small offline/sync state when relevant, and a settings/profile button.
- Back navigation preserves the active list and scroll position.
- Do not require sign-in before a user can use guest mode.

## 3. User journeys

### 3.1 First launch and profile choice

```mermaid
flowchart LR
    Welcome[Welcome: local or synced use] --> Guest[Continue as guest]
    Welcome --> Google[Continue with Google]
    Welcome --> Apple[Continue with Apple on iOS]
    Guest --> Today[Today list]
    Google --> Today
    Apple --> Today
    Guest --> Upgrade[Settings: connect account]
    Upgrade --> Transfer[Review local data transfer]
    Transfer --> Today
```

Explain the choice in plain language: guest data stays on this device; signing in enables account sync across devices. Link the privacy notice before account creation. On iOS, show Google and Apple sign-in as equivalent choices. Ask for notification permission only when the user enables reminders or reaches the reminder setup flow.

### 3.2 Create a task

```mermaid
flowchart LR
    List[Today or Later list] --> Add[Tap +]
    Add --> Form[Enter task details]
    Form --> Validate[Validate fields and date order]
    Validate -->|Valid| Save[Save locally]
    Validate -->|Invalid| Form
    Save --> ListUpdated[Return to correct list]
```

Required fields: topic, start date, planned end date, and effort in hours. Optional fields: subtopic, description, and maximum end date. Use the selected LLD limits and date rules. Keep the effort control explicitly labeled **Estimated effort (hours)**; effort is not elapsed time or calendar duration.

### 3.3 Review and update a task

From any task card, open Task Details. The user can edit the task, add partial progress, mark it complete, reopen it when supported, or delete it after confirmation. The detail page shows planned dates, maximum date if set, effort, current status, and dated progress/completion history.

### 3.4 Record partial progress

Select exactly one method: percentage, completed units, or a note. Save creates a dated progress entry and leaves the task open. Repeated entries are allowed. The history view provides edit and delete actions for correcting an entry.

### 3.5 Resolve a sync conflict

When the same task field changed on this device and another device, show the field name, the local value, and the account value. The user selects which value to keep. Explain that the selection applies to that field; keep unrelated edits. Do not silently replace a value.

## 4. Low-fidelity screen layouts

These layouts show information hierarchy and primary actions, not final pixel measurements.

### 4.1 Today / Current

```text
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Today                 Offline  âš™ â”‚
â”‚ Thursday, 16 October              â”‚
â”‚ 3 tasks Â· 6.5 h across current    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ TODAY                             â”‚
â”‚ â–Œ Review algebra                 â”‚
â”‚ â–Œ Chapter 4                      â”‚
â”‚ â–Œ Effort 2 h   Due today     â€º    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ â–Œ Finish assignment              â”‚
â”‚ â–Œ Effort 3.5 h  Due 18 Oct   â€º    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ â–Œ Revise notes                    â”‚
â”‚ â–Œ Effort 1 h    Overdue      â€º   â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                  â”‚
â”‚                         [  +  ]  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Today       Later     Completed  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

Show current and overdue open tasks here. If empty, use a calm empty state with **No tasks for today** and a primary **Add a task** action. Display effort and status as text so color is never the only signal. A count-only lock-screen notification is configured separately from this screen.

### 4.2 Later / Scheduled

```text
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Later                  Offline âš™ â”‚
â”‚ Tasks starting after today       â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ NEXT                              â”‚
â”‚ Prepare presentation             â”‚
â”‚ Starts 21 Oct Â· Ends 24 Oct      â”‚
â”‚ Effort 5 h                  â€º    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ 28 October                       â”‚
â”‚ Read research paper              â”‚
â”‚ Starts 28 Oct Â· Ends 30 Oct      â”‚
â”‚ Effort 2 h                  â€º    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                         [  +  ]  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Today       Later     Completed  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

Sort by start date, then planned end date. Show the date range and effort. Future tasks do not use the current-task effort-green treatment.

### 4.3 Completed

```text
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Completed                 âš™     â”‚
â”‚ [ Search completed tasks      ]  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ TODAY                            â”‚
â”‚ âœ“ Submit lab report              â”‚
â”‚ Completed 10:42 AM Â· Effort 2 h  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ YESTERDAY                        â”‚
â”‚ âœ“ Clean desk                     â”‚
â”‚ Completed 6:15 PM Â· Effort 1 h   â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  Today       Later     Completed  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

Show most recently completed tasks first. Load older history incrementally; provide search/filter for completed tasks. A completed card has a check icon and the word **Completed**, independent of color.

### 4.4 Create / edit task

```text
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ â€¹ Back        New task           â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Topic *                           â”‚
â”‚ [                              ] â”‚
â”‚ Subtopic                          â”‚
â”‚ [                              ] â”‚
â”‚ Description                       â”‚
â”‚ [ Add details                  ] â”‚
â”‚                                  â”‚
â”‚ Start date *      Planned end *  â”‚
â”‚ [ 16 Oct       ]  [ 18 Oct     ] â”‚
â”‚ Maximum end date (optional)       â”‚
â”‚ [ Choose date                  ] â”‚
â”‚                                  â”‚
â”‚ Estimated effort (hours) *       â”‚
â”‚ [ 2.5                          ] â”‚
â”‚                                  â”‚
â”‚ [          Save task           ] â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

Use a numeric decimal keyboard for effort. Display dates in an unambiguous localized format. Validate end date >= start date and maximum end date >= planned end date. Preserve entered values when showing validation errors.

### 4.5 Task details and progress

```text
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ â€¹ Back        Task details    â‹®  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Finish assignment                â”‚
â”‚ Topic / subtopic                 â”‚
â”‚                                  â”‚
â”‚ 16â€“18 Oct Â· Max 20 Oct           â”‚
â”‚ Estimated effort       3.5 h     â”‚
â”‚ Status                 Current   â”‚
â”‚                                  â”‚
â”‚ [ Log progress ] [ Complete ]    â”‚
â”‚                                  â”‚
â”‚ Progress history                 â”‚
â”‚ 16 Oct Â· 50%                     â”‚
â”‚ 15 Oct Â· Started section 1       â”‚
â”‚                                  â”‚
â”‚ [ Edit task ]                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

The overflow menu contains Delete, with a clear confirmation that deleting also removes progress and completion history. Reopen appears for completed tasks when enabled.

### 4.6 Partial progress form

```text
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ â€¹ Back        Log progress       â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Finish assignment                â”‚
â”‚                                  â”‚
â”‚ Progress type                    â”‚
â”‚ (â€¢) Percentage  ( ) Units  ( ) Noteâ”‚
â”‚                                  â”‚
â”‚ Completed                        â”‚
â”‚ [ 50 ] %                         â”‚
â”‚                                  â”‚
â”‚ Date and time                    â”‚
â”‚ [ Today Â· Now                 ] â”‚
â”‚                                  â”‚
â”‚ [       Save progress          ] â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

Switching the method replaces the method-specific input; do not combine methods in one entry. The note method shows a note field instead of percentage/units.

### 4.7 Reminder settings

```text
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ â€¹ Settings       Reminders       â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Notifications            [ On ]  â”‚
â”‚ No tasks today                  â”‚
â”‚   First reminder       [ 9:00 ]  â”‚
â”‚   Second reminder      [12:00 ]  â”‚
â”‚ End-of-day log reminder [22:00 ] â”‚
â”‚ Quiet hours             [ Off ]  â”‚
â”‚ Sound                   [ On ]  â”‚
â”‚ Vibration               [ On ]  â”‚
â”‚                                  â”‚
â”‚ Times use India Standard Time.   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

When OS permission is denied, explain how to enable it in system settings and keep all task features available. Quiet hours follow the LLD's same-day defer-or-suppress rule.

### 4.8 Settings, profile, and sync

Include: current profile type (Guest / signed-in provider), sync state, **Connect account** for guests, **Sync now**, notification settings, privacy policy, app licenses, and **Delete account** for signed-in accounts. Account deletion requires re-authentication and displays the 7-day primary-data and 30-day backup windows before final confirmation.

## 5. Effort-based green treatment

Use a deterministic five-level scale based only on estimated hours. Apply the green level to a slim card accent and a labeled effort chip; keep the main task text on a neutral card background for readability.

| Estimated effort | Level | Suggested light-theme indicator |
|---|---|---|
| `0 < h <= 1` | 1 | `#E8F5E9` |
| `1 < h <= 3` | 2 | `#C8E6C9` |
| `3 < h <= 6` | 3 | `#A5D6A7` |
| `6 < h <= 10` | 4 | `#66BB6A` |
| `h > 10` | 5 | `#2E7D32` |

Always show the numeric effort, for example **Effort 3.5 h**, plus an accessible textual description such as **Higher effort** for the level. Use contrast-checked text on the chip; do not rely on the suggested color alone. Define equivalent contrast-safe dark-theme tokens during implementation.

Overdue styling takes precedence over the green accent: use a red accent, an explicit **Overdue** label, and an overdue icon. Continue to show the effort value. Scheduled and completed tasks do not use the green current-task scale.

## 6. Accessibility and interaction rules

- Every interactive control has a screen-reader label; icons that communicate status have accompanying text.
- Respect system text scaling and support light/dark appearance.
- Meet contrast requirements for text and interactive controls; test each status token in both themes.
- Keep touch targets comfortable for one-handed use and place the primary action within reach on long forms.
- Use confirmation for destructive task/account deletion, with a clear cancel action.
- Show pending/offline/sync-failed state without blocking local task use.
- Preserve keyboard focus, entered form values, and scroll position when navigating back from an error or detail view.
- Do not use color as the sole encoding of effort, overdue, completion, selection, or sync state.

## 7. Notification and platform boundaries

- Notifications are an OS-controlled surface and may be dismissed. The app does not promise an uncloseable permanent task notification.
- Default lock-screen content is a privacy-safe count, not topic/subtopic text.
- Tapping a daily summary opens Today; tapping an end-of-day reminder opens the tasks that still need a log.
- Calendar and study-timer destinations are not shown in the MVP navigation.

## 8. Review checklist for the wireframes

- Do the three bottom tabs make the required task views easy to find?
- Is creating a task reachable in one action from the task lists?
- Is the distinction between effort hours and date duration clear?
- Can the user identify current, overdue, scheduled, and completed tasks without interpreting color?
- Are progress method choices understandable and mutually exclusive?
- Is guest-vs-account data behavior clear before a user chooses sign-in or transfer?
- Are reminders, sign-in, and deletion transparent about OS or retention constraints?


