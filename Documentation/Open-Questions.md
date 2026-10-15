# Product Decisions and Answers

**Project:** Personal and public task-planning mobile application  
**Status:** The user's answers have been recorded; implementation defaults and later decisions are reflected in the FRS, HLD, LLD, and [Implementation Roadmap](Implementation-Roadmap.md).  
**Purpose:** Preserve the original product decision context for future reference. This is a decision record; no response is currently requested.  

## A. Product and launch scope

1. **What do you mean by â€œpublicâ€?** Is this an app released for anyone to install, while each person's tasks stay private, or should users be able to share/view tasks with other people?

   **Why this matters:** Public sharing changes permissions, privacy, account design, and backend requirements.

   **Answer:**
 For public i mean over the internet .  
Currently this is fr my personal use but later i will host it and it will be open in playstore to download and use 
2. **Which platforms should the first version support?** Android, iOS, or both? Any preferred technology (native, Flutter, React Native), or should that be decided in HLD?

   **Why this matters:** Notification behavior and development choices differ by platform.

   **Answer:**
I think i should  support both android and iphones 
3. **Should users sign in and sync across devices in the first release, or should the first version work locally on one device?** Should users be able to use it without an account?

   **Why this matters:** This determines whether launch needs a backend, account recovery, sync, and cloud data handling.

   **Answer:**
 User can log in using their gmail accont  or there will we a feature "Use as a Guest"  
  The Use as a guest would save users data , all the things will be on local , for gmail account we will save data 
4. **Who is the target user for launch?** Just you initially, or a broad audience with different locales, languages, and time zones from day one?

   **Why this matters:** It helps set localization, usability, support, and scale requirements.

   **Answer:**
 For now i am the only user , but later my friends will use this . no need to worry about different language , language will be english onlly, 
## B. Task fields and dates

5. **What is a â€œTopicâ€ and â€œSubtopicâ€ in your mind?** Should users type them freely for each task, choose from reusable categories, or both?

   **Why this matters:** Reusable categories enable filtering and consistent labels; free text is more flexible.

   **Answer:**
 good idea , by topic and subtics are written freely , no categorizatin on it , but keep this point for later that we can add a category dropdown also here .
6. **Should tasks have a separate title in addition to Topic and Subtopic?** For example: Topic â€œStudyâ€, Subtopic â€œMathâ€, task title â€œFinish chapter 3 exercisesâ€.

   **Why this matters:** Topic/subtopic alone may not describe a specific action, especially in notifications and task lists.
 
   **Answer:**
 Ok so will will also add a optional desription below subtopic  think like this , topic is the main point to complete .  
lets take a example . Topic : COmplete Graph playlist , subtopic will be , complete DAG  , Cycle graph , BFS etc . 
7. **What does â€œMaximum end dateâ€ mean?** Pick or describe the closest meaning:
   - Hard latest date the task is allowed to finish
   - A pessimistic/upper-bound estimate distinct from planned end date
   - Deadline buffer or escalation date
   - Something else

   **Why this matters:** The field affects validation, overdue state, and the future planned-versus-actual calendar.

   **Answer:**
Hard latest date the task is allowed to finish
A pessimistic/upper-bound estimate distinct from planned end date
   - Deadline buffer or escalation date

   all three i guess

8. **How should â€œcurrent taskâ€ be decided?** Recommended default: a task is current on each date from its start date through planned end date, inclusive, unless completed. Should this include overdue tasks after the planned end date?

   **Why this matters:** The rule controls the today list, notification summary, and no-task reminders.

   **Answer:**
   YES
9. **How should future/scheduled tasks be decided?** Recommended default: start date is after today. What should happen to tasks with no start date, if dates can be optional?

   **Why this matters:** Each task needs one predictable home in the three views.

   **Answer:**
   Dates are mandatory .
10. **Are start and planned end dates mandatory?** Can a task have a deadline but no start date, or an open-ended duration?

   **Why this matters:** Optional dates complicate list placement, reminders, and calendar display.

   **Answer:**
   Yes


11. **When a task is not finished by its planned end date, what should the user do?** Keep the original plan and mark overdue, explicitly reschedule it, or automatically extend it? Should the original date remain visible in history?

   **Why this matters:** The future calendar needs to show the original plan and the amount of extension accurately.

   **Answer:**
   It will automatically extend its time to current time . 
   it will show as a work due in today task list . 
   it will show as a red . 

