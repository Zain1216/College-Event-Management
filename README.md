# 🎓 FusionFiesta - Cross-Platform College Event Management System

![FusionFiesta Banner](assets/images/logo.jpg)

> **TechWiz 6 - Aptech Global Tech Competition Project Submission**  
> An end-to-end, multi-role cross-platform application developed in Flutter with pure Google Firebase cloud architecture.

---

## 🎨 Visual Identity & Strict Color Directive
- **Strict Color Constraint**: **NO PURPLE / VIOLET / MAGENTA / INDIGO** anywhere in the application.
- **Theme Palette**:
  - 🔵 **Primary**: Sapphire Blue (`#2563EB`)
  - 🌌 **Deep Navy**: Midnight Slate (`#0F172A`)
  - 🔷 **Secondary Accent**: Electric Cyan (`#06B6D4`)
  - 🟢 **Live Status / Turnout**: Emerald Green (`#10B981`)
  - 🟡 **Medals & Trophies**: Amber Gold (`#F59E0B`)

---

## 👥 4 User Roles & Test Credentials

The application is pre-seeded with 4 test user accounts and includes a **1-tap Instant Role Switcher** on the login screen for rapid evaluation:

| Role | Email Address | Password | Full Name | Department | Key Capabilities |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **🛡️ System Admin** | `admin@fusionfiesta.edu` | `Admin@123` | Dr. Arthur Vance | Dean Academic Affairs | Approve/decline event proposals, manage user roles & approvals, security alerts, on-demand PDF & Excel export, content moderation. |
| **📋 Event Organizer** | `organizer@fusionfiesta.edu` | `Org@123` | Prof. Elena Rostova | Computer Science | Propose events with guideline PDFs, live QR attendance scanner, winner designation, bulk e-certificates, broadcast alerts. |
| **🎓 Student Participant** | `student@fusionfiesta.edu` | `Student@123` | Zain Ahmed | Computer Science (CS-2023-089) | 1-click event registration, encrypted QR passes, certificate vault with fee clearance, vector PDF download, 4-criteria feedback. |
| **👀 Student Visitor** | `visitor@fusionfiesta.edu` | `Visitor@123` | Rohan Verma | Mechanical Eng. | Browse event catalog, search with auto-suggestions, campus map GPS navigation, 1-tap upgrade to Participant. |

---

## 🚀 Key Features Implemented (SRS Conformance)

### 1. 🏠 Student Experience & Event Discovery
- **Visual Sitemap & Onboarding Flowchart**: Direct roadmap button on the home screen providing a visual walkthrough of all app capabilities (mandated on SRS Page 14).
- **Global Search & Filter**: Real-time fuzzy keyword search, tag filtering, auto-complete suggestions, and category chips (Technical, Cultural, Sports, Seminar, Workshop).
- **Event Spotlight Carousel & Slot Counter**: Visual progress bar showing remaining seats in real time.
- **Rules & Guidelines Preview**: PDF view and download for official event rulebooks.

### 2. 🎟️ 1-Click Registration & Digital QR Entry Passes
- **Instant Registration**: One-touch booking for verified participants with automatic seat limit validation.
- **Pass QR Code**: High-resolution QR ticket generation (`qr_flutter`) containing tamper-resistant student and event credentials for gate check-in.
- **Registration Management**: View upcoming passes and cancel bookings before deadlines.

### 3. 📷 Live QR Attendance Scanner (Organizer Suite)
- **Animated Scanner Viewfinder**: Live camera check-in mode with animated laser tracking.
- **Instant QR Verification**: Validates registration status and prevents duplicate check-ins.
- **Manual Roster Fallback**: Searchable participant roster for manual check-ins.

### 4. 🏆 Winner Designations & E-Certificate Vault
- **Winner Badges**: Designate 1st, 2nd, and 3rd place winners with automated certificate generation.
- **Certificate Fee Gateway**: Simulated Card/UPI/Wallet checkout to clear certificate processing fees (`$50.00`) per SRS Section 1.4 & 1.6 #6.
- **Official Vector PDF Generator**: Generates high-resolution certificates with college crest, verification QR code, and signatures using `pdf` and `printing`.

### 5. ⭐ Multi-Criteria 5-Star Feedback System
- **4 Evaluation Parameters**: Organization, Relevance, Coordination, and Overall Experience (SRS Section 1.6 #9).
- **Spam / Abuse Flagging**: Automatic and administrative moderation tools.

### 6. 🗺️ Interactive Campus Map & Venues
- **OpenStreetMap Integration**: Interactive map (`flutter_map` & `latlong2`) with pins for campus venues (Innovation Hub, Computing Arena, Open Air Amphitheatre, Sports Complex, Robotics Arena).
- **GPS Route Guidance**: One-click route directions to event halls.

### 7. 📊 Administrative Governance & Report Center
- **Proposal Review Workflow**: Admin approval or rejection with feedback reasons.
- **User Account Management**: Activate/deactivate accounts, approve staff signups, and toggle roles.
- **On-Demand Exports**: Generates print-ready executive **PDF reports** and **Excel `.xlsx` spreadsheets** (`excel` package) with multi-sheet statistics.

---

## 🗄️ Pure Firebase Architecture (Zero SQL)

- **Database**: Cloud Firestore with 9 collections (`users`, `events`, `registrations`, `attendance`, `feedback`, `certificates`, `media_gallery`, `notifications`, `contact_queries`).
- **Security**: Granular Role-Based Access Control (`firestore.rules` and `storage.rules`).
- **Offline Persistence**: Local cache synchronization for high resilience during campus network drops.

---

## 🛠️ Installation & Running the Project

### Prerequisites
- Flutter SDK (version 3.2.0 or higher)
- Google Chrome or Android Studio

### Steps
```bash
# 1. Clone repository and navigate to directory
cd "College Event Management"

# 2. Install all Flutter dependencies
flutter pub get

# 3. Run application on Web (Google Chrome)
flutter run -d chrome

# 4. Run application on Android
flutter run -d android

# 5. Build production Release Android APK
flutter build apk --release
```

---

## 📁 Repository Structure
```
College Event Management/
├── assets/
│   ├── images/
│   │   └── logo.jpg               # Official Sapphire Blue/Cyan Logo
│   └── sample_data/
│       └── firebase_seed_data.json# Bundled initial database
├── database/
│   ├── firebase_seed_data.json    # Firestore seed dataset
│   └── schema.sql                 # SQL reference definition
├── documentation/
│   └── ReadMe.doc                 # Official TechWiz 6 doc file
├── lib/
│   ├── models/                    # Domain models with enhanced enums
│   ├── providers/                 # State management & reactive business logic
│   ├── screens/
│   │   ├── admin/                 # Approvals, user management, reports, moderation
│   │   ├── auth/                  # Login, registration, role selection
│   │   ├── common/                # Catalog, media gallery, campus map, about, contact, profile
│   │   ├── organizer/             # Dashboard, event create/edit, QR scanner, results
│   │   ├── sitemap/               # Visual flowchart roadmap
│   │   └── student/               # Dashboard, event details, my passes, certificate vault
│   ├── services/                  # Firebase DataStore, PDF generator, Excel exporter, QR service
│   ├── theme/                     # AppTheme (Sapphire/Cyan palette - no purple)
│   └── main.dart                  # MultiProvider bootstrap entrypoint
├── firebase.json                  # Firebase configuration
├── firestore.rules                # RBAC Firestore Security Rules
├── storage.rules                  # Firebase Storage Security Rules
├── firestore.indexes.json         # Firestore index optimizations
└── pubspec.yaml                   # 70+ verified dependencies
```
