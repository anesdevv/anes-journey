# Anes Journey — PRD

## Summary

A personal life-management app for a single user (Anes) — Muslim, learning German for Ausbildung. Replaces a fragmented mental system with one black-and-red Flutter app (Android + Web) that unifies daily tracking across prayers, habits, goals, tasks, language learning, calendar, and journaling. The home screen is a daily dashboard showing today's health at a glance.

---

## Problem

User tracks everything in his head. Things slip. No single tool covers Islamic prayer tracking + German learning + goal/habit tracking in one cohesive place.

---

## Platform & Tech

- Flutter (Android + Web)
- Single user, no auth needed (local-first, optional cloud sync via Supabase or Firebase later)
- Colors: Black background, Red accent

---

## Modules

### 1. Daily Dashboard (Home Screen)

The default screen. Aggregates today's data from all modules.

**Shows:**
- Today's 5 prayers status (on-time / missed / not yet)
- Today's to-do completion (X/Y done)
- Active habits streak summary
- Active weekly/monthly goal progress bars
- German learning — today's study time vs. daily target
- Quick-add button (floating action button) → opens modal to pick which module to add to

---

### 2. Calendar

- Create events with title, date, time, optional notes
- Set reminders (push notification) — single or repeating
- View: monthly + daily agenda view
- Color-coded by module type (e.g. red for personal, gray for other)

---

### 3. Daily To-Do List

- New list auto-created each day
- Add tasks with optional time and priority
- Check off tasks
- Uncompleted tasks can be rolled over to next day or dismissed
- No subtasks (keep it simple)

---

### 4. Goal Tracker

**Goal levels:** Year → Month → Week

- Create a goal at any level with a title and optional description
- Mark progress manually (percentage slider or done/not done)
- Goals cascade visually: weekly goals nest under monthly, monthly under yearly
- Dashboard shows active goals with progress bars
- Archive completed goals

---

### 5. Habit Tracker

- Create a habit with: name, frequency (daily / specific days), optional target count per day
- Mark each day: done / skipped / missed
- Track streak (current + longest)
- Track "bad habits" separately — same structure but framed as "days clean"
- Weekly summary view (grid of days vs. habits)

---

### 6. Prayer Tracker

**Prayer Times API: AlAdhan (free, no API key required)**
- Endpoint: `https://api.aladhan.com/v1/timingsByCity?city=Tlemcen&country=Algeria&method=19`
- Method 19 = Algerian Ministry of Religious Affairs (most accurate for Algeria)
- Fetch once daily, cache locally + in Supabase — no repeated calls
- Times auto-update daily at midnight

**Tracking:**
- 5 daily prayers: Fajr, Dhuhr, Asr, Maghrib, Isha
- Each prayer shows exact time pulled from API
- Each prayer logged as: ✅ On time | ⚠️ Late/Qada | ❌ Missed
- Push notification at each prayer time as reminder
- Auto-resets each day at midnight

**Views & Stats:**
- Monthly grid: each prayer per day color-coded
- Stats: on-time rate per prayer, overall monthly score

---

### 7. Language Tracker (German / Ausbildung)

**Study Sessions:**
- Log a session: duration (manual input), source (Duolingo / Book / YouTube / Custom)
- Custom sources can be added by user

**Custom Topics:**
- User creates topics (e.g. "Accusative Case", "Job Vocabulary")
- Log progress per topic: Not started / In progress / Mastered
- Add notes per topic

**Stats:**
- Total hours studied (weekly / monthly / all-time)
- Duolingo streak (manual input — no API)
- Topics mastered count

---

### 8. Journal

- Daily entry linked to today's date
- Free-text input (rich text: bold, italic, bullet list minimum)
- Optional mood tag: 😊 😐 😔 (3 options, simple)
- Searchable by keyword
- Calendar view to see which days have entries
- Entries are private (no sharing)

---

## Navigation Structure

```
Bottom Nav Bar (5 items):
├── Home (Dashboard)
├── Calendar
├── To-Do
├── Tracker (Prayer + Habit + Goal — tabbed)
└── More (Journal + Language + Settings)
```

---

## Notifications

- Prayer reminders: user sets custom time per prayer
- To-do reminders: per-task if time is set
- Habit reminders: daily nudge at user-defined time
- Calendar event reminders: per-event

All notifications handled via Flutter Local Notifications package.

---

## Data & Storage

- **Supabase** as backend (Postgres + Realtime sync)
- Local cache (Hive or SQLite) for offline support — syncs when back online
- Single user: one hardcoded Supabase account (no public auth/signup)
- All modules store data in Supabase, real-time sync across Android + Web
- Row-level security enabled (user_id scoped) even for single user — good practice
- Export to JSON (backup) — nice to have in v1


---

## Key Screens

| Screen | Core Action |
|---|---|
| Dashboard | See today, quick-add |
| Calendar | Add/view events + reminders |
| To-Do | Daily task list |
| Prayer Tracker | Log each prayer status |
| Habit Tracker | Check off habits, see streaks |
| Goal Tracker | View/update year-month-week goals |
| Language Tracker | Log session, manage topics |
| Journal | Write daily entry |

---

## Design Tokens

| Token | Value |
|---|---|
| Background | #000000 |
| Surface | #111111 |
| Accent | #E53935 (Red 600) |
| Text Primary | #FFFFFF |
| Text Secondary | #9E9E9E |
| Font | Inter or Poppins |
| Border Radius | 12px |