## C. Effort, progress, and completion

12. **What does effort represent?** Recommended default: total estimated work, separate from the number of calendar days between start and end. Is that right?

   **Why this matters:** A task spanning a week may require only two hours of effort; the app should not confuse duration with workload.

   **Answer:** YES .

13. **How should effort be entered?** One estimate in hours only, or selectable hours/days/months? If days/months are allowed, do they mean working days/months or calendar time, and should users specify hours per day?

   **Why this matters:** The green intensity requires comparable values. â€œ2 daysâ€ cannot be compared reliably to â€œ8 hoursâ€ without a conversion rule.

   **Answer:** Efforts is masured in hours . 

14. **Should effort be total per task or planned per day?** If a task spans several days, should its shade represent its total effort or today's planned effort?

   **Why this matters:** Per-day effort better describes today's load; total effort is simpler to enter.

   **Answer:** It is totaled per task . 

15. **How should partial completion work?** Choose one or combine:
   - Percentage complete
   - Completed units (e.g., 3 of 10 exercises)
   - A brief progress note only
   - Percentage/units plus an optional note

   Can users add multiple progress logs in a day?

   **Why this matters:** This shapes the task log, reminder suppression rule, and later progress reporting.

   **Answer:** YES , combine all , we will ask use to slelect any one of that . 

16. **What information should a progress log capture?** Recommended minimum: date/time, progress amount or status, optional note. Should it also capture actual time spent?

   **Why this matters:** Actual time could overlap with the later study timer feature and influence the data model.

   **Answer:** ok

17. **Can a completed task be reopened?** Should users be able to edit/delete a mistaken progress log or completion event?

   **Why this matters:** We need a clear history policy while still allowing corrections.

   **Answer:** Yes completed task can be reopend . and it can be edit also . 
   All crud oprations 

## D. Notifications and daily workflow

18. **You wrote â€œ9 am and 12 amâ€ for the no-task reminder. What exact second time did you intend: 12:00 PM (noon), 12:00 AM (midnight), or another time?**

   **Why this matters:** These lead to very different reminder behavior; â€œ12 amâ€ means midnight in common time notation.

   **Answer:**Ok.

19. **Should the no-task reminder fire when there are no tasks starting today, or when there are no active tasks at all today?** Should it stop after you create/assign a task?

   **Why this matters:** A multi-day task may already be active today even if nothing starts today.

   **Answer:** in both cases .

20. **At 10 PM, when exactly should the â€œlog what you did todayâ€ reminder appear?** Recommended default: if at least one task was active today and is still incomplete, and that task has no progress log dated today. Should any log suppress the reminder, even if the task remains incomplete?

   **Why this matters:** The reminder should prompt the behavior you want without repeatedly notifying after you have already logged.

   **Answer:** YEs

21. **Do you need a notification that stays permanently visible and cannot be dismissed?** On common mobile platforms, users and operating systems control notifications; a general promise that one can never be hidden or closed is not available. Would a dismissible daily summary, with reminders that reappear on schedule, meet the need?

   **Why this matters:** This is a platform constraint, especially for iOS, and must shape the requirement before implementation.

   **Answer:** Its oky , but i have seed some of the application notifucation when the app was runnign you cannot dismiss its notification 

22. **Should notification text show task names on the lock screen, or use a privacy-safe message such as â€œYou have 3 tasks todayâ€?**

   **Why this matters:** Task names may reveal private information to people near the device.

   **Answer:** Yes , in lock screen â€œYou have 3 tasks todayâ€

23. **Should users be able to change reminder times, quiet hours, and notification sound/vibration?** What should the default time zone behavior be when traveling?

   **Why this matters:** Reminders need to behave predictably and respect user preferences.

   **Answer:** YES ,, it is customisaable 

## E. Views and future features

24. **What should completed tasks show by default?** All completed tasks, recent tasks (for example, the last 30 days), or searchable history?

   **Why this matters:** This affects list usability and how much history loads on a phone.

   **Answer:** YES

