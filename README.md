# SkillPath — Career Roadmap & Coding Progress Platform

> **Tagline:** Your roadmap from learning to landing a software engineering role.

SkillPath is a modern, production-quality full-stack mobile application that combines structured personalized career roadmaps, a comprehensive DSA progress tracker with spaced repetition revision scheduling, a hands-on project learning hub with resume bullet point generation, and technical/behavioral interview preparation into one unified platform.

---

## 🚀 Key Features

### 1. Personalized Career Roadmaps
- **Curated Multi-Role Roadmaps:** Software Development Engineer (SDE), Flutter Developer, Frontend Developer, Backend Developer, and Full-Stack Developer.
- **Stage & Topic Breakdown:** Stages organized into topics with estimated study hours and difficulty indicators.
- **Prerequisite Unlocking Engine:** Dependent topics automatically unlock as earlier foundational prerequisites are completed.
- **Curated Learning Resources:** Attached high-quality articles, videos, and documentation for each topic with bookmarking support.

### 2. Comprehensive DSA Progress Tracker
- **Spaced Repetition Scheduler:** Automatically schedules problem revisions (e.g., 3, 7, 14, 30 days) to prevent forgetting.
- **Problem Management:** Track problem title, URL, platform (LeetCode, Codeforces, GeeksforGeeks, HackerRank), topic, and difficulty.
- **Intuition & Mistakes Journal:** Record solution approaches, edge-case mistakes, and key observations for each problem.
- **Real-Time Analytics:** Problem breakdown (Easy, Medium, Hard), total unique problems solved, weekly activity charts, and weak topic identification.

### 3. Project Learning Hub
- **Production-Grade Project Guides:** Complete step-by-step implementation plans for real-world projects (Task Management, Expense Tracker, E-Commerce, Real-Time Chat, DSA Visualizer).
- **Interactive Milestone Checklists:** Check off milestones to dynamically advance overall project progress.
- **Portfolio Repository & Live Deployment Tracking:** Save GitHub URLs and live demo links.
- **Verified Resume Bullet Point Generator:** Automatically generates tailored, verified resume bullet points based on completed milestones and actual technologies without hallucinating metrics.

### 4. Consolidated Smart Dashboard
- **Rule-Based Recommendations:** Intelligently recommends the highest-priority action based on actual progress (e.g. revision due today, incomplete roadmap prerequisite, next project milestone).
- **Coding Streak Counter:** Tracks consecutive days of activity.
- **Weekly Learning Activity Chart:** Interactive bar chart visualizing the past 7 days of problem solving and topic mastery.

### 5. Interview Preparation & Career Tools
- **Technical & Behavioral Question Bank:** Categorized questions by topic, category, and difficulty, tagged with hiring company tags (Amazon, Google, Meta, Microsoft).
- **Interview Readiness Checklist:** Verifies topic milestones, DSA volume, and project completion.
- **STAR Story & Answer Notes:** Draft and save structured interview responses.

---

## 🛠️ Technology Stack

### Mobile Frontend
- **Framework:** Flutter 3.44.8 (Dart 3.12.2)
- **UI Architecture:** Material 3 Design System with custom dark & light themes
- **State Management:** Riverpod 3.x (`flutter_riverpod`, `NotifierProvider`)
- **Navigation:** GoRouter 17.x with `StatefulShellRoute` for persistent bottom navigation
- **HTTP Client:** Dio 5.x with automatic JWT attachment and refresh token interceptors
- **Typography:** Google Fonts (`Inter`)
- **Data Visualization:** `fl_chart`

### Backend
- **Runtime:** Node.js v22.x
- **Framework:** Express.js
- **Database:** MongoDB Atlas / Local MongoDB (Mongoose ODM)
- **Authentication:** JWT (Access Token + Refresh Token), bcrypt password hashing
- **Security:** Rate limiting (`express-rate-limit`), CORS, environment variable isolation

---

## 📁 Repository Structure

```
├── lib/
│   ├── app/
│   │   ├── app.dart                   # Root MaterialApp with theme & router
│   │   ├── router.dart                # GoRouter configuration & shell branches
│   │   ├── scaffold_with_nav_bar.dart # Persistent 5-tab Material 3 navigation
│   │   └── theme/                     # Colors, typography, and light/dark theme data
│   ├── core/
│   │   ├── constants/                 # API routes & app configuration constants
│   │   ├── errors/                    # AppFailure, NetworkFailure, ServerFailure
│   │   ├── network/                   # Dio ApiClient with token refresh interceptors
│   │   ├── storage/                   # TokenStorage & LocalStorage
│   │   └── widgets/                   # Reusable UI components (AppButton, AppCard, etc.)
│   └── features/
│       ├── auth/                      # Login, Register, Forgot Password, AuthNotifier
│       ├── onboarding/                # Multi-step Career Goal & Skill Onboarding
│       ├── dashboard/                 # Analytics, Recommendations, Weekly Chart
│       ├── roadmaps/                  # Stage & topic progression, unlock logic
│       ├── dsa/                       # Manual & catalog tracking, revision queue
│       ├── projects/                  # Catalog, milestone checklist, resume generator
│       ├── interview/                 # Technical & behavioral QA, readiness check
│       └── profile/                   # User profile settings & Dark Mode toggle
├── server/
│   ├── scripts/
│   │   └── seed.js                    # Rich database seeder with roadmaps, DSA, and projects
│   ├── src/
│   │   ├── config/                    # MongoDB connection
│   │   ├── controllers/               # Auth, Roadmap, DSA, Project, Dashboard controllers
│   │   ├── middleware/                # JWT protect, error handler, rate limiter
│   │   ├── models/                    # Mongoose schemas with indexes & constraints
│   │   ├── routes/                    # Express REST endpoints
│   │   ├── services/                  # Analytics, recommendation engine, resume generator
│   │   ├── app.js                     # Express app setup
│   │   └── server.js                  # Server entry point
│   ├── tests/
│   │   └── api.test.js                # Automated backend integration tests
│   ├── .env.example                   # Environment configuration template
│   └── package.json
└── README.md
```

