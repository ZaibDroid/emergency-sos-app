# 🚨 Emergency SOS

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

A cross-platform mobile application designed to provide immediate safety assistance during emergency situations. The primary focus of this application is reliability—ensuring that life-saving SOS alerts can be sent even without an active internet connection.

## ✨ Key Features

- **Offline SOS Alerts**: Pressing the SOS button instantly fetches the device's hardware GPS coordinates and dispatches an emergency SMS to your trusted contacts, embedded with a Google Maps link. Works completely offline (requires cellular signal only).
- **Trusted Contacts Management**: Securely store up to 4 emergency contacts locally on your device.
- **Live Location Tracking**: View your real-time position on an interactive Google Map.
- **Nearby Emergency Services**: Quickly locate and get directions to nearby Hospitals, Police Stations, Car Mechanics, and Petrol Pumps using the Overpass API (OpenStreetMap).

## 🛠️ Technology Stack

- **Framework**: Flutter (Dart)
- **Local Storage**: `shared_preferences` (No external database, ensuring total privacy)
- **Location Services**: `geolocator`
- **Mapping**: `google_maps_flutter`
- **Places Integration**: Overpass API (OpenStreetMap) via HTTP
- **Messaging**: `flutter_sms` / native telephony channels

## 📶 Internet Dependency Breakdown

| Feature | Needs Internet? | How it Works |
| --- | --- | --- |
| **Get GPS Coordinates** | ❌ **No** | Uses hardware satellite GPS. |
| **Send SMS Alert** | ❌ **No** | Uses native cellular modem (requires SIM signal). |
| **Manage Contacts** | ❌ **No** | Reads/writes to local device flash storage. |
| **Load Google Map** | ✅ Yes | Downloads visual map tiles. |
| **Find Nearby Services**| ✅ Yes | Calls Overpass API. |

## 🚀 Installation & Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- Android Studio / Xcode
- A physical device is recommended to test SMS and GPS features accurately.

### Steps to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/sos-safety-app.git
   cd sos-safety-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## 🔐 Permissions Required

To function correctly, the app will request the following runtime permissions on first launch:
- `ACCESS_FINE_LOCATION`: Required to get precise hardware GPS coordinates.
- `SEND_SMS`: Required to programmatically dispatch emergency text messages in the background.

## 🛡️ Privacy First
This app does not contain a backend server. Your name, location, and emergency contacts never leave your device unless you explicitly trigger an SOS, at which point the data is sent directly to the contacts *you* defined.

---
*Built to help keep people safe.*
