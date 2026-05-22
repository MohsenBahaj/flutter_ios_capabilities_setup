# flutter_ios_capabilities_setup

> Configure iOS capabilities for your Flutter project — **without Xcode, from any OS including Windows.**

[![pub.dev](https://img.shields.io/pub/v/flutter_ios_capabilities_setup.svg)](https://pub.dev/packages/flutter_ios_capabilities_setup)

---

## Why this tool exists

Every Flutter developer building for iOS hits the same wall:

**You need a Mac with Xcode just to:**

- Drag `GoogleService-Info.plist` into the Runner folder
- Enable Push Notifications in Signing & Capabilities
- Enable Background Modes
- Add your Google Maps API key to AppDelegate

**This means:**

- Windows developers are completely blocked
- Developers with no Mac access are stuck

**This tool removes that wall entirely.**

Run one command from **any OS — Windows, macOS, Linux** — and all iOS capabilities are configured correctly:

- `project.pbxproj` updated with correct UUIDs
- `Runner.entitlements` created
- `AppDelegate.swift` configured
- `Info.plist` updated

After running the tool, push your code and build via any CI/CD.
**Your iOS app is ready — no Mac, no Xcode, no manual steps.**

---

## Features

- ✅ Firebase & Push Notifications — full setup in seconds
- ✅ Background Modes — select only the modes you need
- ✅ Google Maps — API key + AppDelegate setup
- ✅ Works on **Windows, macOS, and Linux** — no Xcode required
- ✅ Idempotent — safe to run multiple times, never duplicates
- ✅ Validates `GoogleService-Info.plist` before making any changes
- ✅ After setup, build and deploy via any CI/CD without touching Xcode

---

## Prerequisites

Before running the tool:

### 1. Add your `GoogleService-Info.plist`

Download it from Firebase Console → Your Project → iOS App → Download config file.

Place it at exactly this path:

```
your_project/
└── ios/
    └── Runner/
        └── GoogleService-Info.plist  ← here
```

### 2. Match your Bundle ID

The Bundle ID in `GoogleService-Info.plist` must match your Flutter project's Bundle ID.

Change your project's Bundle ID easily:

```bash
# Step 1 — Add the package
flutter pub add -d change_app_package_name

# Step 2 — Change the bundle ID
dart run change_app_package_name:main com.yourcompany.yourapp
```

To change iOS only:

```bash
dart run change_app_package_name:main com.yourcompany.yourapp --ios
```

See: https://pub.dev/packages/change_app_package_name

### 3. Dart SDK >= 3.0.0

---

## Installation

```bash
dart pub global activate flutter_ios_capabilities_setup
```

---

## Usage

Run from the **root of your Flutter project:**

```bash
flutter_ios_capabilities_setup
```

> **Windows users:** If the command is not recognized, run:
>
> ```bash
> dart pub global run flutter_ios_capabilities_setup
> ```
>
> Or add `%LOCALAPPDATA%\Pub\Cache\bin` to your system PATH.

### Step 1 — Select capabilities

```
🔧 Flutter iOS Configurator
   by Mohsen Bahaj — https://github.com/MohsenBahaj/flutter_ios_capabilities_setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📋 Instructions:
     SPACE  = select / deselect
     ENTER  = confirm selection
     ↑ ↓    = navigate

? Select capabilities to configure
  ◯ Firebase & Push Notifications
  ◯ Background Modes
  ◯ Google Maps
```

### Step 2 — Follow the prompts

Select Background Modes if needed, enter your Google Maps API key if selected.

### Step 3 — Done

```
✅ Created Runner.entitlements
✅ Updated Info.plist — added UIBackgroundModes
✅ Updated AppDelegate.swift — added Firebase setup
✅ Updated project.pbxproj — registered GoogleService-Info.plist
✅ Updated project.pbxproj — iOS deployment target set to 15.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ iOS configuration complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4 — Build via CI/CD

Push your code and build via your preferred CI/CD service.

**If you have Mac access** — run pod install first:

```bash
cd ios && pod install
```

**If you don't have Mac** — use Codemagic or GitHub Actions. They handle pod install automatically as part of the iOS build process.

**Codemagic** (recommended — GUI based, no YAML needed):

1. Connect your repo
2. Select Flutter version and Xcode version
3. Choose Debug / Release / Profile
4. Start build — pod install runs automatically

**GitHub Actions:**

```yaml
jobs:
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.32.8"
      - run: flutter pub get
      - run: cd ios && pod install
      - run: flutter build ios --debug --no-codesign
```

---

## What it configures

### Firebase & Push Notifications

| File                  | Change                                                                              |
| --------------------- | ----------------------------------------------------------------------------------- |
| `Runner.entitlements` | Creates with `aps-environment: development`                                         |
| `Info.plist`          | Adds `UIBackgroundModes: [fetch, remote-notification]`                              |
| `AppDelegate.swift`   | Adds Firebase imports, `FirebaseApp.configure()`, FCM delegate                      |
| `project.pbxproj`     | Registers `GoogleService-Info.plist`, adds entitlements to all build configurations |
| `project.pbxproj`     | Sets `IPHONEOS_DEPLOYMENT_TARGET` to 15.0                                           |

### Background Modes

| File         | Change                                           |
| ------------ | ------------------------------------------------ |
| `Info.plist` | Adds selected modes to `UIBackgroundModes` array |

Supports: `fetch`, `remote-notification`, `location`, `audio`, `processing`

If `UIBackgroundModes` already exists, only missing modes are added.

### Google Maps

| File                | Change                                                     |
| ------------------- | ---------------------------------------------------------- |
| `AppDelegate.swift` | Adds `import GoogleMaps` and `GMSServices.provideAPIKey()` |
| `Info.plist`        | Adds `NSLocationWhenInUseUsageDescription`                 |

---

## Author

Built by **Mohsen Bahaj**

- GitHub: [github.com/MohsenBahaj](https://github.com/MohsenBahaj)
- Portfolio: [bahaj.net/en](https://bahaj.net/en)
- LinkedIn: [linkedin.com/in/mohsen-bahaj](https://www.linkedin.com/in/mohsen-bahaj)

---

## ⭐ Support this project

If this tool saved you time, please **star the repository.**

👉 **[Star on GitHub](https://github.com/MohsenBahaj/flutter_ios_capabilities_setup)**

Found a bug or have a feature request?
👉 **[Open an issue](https://github.com/MohsenBahaj/flutter_ios_capabilities_setup/issues)**

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