25. **For the later calendar, which dates should be visible?** Start date, each active day, planned end date, actual completion date, and maximum end date? What exactly should â€œhow much it is extendedâ€ compare?

   **Why this matters:** We can preserve the necessary date history in the initial task model.

   **Answer:**the start and end date the task should be opaque and for the extended period till the task is completed will be in tranulecet .

26. **For the later study timer, should sessions link to a task, and should time be counted toward task progress/effort?**

   **Why this matters:** Linking it now at the data level can avoid a redesign, while keeping the timer out of MVP.

   **Answer:** , It can be independent and can be link to a task 

27. **Which additional capabilities are important after MVP?** Examples: recurring tasks, subtasks/checklists, tags, search, widgets, backup/export, shared tasks, or reports.

   **Why this matters:** This helps keep the first release focused while leaving room for likely extensions.

   **Answer:** All ot thsi 

## F. Non-functional expectations

28. **Do you expect the app to work offline?** If yes, should users be able to create/edit/log offline and sync later?

   **Why this matters:** Offline-first design influences conflict handling, storage, and development effort.

   **Answer:** YES 

29. **Do you have any launch scale expectations?** For example, approximate users in the first year or target countries. If unknown, we can size for an early-stage public app and define measurable targets in HLD.

   **Why this matters:** Scalability should be designed against expected usage rather than an arbitrary large-system target.

   **Answer:** , TArget country India , expected user be 10,000,000 for later 

30. **Should users be able to export and permanently delete their data?** Any backup or retention expectations?

   **Why this matters:** These are important lifecycle requirements for a public app and affect the storage design.

   **Answer:** There can be a feature to export all the data where the user can export all its data . 

31. **Are there accessibility or language needs for launch?** For example, screen-reader support, larger text, dark mode, or languages beyond English.

   **Why this matters:** These are easier to include in interaction and visual design from the start.

   **Answer:** No not for now 

32. **Any preferences for monetization, analytics, or account recovery?** These can be deferred, but should be recorded if already known.

   **Why this matters:** Monetization and analytics can change onboarding, privacy disclosures, and infrastructure choices.

   **Answer:** No not for now 

## Suggested response

You can answer in shorthand by number, such as `1) released publicly, private tasks; 2) Android first; 3) local first`. For any question where you want me to recommend a choice, write `recommend a default`.

---

## Follow-up questions and answers

These follow-ups were added after reviewing the first round. Answers are recorded below. For question 46, you delegated the time choice; I selected 12:00 PM (noon), using your â€œ1200 in 24 hr clockâ€ note. The remaining calendar decision is intentionally deferred.

33. **What exact second time should the no-task reminder use?** Your â€œOkâ€ did not select a time. Choose 12:00 PM (noon), 12:00 AM (midnight), or another time.

   **Why this matters:** The reminder schedule cannot be implemented until this is explicit.

   **Answer:** No task reminder 1200 in 24 hr clock . 
   first alarm is at 9am 2nd at 11 am , rewrite this if i had told anything differetn earlier .

34. **For â€œin both casesâ€ in the no-task reminder, do you mean send a reminder if either there is no task starting today OR there is no active task today?** Recommended simpler rule: remind only when there are no active tasks today; this avoids prompting when a multi-day task is already underway. Please confirm or describe your intended rule.

   **Why this matters:** â€œNo task starting todayâ€ and â€œno active task todayâ€ differ when a task began earlier and continues today.

   **Answer:** Recommended simpler rule: remind only when there are no active tasks today; this avoids prompting when a multi-day task is already underway , yes yes

35. **The maximum-end-date answer describes three meanings. Should the app use these as separate concepts?** Recommended: planned end date is the target; maximum end date is the hard latest acceptable date; a deadline buffer is optional planning metadata (or omitted from MVP). Does that match what you want?

   **Why this matters:** One date field cannot simultaneously be a target, an upper-bound estimate, and a buffer without confusing users and deadline rules.

   **Answer:** It is a upper bound that the task should be completed before that . 

36. **When a task passes its planned end date, should the stored planned end date stay fixed while the task is shown as overdue/current until completion?** Your answer says it â€œautomatically extend[s] its time to current time.â€ Recommended: keep the original planned date fixed for history and calculate the extension through today/completion, rather than changing the original date each day. Confirm?

   **Why this matters:** Changing the planned date daily would erase the amount of delay needed for your calendar view.

   **Answer:** the end date should be fixed , the task after its end date will be shown as due.

