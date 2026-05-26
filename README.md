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

## 🔌 Hardware Setup (Physical Build)

The physical system uses the following components:

- **Microcontroller:** NodeMCU ESP32S
- **Soil Moisture Sensor:** Capacitive Soil Moisture Sensor v1.2
- **Ambient Temp & Humidity Sensor:** DHT11
- **Soil Temperature Sensor:** Waterproof DS18B20
- **Display:** 16x2 LCD Display with I2C Interface Module
- **Relay:** 5V 1-Channel Relay Module (with Optocoupler isolation)
- **Water Valve:** 12V DC Solenoid Water Valve (Normally Closed)
- **Power Supply:**
  - **12V DC Power Adapter/Battery:** Provides enough power for the solenoid valve.
  - **LM2596 DC-DC Buck Converter:** Steps down the 12V supply to 5V to safely power the ESP32 (via the VIN pin) and the Relay Module.
- **Miscellaneous:** Breadboard, Jumper Wires, and a 4.7k Ohm Resistor (required as a pull-up resistor for the DS18B20 sensor).

## 💻 How to Simulate the Device (Wokwi)

Before building the physical hardware, you can test and simulate the ESP32 code online using the [Wokwi Simulator](https://wokwi.com/).

1. Start a new ESP32 project on Wokwi.
2. Click the **+** button to add the supported components: `DHT11`, `DS18B20`, `16x2 I2C LCD`, and a `Relay` module.
3. **Simulating Soil Moisture:** Since you cannot simulate wet soil in Wokwi, add a **Potentiometer**. Connect it to an analog pin and twist the knob to simulate changing soil moisture levels.
4. **Internet Connectivity:** Wokwi allows the virtual ESP32 to connect to the actual internet. You can configure your WiFi credentials in the simulation to connect directly to your live Firebase database!