---

## ⚡ Getting Started

### Prerequisites
- Flutter SDK (>= 3.44.8)
- Node.js (>= 18.x) & npm
- MongoDB running locally on port 27017 or a MongoDB Atlas URI

---

### 1. Backend Setup

1. Open a terminal in the `server` directory:
   ```bash
   cd server
   npm install
   ```

2. Copy the environment variables template:
   ```bash
   cp .env.example .env
   ```

3. Populate the database with realistic sample curriculum and demo data:
   ```bash
   npm run seed
   ```

4. Start the backend server:
   ```bash
   npm run dev
   # Server will start on http://localhost:5000
   ```

5. Run automated backend tests:
   ```bash
   npm test
   ```

---

### 2. Frontend Setup (Flutter)

1. Return to the root workspace directory:
   ```bash
   flutter pub get
   ```

2. Run the application:
   - **For Chrome / Web:**
     ```bash
     flutter run -d chrome
     ```
   - **For Windows Desktop:**
     ```bash
     flutter run -d windows
     ```

---

## 🔑 Demo Account

For rapid evaluation and testing, the database seed script includes a pre-configured account with active roadmap progress, tracked DSA problems, and in-progress project milestones:

| Credential | Value |
|---|---|
| **Email** | `demo@skillpath.dev` |
| **Password** | `Password123!` |

*(On the Login screen, click the **"Fill Demo"** button to auto-fill these credentials with a single tap!)*

---

## 📡 Key API Endpoints

### Authentication
- `POST /api/auth/register` — Create account with initial target role
- `POST /api/auth/login` — Sign in and receive access/refresh tokens
- `POST /api/auth/refresh` — Refresh access token
- `GET /api/auth/me` — Retrieve current user profile
- `PUT /api/auth/profile` — Update role, study goal, and onboarding state

### Roadmaps
- `GET /api/roadmaps` — List all available career roadmaps
- `GET /api/roadmaps/:id` — Get specific roadmap curriculum
- `GET /api/users/me/roadmap` — Get active roadmap with computed topic unlock states
- `PUT /api/users/me/roadmap/progress` — Mark topics completed or in-progress

### DSA Progress Tracker
- `GET /api/problems` — Browse curated catalog problems
- `GET /api/users/me/problems` — Get user's tracked problems and analytics
- `POST /api/users/me/problems` — Add custom or catalog problem
- `PUT /api/users/me/problems/:id` — Update status, notes, or reschedule revision
- `GET /api/users/me/revisions` — Get problems due for spaced repetition

### Project Learning Hub
- `GET /api/projects` — Catalog projects filtered by domain and difficulty
- `GET /api/projects/:id` — Project details with step-by-step guides and milestones
- `GET /api/users/me/projects` — Get user's active and saved projects
- `PUT /api/users/me/projects/:id` — Check off milestones and save repo links
- `POST /api/users/me/projects/:id/resume-bullets` — Generate verified resume bullets

### Consolidated Dashboard
- `GET /api/users/me/dashboard` — Unified summary of roadmap, streak, DSA, weekly chart, and rule-based recommendations
- `GET /api/users/me/analytics` — Detailed user activity breakdown

### Interview Preparation
- `GET /api/interview-questions` — Technical and behavioral QA bank
- `PUT /api/users/me/interview-progress/:id` — Mark question practiced and save answer notes

---

## ☁️ Deployment

**1. Backend (Render, free tier works)**
1. Create a free MongoDB Atlas cluster and copy its connection string.
2. On [Render](https://render.com) choose *New > Blueprint*, select this repo (it reads `render.yaml`), and set `MONGODB_URI`.
3. After deploy, seed demo data once from the Render shell: `npm run seed`.
4. Note the URL, e.g. `https://skillpath-api.onrender.com`. A `server/Dockerfile` is also provided for any container host.

**2. Frontend (GitHub Pages via Actions)**
1. In the GitHub repo: *Settings > Pages > Source: GitHub Actions*.
2. *Settings > Secrets and variables > Actions > Variables*: add `API_BASE_URL` = `https://<your-render-app>.onrender.com/api`.
3. Push to `main`; `.github/workflows/deploy-web.yml` builds and publishes to `https://saivardhan-7.github.io/SkillPath/`.

Local builds can point at any backend with `--dart-define=API_BASE_URL=<url>`. Set `CORS_ORIGIN` on the backend to your Pages origin.

---

## 🔒 Security Best Practices
- Passwords securely hashed with `bcryptjs`.
- Sensitive tokens stored in encrypted platform storage (`FlutterSecureStorage`).
- Centralized error handler masks stack traces in production mode.
- Rate limiting applied to authentication endpoints to prevent brute-force attacks.
- Strict authorization guarantees users can only access and modify their own records.
