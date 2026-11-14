
# 🎓 CampusConnect

> A modern, full-stack cross-platform university management application built with **Flutter** and **Laravel**, designed to streamline academic workflows for both students and teachers with a sleek, professional UI/UX.

---

## 📱 Screenshots & Preview

<div align="center">
  <img src="frontend/assets/campus_connect_logo.png" width="120" alt="CampusConnect Logo">
  <p><em>Empowering academic connectivity through seamless digital experiences.</em></p>
</div>

---

## ✨ Key Features

### 👨‍🏫 Teacher Dashboard
* **Smart Student Grading**: Filter by course and group, then seamlessly input or update CC and Control grades with instant backend synchronization.
* **Digital Course Library**: Upload PDFs and course images via an intuitive drop-zone style interface, preview media, and manage materials on the fly.
* **Group Progress Ledger**: View alphabetically sorted student rosters with real-time search, color-coded attendance warnings, and detailed academic stats.

### 🎓 Student Dashboard
* **Interactive Student ID Card**: Features a 3D hover tilt effect and a tap-to-flip animation revealing a verification QR code on the back.
* **Academic Ledger & Grades**: Clean, responsive table layouts calculating weighted semester averages (`CC * 0.3 + Control * 0.7`) with dynamic pass/fail status badges.
* **Visual Attendance Tracker**: 16-week matrix grid visualization (`8x2` cube layout) clearly indicating attended vs. missed sessions per course.
* **Schedule & Course Material Viewer**: Pinch-to-zoom interactive schedule viewer and downloadable course documents.
* **Profile & Customization**: Manage personal information (Date of Birth, Place of Birth, Sex) and update avatar pictures directly from the mobile app.

---

## 🛠️ Tech Stack

* **Frontend**: Flutter (Dart), Google Fonts (Poppins), Salomon Bottom Bar, File Picker, URL Launcher.
* **Backend**: Laravel REST API (PHP).
* **Database**: MySQL (hosted locally via XAMPP).
* **Authentication**: Token-based Bearer Authentication (`Sanctum` / API tokens).

---

## 🚀 Getting Started Locally

Follow these instructions to set up and run the full stack on your local machine.

### Prerequisites
* Flutter SDK installed on your machine.
* PHP & Composer installed.
* XAMPP (or any local MySQL server).

### 1. Database Setup (XAMPP / MySQL)
1. Start **MySQL** from your XAMPP Control Panel.
2. Open `http://localhost/phpmyadmin` in your browser.
3. Create a new database named `campus_connect`.

### 2. Backend Setup (Laravel API)
1. Navigate to your backend directory and open your terminal.
2. Verify your database credentials in the `.env` file:
   ```env
   DB_DATABASE=campus_connect
   DB_USERNAME=root
   DB_PASSWORD=
   ```
3. Run migrations and seeders to populate initial student, teacher, and admin accounts:
   ```bash
   php artisan migrate
   php artisan db:seed
   ```
4. Find your computer's local IPv4 address (run `ipconfig` on Windows or `ifconfig` on Mac/Linux).
5. Start the Laravel development server bound to your local network IP:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

### 3. Frontend Setup (Flutter App)
1. Open your Flutter project directory.
2. Open `lib/globals.dart` and update the `serverIP` variable to match your computer's local IPv4 address:
   ```dart
   library frontend.globals;

   String serverIP = "YOUR_PC_LOCAL_IP"; // e.g., "192.168.1.15"
   String userToken = "";
   ```
3. Connect your physical Android device (with USB debugging enabled) or start an emulator.
4. Run the application:
   ```bash
   flutter run
   ```

---

## 📂 Project Architecture

```tree
CampusConnect/
├── backend/                  # Laravel REST API
│   ├── app/Http/Controllers/ # Student & Teacher Controllers
│   ├── database/migrations/  # Database schema & tables
│   └── routes/api.php        # API Endpoints
└── frontend/                 # Flutter Mobile Application
    ├── lib/
    │   ├── globals.dart      # Global state & server IP config
    │   └── screens/          # Student & Teacher Dashboard views
    └── assets/               # Logos, user icons, and QR codes
```
