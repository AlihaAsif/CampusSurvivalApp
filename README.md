# Campus Survival

An all-in-one companion app for university students in Pakistan. Ten features, one question running through all of them: **how much room do I have left?** How many classes can I still miss, how many days until this is due, how many rupees are left this month.

Built with Flutter, Riverpod and Firebase, following Clean Architecture.

---

## Features

| Feature | What it does |
|---|---|
| **Smart Dashboard** | Next class with a live countdown, today's schedule, deadlines, attendance and budget at a glance |
| **Smart Timetable** | Manual entry plus import from a PDF or a photo of the department timetable |
| **Assignments** | Deadlines with calendar-accurate due badges, priorities and filters |
| **Attendance Tracker** | Percentage per subject, safe-skip count, recovery target, class-by-class register |
| **Expense Tracker** | Monthly budget, daily allowance, category donut and a seven-day bar chart |
| **Study Planner** | Weekly hour goals per subject, planned sessions and a daily streak |
| **Announcements** | Campus notices with per-student read state and an unread badge |
| **Lost & Found** | Photo posts with author-only editing |
| **Campus Map** | Buildings pinned on OpenStreetMap, searchable, directions handed off to Google Maps |
| **AI Assistant** | Gemini chat that answers using the student's own timetable, attendance and spending |

---

## Tech stack

- **Flutter** (Material 3) + **Riverpod** — `StreamProvider` over Firestore, derived providers for everything computed
- **Firebase** — Auth (email/password with verification) and Cloud Firestore
- **Supabase Storage** — images for Lost & Found
- **ML Kit** + **Syncfusion PDF** — on-device timetable reading
- **flutter_map** + OpenStreetMap — campus map, no billing account needed
- **fl_chart** — expense charts
- **Gemini** — AI assistant

---

## Architecture

Every feature is split three ways:

```
lib/features/<feature>/
├── domain/          plain Dart — models and an abstract repository
├── data/            the implementation (Firestore, Supabase, ML Kit)
└── presentation/    screens and Riverpod providers
```

The rule that holds it together: **`domain/` imports nothing.** Not Flutter, not Firebase. The attendance formula is arithmetic — it has no business knowing where the data came from, which makes it testable in milliseconds and the backend swappable.

Screens depend on the abstract `AuthRepository`, never on `FirebaseAuthRepository`.

---

## A few decisions worth explaining

**Nothing computed is ever stored.** Attendance percentages, monthly totals, unread counts, study hours — all derived from the base collections on every read. A stored total drifts out of sync with the records it summarises; a derived one cannot.

**Money is `int`, never `double`.** Rupee amounts have no fractional part, and floats will eventually produce `Rs 16,429.999999` in a total somewhere.

**Time of day is minutes from midnight.** `08:30` is stored as `510` — sorting is an integer compare, duration is subtraction, and no timezone enters the picture.

**Due dates compare calendar days, not elapsed hours.** An assignment due at 11:59 PM tonight reads "Due today", not "in 4 hours". Without stripping the time first, something due tomorrow morning shows as due today.

**One ticker, not one per widget.** A single 30-second stream drives the countdown, the "Now" badge and the live class highlight. Per-second rebuilds of the whole dashboard are wasteful and nobody can tell the difference.

**PDFs are read, photos are OCR'd.** A digital PDF already holds its text — rasterising it and running OCR over the image only adds mistakes. Photos have no text layer, so those go through ML Kit, with the recognised blocks re-clustered by bounding box so a table row lands on one line.

**The timetable import review step is not optional.** Parsing is never perfect, and a silently wrong timetable corrupts attendance and dashboard data downstream. Nothing is written until the student confirms what was detected.

---

## Getting started

**Prerequisites:** Flutter 3.22+, a Firebase project, a Supabase project, and a Gemini API key from [Google AI Studio](https://aistudio.google.com/apikey).

```bash
git clone https://github.com/<you>/campus-survival.git
cd campus-survival
flutter pub get
```

**Firebase** — enable Auth (Email/Password) and Firestore, then:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Firestore rules: users read and write only under their own `users/{uid}`; `announcements` are read-only; `lostItems` are writable only by their author.

**Supabase** — create a public bucket named `lost-items` with `SELECT` and `INSERT` policies on `bucket_id = 'lost-items'`.

**Config** — copy the examples and fill in your own values (both are gitignored):

```bash
cp lib/core/config/supabase_config.example.dart lib/core/config/supabase_config.dart
cp lib/core/config/gemini_config.example.dart lib/core/config/gemini_config.dart
```

**Android** — set `compileSdk = 36` and `minSdk = 23` in `android/app/build.gradle.kts`.

```bash
flutter run
```

Building coordinates are hand-entered in `lib/features/map/data/campus_places.dart` — no public API knows where your university's library is. Right-click any building in Google Maps to copy its coordinates.

---

## Known limitations

- **Timetable import expects one class per line.** Grid-style sheets carrying every section of the campus lose their row structure when text is extracted, so the parser cannot tell which subject belongs to which section.
- **The Gemini key ships in the client.** Fine for a portfolio build; a published app would move the call behind a Cloud Function.
- **Chat history is in-memory** and resets when the assistant closes.
- **Single campus** — places, sections and the 75% attendance requirement are built around one university.

---

Map data © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors.