37. **For partial logs, may a user combine percentage, completed units, and a note in one log, or must they select only one method?** Also, can they add several logs for the same task on one day?

   **Why this matters:** â€œCombine allâ€ and â€œselect any oneâ€ can mean either one selectable method or all methods together. This also determines how the 10 PM reminder detects a log.

   **Answer:** , any one method can be selected to log the task . 

38. **Should task dates/settings support travel across time zones using the device's current local time, or remain anchored to the time zone where the task was created?**

   **Why this matters:** This determines which day counts as â€œtodayâ€ and when local reminders fire during travel.

   **Answer:** , do not focus on this now , we are focusing on indian time zone only

39. **Can guest users later convert/transfer their local data to a Google account?**

   **Why this matters:** A migration path avoids making users recreate tasks if they later want cloud backup or multi-device access.

   **Answer:** YES

40. **Should users be able to permanently delete their account and associated cloud data?** You confirmed full-data export; please also confirm deletion and whether any retention period is needed.

   **Why this matters:** Export and deletion are separate data lifecycle capabilities for a public service.

   **Answer:** YES 

41. **For the completed-tasks view, which default do you want: all completed tasks, recent tasks, or searchable history?** Recommended: show recent completions first and provide search/filter for older tasks.

   **Why this matters:** â€œYESâ€ did not select one of the alternatives, and loading all history at once can become slow as usage grows.

   **Answer:** yes

42. **For the calendar, is the intended display that the planned start-to-end interval is opaque, and the period after planned end through actual completion is translucent?** Should the maximum end date also be marked?

   **Why this matters:** This translates your opacity/translucency description into an unambiguous visual rule.

   **Answer:** Not currently i will tell you later if we were including it 

43. **For a logged-in account used on multiple devices offline, how should conflicting edits be handled?** Recommended initial behavior: sync non-conflicting changes automatically and ask the user to choose if the same task field was changed on both devices.

   **Why this matters:** Offline use plus account sync needs a predictable conflict rule to prevent silently losing edits.

   **Answer:** Yes

44. **Should full-data export be part of the first public release, or can it follow shortly after launch?**

   **Why this matters:** Export affects file format, data model, and release scope; an early answer lets HLD plan for it.

   **Answer:** Can be do later 

45. **When a user deletes a task, should it disappear immediately and permanently, or go to a recoverable trash/archive first?** Should deleting a task also delete its progress and completion history?

   **Why this matters:** You asked for full CRUD and editable history. We need to know whether â€œdeleteâ€ should preserve a recovery/audit path or remove all related records.

   **Answer:** YES , delete should remove all the history of the task . 

46. **Please confirm the second no-task reminder time.** You wrote â€œ1200 in 24 hr clockâ€ (12:00 / noon), then specified the first alarm at 9 AM and the second at 11 AM. Should the defaults be **9:00 AM and 11:00 AM**, with â€œ12:00â€ being a correction/typo?

   **Why this matters:** The two times in the same answer conflict, and the reminders should not be scheduled at the wrong time.

   **Answer:** Pick time you like, please. Decision: use 9:00 AM and 12:00 PM (noon) in India Standard Time. This follows the explicit 24-hour â€œ1200â€ notation.

47. **Can a task have multiple progress logs on the same day?** Your answer confirms one method per log (percentage, units, or note), but does not say whether the user may log more than once daily.

   **Why this matters:** This affects the task history and whether one log is sufficient to suppress the 10 PM reminder.

   **Answer:** One log on a given day is sufficient to suppress the 10 PM reminder. The FRS supports progress logs over time; it does not impose a one-log-per-day limit.

48. **How should hours map to the green effort shades?** Choose a fixed scale (the same number of hours always gets the same shade) or a relative scale (darker compared with other tasks due today). Recommended for predictable meaning: fixed thresholds, which we can tune during UI design.

   **Why this matters:** A relative scale can make the same task shade change from day to day; a fixed scale needs sensible hour thresholds.

   **Answer:** Ok. Decision: use a fixed effort-to-color scale; exact hour thresholds will be set during UI design.
   

