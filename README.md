# 🌿 Plant Monitor System (v1.0)

A smart, IoT-based mobile application built with Flutter to monitor, manage, and automate plant care remotely. This system connects to an ESP32 microcontroller via Firebase Realtime Database to provide real-time sensor data and control automated watering mechanisms.

## ✨ Key Features

- **Live Sensor Dashboard**
  - Real-time display of **Soil Moisture** (via an interactive, dynamic gauge).
  - Live tracking of ambient **Temperature** and **Humidity**.
  - Monitoring of the reservoir **Water Level**.

- **Smart Weather Prediction**
  - Analyzes current temperature and humidity to infer local weather states (e.g., Sunny, Partly Cloudy, Rainy, Hot).
  - Displays dynamic banners and icons matching the predicted weather conditions.

- **Advanced Time Slot Scheduling**
  - Allows users to configure a specific automated watering window by selecting a **Start Time** and **End Time**.
  - Syncs the time slot configuration instantly with the cloud so hardware (ESP32) knows exactly when to operate the water valve.
  - Graceful skipping logic: Watering skips automatically if moisture is already above the required threshold.

- **Manual Override Controls**
  - "Water Now" toggle to manually open/close the irrigation valve remotely from anywhere in the world.

- **Premium UI / UX Design**
  - Built with a sleek, modern **Dark Mode** aesthetic featuring deep navy blues (`#0F1923`) and vibrant neon greens (`#6BCB77`).
  - Smooth micro-animations, glass-morphism cards, and a seamless gradient splash screen that matches the launcher icon.

## 🛠️ Technology Stack

- **Frontend:** Flutter (Dart)
- **Backend / Cloud:** Firebase Realtime Database
- **Hardware (Target):** ESP32 Microcontroller (C++)
- **Target OS:** Android (Universal APK bundled for arm64-v8a, armeabi-v7a, x86_64)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Android Studio / Android SDK
- Firebase Project configured with Realtime Database enabled.

### Run the App
1. Clone this repository.
2. Run `flutter pub get` to fetch dependencies.
3. Replace the placeholder values in `lib/firebase_options.dart` with your own Firebase configuration keys.
4. Add your `google-services.json` file to `android/app/`.
5. Connect your device and run:
   ```bash
   flutter run
   ```

### Build the APK
To export a universal "fat" APK that runs on all Android devices:
```bash
flutter build apk
```
The final binary will be available at: `build/app/outputs/flutter-apk/app-release.apk`
