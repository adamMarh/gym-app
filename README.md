# CSEE — Gym Performance Engine

A full-stack gym management app built with **Flutter** (frontend) and **Node.js + TypeScript** (backend). Supports three user roles — client, staff, and admin — each with their own set of features.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Flutter Setup](#flutter-setup)
- [Demo Accounts](#demo-accounts)
- [API Reference](#api-reference)
- [Database](#database)
- [Environment Variables](#environment-variables)

---

## Features

### Client
- View upcoming gym classes and book / cancel spots
- Log workouts with exercises, sets, reps, and weight
- Browse a workout calendar by date
- Post to the community feed, like posts, and comment
- View membership status and profile

### Staff
- Everything a client can do
- Punch clock — punch in and out of shifts
- Submit daily reports with summary and detailed notes

### Admin
- Everything staff can do
- View and manage all members
- Create and delete gym classes
- Review and annotate staff reports
- Moderate the community feed — flag and pin posts

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile / Web frontend | Flutter (Dart) |
| Backend API | Node.js, Express, TypeScript |
| Authentication | JWT (jsonwebtoken) + bcryptjs |
| Database | NoSQL-style flat CSV files |
| State management | Provider (Flutter) |
| HTTP client | `http` package (Flutter) |

---

## Project Structure

```
CSEE/
├── light_client/          # Flutter frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/        # Data classes with fromJson()
│   │   ├── providers/     # State management (API-backed)
│   │   ├── screens/       # UI screens by role
│   │   │   ├── auth/
│   │   │   ├── client/
│   │   │   ├── staff/
│   │   │   └── admin/
│   │   ├── services/      # ApiService singleton (HTTP + token)
│   │   ├── navigation/    # Bottom nav + provider initialisation
│   │   ├── widgets/       # Reusable UI components
│   │   └── theme/         # Colors, text styles, app theme
│   └── pubspec.yaml
│
└── server/                # Node.js backend
    ├── src/
    │   ├── app.ts         # Express entry point
    │   ├── types/         # TypeScript interfaces
    │   ├── middleware/
    │   │   └── auth.ts    # JWT verify + role guard
    │   ├── services/
    │   │   ├── csvService.ts   # CRUD layer over CSV files
    │   │   └── seedService.ts  # Seeds DB with demo data on first boot
    │   └── routes/
    │       ├── auth.ts
    │       ├── users.ts
    │       ├── classes.ts
    │       ├── workouts.ts
    │       ├── feed.ts
    │       └── staff.ts
    ├── DB/                # Auto-created CSV files (gitignored)
    ├── .env
    ├── package.json
    └── tsconfig.json
```

---

## Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Node.js | ≥ 18 |
| npm | ≥ 9 |
| Flutter SDK | ≥ 3.0 |
| Dart SDK | ≥ 3.0 |

---

### Backend Setup

```bash
cd CSEE/server
npm install
npm start
```

The server starts on **http://localhost:3000**.

On first boot it automatically creates the `DB/` folder and seeds all CSV files with demo data. You will see confirmation in the terminal:

```
✔ Seeded users.csv
✔ Seeded class_sessions.csv
✔ Seeded workout_sessions.csv
...
🏋️  CSEE Backend running on http://localhost:3000
```

**Other scripts:**

```bash
npm run dev          # Hot-reload dev mode (nodemon)
npm run build        # Compile TypeScript → dist/
npm run start:prod   # Run compiled JS (after build)
```

---

### Flutter Setup

```bash
cd CSEE/light_client
flutter pub get
flutter run
```

> **Running on a physical device or Android emulator?**
> Open `lib/services/api_service.dart` and update `kBaseUrl`:
>
> ```dart
> // Android emulator
> const String kBaseUrl = 'http://10.0.2.2:3000/api';
>
> // Physical device — use your machine's local IP
> const String kBaseUrl = 'http://192.168.x.x:3000/api';
>
> // iOS simulator / web (default)
> const String kBaseUrl = 'http://localhost:3000/api';
> ```

---

## Demo Accounts

All accounts use the password **`password`**.

| Role | Email |
|---|---|
| Client | alex@example.com |
| Staff | jordan@example.com |
| Admin | sam@example.com |

---

## API Reference

All routes are prefixed with `/api`. Protected routes require the header:
```
Authorization: Bearer <token>
```

### Auth
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/auth/login` | — | Login, returns JWT + user |
| GET | `/auth/me` | ✅ | Get current user |
| PATCH | `/auth/me` | ✅ | Update name / phone |

### Users
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/users` | Admin | List all users |
| GET | `/users/:id` | ✅ | Get user by ID |

### Classes
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/classes` | ✅ | List all classes (with `isBooked` per user) |
| POST | `/classes` | Staff / Admin | Create a class |
| DELETE | `/classes/:id` | Admin | Delete a class |
| POST | `/classes/:id/book` | ✅ | Book a class |
| DELETE | `/classes/:id/book` | ✅ | Cancel a booking |

### Workouts
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/workouts` | ✅ | List user's workouts (with nested exercises) |
| GET | `/workouts/dates` | ✅ | Dates that have at least one workout |
| GET | `/workouts/by-date?date=YYYY-MM-DD` | ✅ | Workouts for a specific date |
| GET | `/workouts/:id` | ✅ | Get single workout |
| POST | `/workouts` | ✅ | Create workout + exercises |

### Feed
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/feed` | ✅ | List posts (pinned first, with `isLiked` + comments) |
| POST | `/feed` | ✅ | Create a post |
| DELETE | `/feed/:id` | ✅ Author / Admin | Delete a post |
| POST | `/feed/:id/like` | ✅ | Toggle like |
| POST | `/feed/:id/flag` | Staff / Admin | Toggle flag |
| POST | `/feed/:id/pin` | Admin | Pin post (unpins all others) |
| GET | `/feed/:id/comments` | ✅ | List comments |
| POST | `/feed/:id/comments` | ✅ | Add a comment |

### Staff
| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/staff/punch/status` | Staff / Admin | Current punch-in status |
| POST | `/staff/punch/in` | Staff / Admin | Punch in |
| POST | `/staff/punch/out` | Staff / Admin | Punch out |
| GET | `/staff/punch/history` | Staff / Admin | Completed punch records |
| GET | `/staff/reports` | Staff / Admin | Reports (staff: own, admin: all) |
| GET | `/staff/reports/unreviewed` | Admin | Pending reports |
| POST | `/staff/reports` | Staff / Admin | Submit a report |
| PATCH | `/staff/reports/:id/review` | Admin | Mark report as reviewed |

---

## Database

The backend uses a lightweight NoSQL-style document store built on flat CSV files. No database server is required. All files live in `server/DB/` and are created automatically on first boot.

| File | Contents |
|---|---|
| `users.csv` | User accounts (hashed passwords) |
| `class_sessions.csv` | Gym class definitions |
| `class_bookings.csv` | User ↔ class booking links |
| `workout_sessions.csv` | Workout session headers |
| `exercises.csv` | Individual exercises (linked to a session) |
| `posts.csv` | Community feed posts |
| `post_likes.csv` | User ↔ post like links |
| `comments.csv` | Post comments |
| `staff_reports.csv` | Daily staff reports |
| `punch_records.csv` | Staff punch clock records |

> The `DB/` folder is gitignored. Each environment generates its own data on first run.

---

## Environment Variables

Create a `.env` file in `server/` (one is included by default):

```env
PORT=3000
JWT_SECRET=your-secret-key-here
```

> ⚠️ Never commit `.env` to version control. Change `JWT_SECRET` to a long random string in any non-development environment.