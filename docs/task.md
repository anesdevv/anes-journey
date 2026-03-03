# Project Milestones: Anes Journey App

## Milestone 1: Project & Infrastructure Setup
- Initialize Flutter project (Android & Web support).
- Set up Supabase backend with Row-Level Security.
- Implement local caching strategy (Hive/SQLite) for offline-first architecture.

## Milestone 2: Core Tracking Modules
- Develop the **Calendar** (monthly/daily views, event creation).
- Implement the **Daily To-Do List** (auto-creation, rollover logic).
- Build the **Goal Tracker** (Yearly/Monthly/Weekly cascading goals).
- Create the **Habit Tracker** (streaks, frequency, bad habits).

## Milestone 3: Specialized Modules
- Build the **Prayer Tracker** (integrate AlAdhan API, local daily caching).
- Develop the **Language Tracker** (study sessions, custom topics, stats).
- Implement the **Journal** (rich text formatting, mood tags, searchable entries).

## Milestone 4: Dashboard & Navigation Framework
- Create the main Bottom Navigation Bar connecting all modules.
- Develop the **Daily Dashboard** (aggregation of all daily metrics).
- Implement the Global Quick-Add Floating Action Button.

## Milestone 5: Notifications & Sync Pipeline
- [x] Initialize flutter_local_notifications and request permissions
- [x] Create NotificationService for scheduling specific alerts (Prayer, To-Do, Habit, Calendar)
- [x] Create SyncService to manage Supabase online/offline cache synchronization
- [x] Integrate NotificationService and SyncService into main.dart

## Milestone 6: UI Polish & Launch Preparation
- [x] Apply global design tokens across the app (typography, colors, radii)
- [x] Add JSON data export functionality in the More menu
- [x] Verify E2E flows locally and polish remaining UI issues
