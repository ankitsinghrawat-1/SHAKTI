# SHAKTI (शक्ति) — Unified Women's Safety Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?logo=node.js)](https://nodejs.org)
[![PostgreSQL](https://img.shields.io/badge/Database-Supabase%20Postgres-3ECF8E?logo=supabase)](https://supabase.com)
[![Build APK](https://github.com/ankitsinghrawat-1/shakti/actions/workflows/build-apk.yml/badge.svg)](https://github.com/ankitsinghrawat-1/shakti/actions/workflows/build-apk.yml)
[![Release](https://img.shields.io/badge/Release-v1.0.0-crimson)](https://github.com/ankitsinghrawat-1/shakti/releases)

**SHAKTI** is a full-stack, offline-first personal safety application engineered for rapid emergency response, tamper-evident evidence preservation, real-time GNSS telemetry, and verified safe havens discovery.

---

## 📱 Option 1: Mobile APK Installation (Quickest)

You can download and install the fully functional Android application directly on any physical phone without configuring a local development environment.

### 1. Download the APK
- Download the latest **`app-release.apk`** from the [GitHub Releases](https://github.com/ankitsinghrawat-1/shakti/releases) page.
- Or download the built APK directly from this repository:
  ```
  build/app/outputs/flutter-apk/app-release.apk
  ```

### 2. Install on Android
1. Open the downloaded `.apk` file on your Android device.
2. If prompted, toggle **"Allow installation from unknown sources"** for your browser or file manager.
3. Tap **Install** and open **SHAKTI**.

### 3. Demo Credentials & Quick Test
- **Registration / Sign In**:
  - Enter any phone number (e.g. `9876543210`) or email.
  - Choose any 4-digit PIN (e.g. `1234`).
- **Demo OTP Verification**:
  - Code: **`123456`** *(Tap the green Auto-Fill button on screen)*.
- **Offline / Standalone Mode**:
  - If running without the local backend server connected, the app automatically runs in the local secure enclave mode using PIN `1234`.
- **Duress PIN (Anti-Coercion)**:
  - Enter **`0000`** as your PIN to simulate a disarm while secretly alerting ERSS-112.

---

## 💻 Option 2: Local System Setup & Development

Follow these instructions to run both the Node.js cloud backend and the Flutter mobile client locally on your computer.

### Prerequisites
- **Flutter SDK** (v3.29+ or latest stable): [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- **Node.js** (v18 or higher): [nodejs.org](https://nodejs.org)
- **Java Development Kit (JDK 21)** (required for Gradle 8.x): OpenJDK 21 / Temurin 21
- **Android Studio & Android SDK Command-line Tools**
- **Git**

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/ankitsinghrawat-1/shakti.git
cd shakti
```

---

### Step 2: Configure & Start the Backend

The backend runs on **Node.js + Express** connected to **Supabase PostgreSQL**.

1. Navigate to the backend directory:
   ```bash
   cd backend
   npm install
   ```

2. Create your environment configuration file `backend/.env`:
   ```env
   NODE_ENV=development
   PORT=3000
   DATABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres
   JWT_SECRET=your_jwt_secret_key_at_least_32_characters_long
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_secret
   SUPABASE_EVIDENCE_BUCKET=evidence-vault
   DEMO_OTP_ENABLED=true
   DEMO_OTP_CODE=123456
   ```

3. Run database migrations to provision tables:
   ```bash
   npm run db:migrate
   ```

4. Execute automated backend smoke tests:
   ```bash
   node test_backend.js
   ```

5. Start the backend server:
   ```bash
   npm start
   ```
   *The server starts on `http://localhost:3000/api/v1`.*

---

### Step 3: Run the Flutter Client

1. Open a new terminal and return to the project root:
   ```bash
   cd ..
   flutter pub get
   ```

2. Verify project diagnostics:
   ```bash
   flutter analyze
   ```

3. **Running on Connected Android Phone via USB**:
   - Enable **USB Debugging** on your Android phone under Developer Options.
   - Connect the phone via USB cable and run:
     ```bash
     flutter devices
     ```
   - Forward the backend port so your phone can reach `http://localhost:3000`:
     ```bash
     adb reverse tcp:3000 tcp:3000
     ```
   - Launch the app in debug/profile mode:
     ```bash
     flutter run -d <DEVICE_ID>
     ```

4. **Running on Local Computer / Chrome Browser**:
   ```bash
   flutter run -d chrome
   ```

---

### Step 4: Building a Production Release APK Locally

To compile an optimized, standalone release APK on your machine:

```powershell
flutter build apk --release
```

The compiled APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

To install directly to a connected USB device:
```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 Connecting Phone to Local Backend over Wi-Fi

If running without a USB cable (or over Wi-Fi):
1. Find your computer's local IP address (e.g. `192.168.1.45` via `ipconfig` on Windows or `ifconfig` on macOS/Linux).
2. Ensure both your computer and phone are connected to the same Wi-Fi network.
3. In the mobile app, tap the **Server Connection Pill** on the Login screen or open **App Settings > Backend Connection** and set:
   ```
   http://192.168.1.45:3000/api/v1
   ```

---

## 🛠️ Key Architectural Capabilities

| Capability | Implementation Detail |
| :--- | :--- |
| **Sub-Meter Live GNSS** | Continuous 1m high-accuracy GPS hardware stream with 6-decimal precision and live street address reverse geocoding. |
| **Real Nearby Havens Discovery** | Real-time geospatial lookup via OpenStreetMap Nominatim & Google Places to discover actual hospitals, police posts, and safe points around user. |
| **Turn-by-Turn Navigation** | Native one-tap walking route guidance and emergency phone dialing (`112` / `108`) directly in Google Maps. |
| **Tamper-Evident Evidence Vault** | Acoustic recording + sequential dual-camera video, hashed using SHA-256, uploaded to private Supabase Storage, with in-app playback and PDF dossier export. |
| **Anti-Coercion Duress PIN** | Secret PIN (`0000`) disarms UI visually while silently dispatching high-priority covert duress telemetry to ERSS-112. |
| **Camouflage Calculator** | Instant decoy screen disguising SHAKTI as a working calculator under duress. |
| **Automated CI/CD** | GitHub Actions workflow compiles the release APK automatically on every commit. |

---

## 🧪 Verification & Health Check

Run these checks to verify system readiness:

```bash
# Verify backend smoke tests (Auth, Registration, Guardians, Feedback)
node backend/test_backend.js

# Verify Flutter code compliance
flutter analyze
```

---

## 📄 License
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
