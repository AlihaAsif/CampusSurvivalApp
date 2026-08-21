# Campus Survival

A simple **all-in-one companion app for university students in Pakistan**.

Campus Survival helps students keep track of their **classes, attendance, assignments, expenses, study time, campus announcements and important locations** — all in one place.

Built with **Flutter, Riverpod and Firebase** using **Clean Architecture**.

---

## Features

| Feature                | What it does                                                                               |
| ---------------------- | ------------------------------------------------------------------------------------------ |
| **Smart Dashboard**    | Shows your next class, countdown, today's schedule, deadlines, attendance and budget       |
| **Smart Timetable**    | Add classes manually or import a timetable from a PDF or photo                             |
| **Assignments**        | Add assignments, set deadlines, priorities and filter them                                 |
| **Attendance Tracker** | Track attendance for each subject and see how many classes you can safely miss             |
| **Expense Tracker**    | Set a monthly budget and track daily expenses by category                                  |
| **Study Planner**      | Set weekly study goals, plan study sessions and maintain a daily streak                    |
| **Announcements**      | View campus announcements and track which ones you have read                               |
| **Lost & Found**       | Post lost or found items with photos                                                       |
| **Campus Map**         | Find important campus buildings using OpenStreetMap and get directions through Google Maps |
| **AI Assistant**       | Chat with Gemini and get answers based on your timetable, attendance and expenses          |

---

## Tech Stack

* **Flutter** — Mobile app development
* **Riverpod** — State management
* **Firebase Authentication** — User login and registration
* **Cloud Firestore** — Store user and campus data
* **Supabase Storage** — Store Lost & Found images
* **ML Kit** — Read timetable information from photos
* **Syncfusion PDF** — Extract text from PDF timetables
* **flutter_map + OpenStreetMap** — Campus map
* **fl_chart** — Expense charts
* **Gemini AI** — AI Assistant

---

## Project Architecture

The project follows **Clean Architecture**.

Each feature is divided into three parts:

```text
lib/features/<feature>/
├── domain/
│   ├── models
│   └── repositories
│
├── data/
│   └── repository implementations
│
└── presentation/
    ├── screens
    └── providers
```

### Why this structure?

* **Domain** contains the main business logic.
* **Data** handles Firebase, Supabase and other external services.
* **Presentation** contains the UI and Riverpod providers.

This keeps the code organized and makes it easier to **test, maintain and update** the app.

---

## Important Design Decisions

### 1. Calculated data is not stored

Things like:

* Attendance percentage
* Monthly expenses
* Unread announcements
* Study hours

are calculated from the original data instead of being stored separately.

This prevents totals from becoming incorrect when the original records change.

### 2. Money is stored as integers

Expenses are stored as `int` values because Pakistani rupee amounts normally don't need decimal values.

For example:

```text
16429
```

instead of:

```text
16429.999999
```

### 3. Time is stored as minutes

Instead of storing `08:30` as a string, it is stored as:

```text
510 minutes
```

This makes sorting and calculating class durations easier.

### 4. Due dates use calendar days

The app checks the **date**, not the exact number of hours remaining.

For example, an assignment due tonight shows:

```text
Due today
```

instead of:

```text
Due in 4 hours
```

### 5. One timer for the dashboard

A single timer updates the dashboard countdown and class status instead of creating separate timers for every widget.

### 6. PDF and photo timetables are handled differently

* **PDF:** Text is extracted directly from the PDF.
* **Photo:** ML Kit is used to recognize the text.

The detected timetable is shown to the student for **review and confirmation before saving**.

This is important because automatic timetable detection may not always be perfect.

---

## Campus Map

The campus map uses **OpenStreetMap** through `flutter_map`.

OpenStreetMap provides the map data, but it does not automatically know where every university building is located.

Therefore, important campus places such as:

* CS Department
* Library
* Cafeteria
* Administration Block
* Labs

are added manually with their coordinates.

The coordinates are stored in:

```text
lib/features/map/data/campus_places.dart
```

Students can search for a building and then open directions in Google Maps.

---

## Getting Started

### Requirements

Before running the project, you need:

* Flutter 3.22+
* Firebase project
* Supabase project
* Gemini API key

### Installation

Clone the repository:

```bash
git clone https://github.com/AlihaAsif/CampusSurvivalApp.git
cd CampusSurvivalApp
flutter pub get
```

### Firebase

Enable:

* Firebase Authentication
* Email/Password authentication
* Cloud Firestore

Then configure Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### Supabase

Create a storage bucket named:

```text
lost-items
```

and configure the required storage policies.

### Gemini

Create a Gemini API key and add it to the project's configuration file.

### Run the App

```bash
flutter run
```

---

## Known Limitations

* Timetable import works best when there is **one class per line**.
* The Gemini API key is currently stored in the client, which is acceptable for a portfolio project but should be moved to a backend for a production app.
* AI chat history is currently stored only in memory.
* The app is currently designed for **one university campus**.
* Campus buildings and locations are manually added.
* The attendance requirement is currently based on a **75% requirement**.

---

## License

This project is created as a portfolio project.

Map data © OpenStreetMap contributors.
