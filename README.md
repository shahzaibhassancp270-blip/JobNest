# JobNest 🚀
### A Complete Job Search & Application Tracker App

JobNest is a production-ready Flutter application designed to help job seekers find, track, and manage their career opportunities in one place. Built with **Clean Architecture** and **Feature-First** modularity, it offers a seamless experience from job discovery to offer acceptance.

---

## 🌟 Key Features

### 🔍 Live Job Search
- Real-time job listings via **Jsearch API (RapidAPI)**.
- Advanced filtering (Remote, Full-time, Contract).
- Paginated results with shimmer loading states.

### 📋 Kanban Application Tracker
- Horizontal scrollable columns: **Saved → Applied → Interview → Offer → Rejected**.
- Detailed application management (notes, resume links, status updates).
- Drag-and-drop feel with status badges.

### 📊 Advanced Analytics
- **Pie Charts**: Breakdown of application statuses.
- **Bar Charts**: Weekly application activity tracking.
- **Stat Cards**: Total applications, response rates, and offer success rates.

### 🔔 Interview Reminders
- Scheduled local notifications for upcoming interviews.
- Automatic alerts 1 day before and on the day of the interview.

### 🌗 Dark Mode & Premium UI
- Full system-wide dark mode support.
- Modern, glassmorphism-inspired design with a vibrant color palette.
- Responsive layouts for all screen sizes.

---

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Latest Stable)
- **State Management**: [Riverpod](https://riverpod.dev/) (Notifier & AsyncNotifier)
- **Navigation**: [Go Router](https://pub.dev/packages/go_router) (with Auth Guards)
- **Database (Local)**: [Hive](https://pub.dev/packages/hive) (NoSQL storage for offline tracking)
- **Backend/Auth**: [Firebase](https://firebase.google.com/) (Email/Password & Google Sign-In)
- **HTTP Client**: [Dio](https://pub.dev/packages/dio) (with custom interceptors)
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart)
- **Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

## 📂 Project Structure (Feature-First)

The project follows an industry-standard modular structure to ensure scalability:

```text
lib/
├── core/               # Shared theme, constants, and global widgets
├── features/           # Modular features
│   ├── auth/           # Login, Register, Forgot Password
│   ├── home/           # Job Search & Details
│   ├── tracker/        # Kanban Board & Application Details
│   ├── analytics/      # Performance charts & stats
│   └── profile/        # Settings & Theme Toggle
├── routing/            # GoRouter configuration
└── main.dart           # App entry point & initialization
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- A RapidAPI account (for Jsearch API)
- A Firebase project

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/jobnest.git
   cd jobnest
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## ⚙️ Required Configuration (Action Needed from You)

To make this app fully functional, you need to provide the following:

1. **RapidAPI Key**:
   - Go to [Jsearch API on RapidAPI](https://rapidapi.com/letscrape-6s7964ad9ay/api/jsearch/).
   - Get your API Key.
   - Replace the placeholder in `lib/core/constants/api_keys.dart`.

2. **Firebase Setup**:
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Run `flutterfire configure` to generate your `firebase_options.dart`.
   - Enable **Email/Password** and **Google** sign-in methods in the Authentication tab.

3. **Google Sign-In**:
   - For Android: Add your `SHA-1` certificate fingerprint to the Firebase project settings.
   - For iOS: Download and add the `GoogleService-Info.plist`.

---

## 📝 License
This project is licensed under the MIT License - see the LICENSE file for details.
