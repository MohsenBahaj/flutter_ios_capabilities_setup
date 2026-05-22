# flutter_ios_capabilities_setup — Example

## Full Setup Walkthrough

### Step 1 — Create or open your Flutter project

```bash
flutter create my_app
cd my_app
```

### Step 2 — Match your Bundle ID with Firebase

Add `change_app_package_name` to your project:

```bash
flutter pub add -d change_app_package_name
dart run change_app_package_name:main com.yourcompany.yourapp
```

### Step 3 — Add GoogleService-Info.plist

Download from Firebase Console → Your Project → iOS App → Download config file.

Place it here:

```
my_app/
└── ios/
    └── Runner/
        └── GoogleService-Info.plist  ← here
```

### Step 4 — Install and run the tool

```bash
dart pub global activate flutter_ios_capabilities_setup
flutter_ios_capabilities_setup
```

> **Windows users:** If command not recognized:
>
> ```bash
> dart pub global run flutter_ios_capabilities_setup
> ```

### Step 5 — Select capabilities

```
📋 Instructions:
   SPACE  = select / deselect
   ENTER  = confirm selection
   ↑ ↓    = navigate

? Select capabilities to configure
  ◯ Firebase & Push Notifications
  ◯ Background Modes
  ◯ Google Maps
```

### Step 6 — Expected output

```
✅ Created Runner.entitlements
✅ Updated Info.plist — added background mode: fetch
✅ Updated Info.plist — added background mode: remote-notification
✅ Updated AppDelegate.swift — added imports: FirebaseCore, FirebaseMessaging, UserNotifications
✅ Updated AppDelegate.swift — added MessagingDelegate
✅ Updated AppDelegate.swift — added Firebase setup
✅ Updated AppDelegate.swift — added Firebase delegate methods
✅ Updated project.pbxproj — registered GoogleService-Info.plist
✅ Updated project.pbxproj — iOS deployment target set to 15.0
✅ Updated AppDelegate.swift — added import GoogleMaps
✅ Updated AppDelegate.swift — added GMSServices.provideAPIKey
✅ Updated Info.plist — added NSLocationWhenInUseUsageDescription

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ iOS configuration complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 7 — Build via CI/CD

**With Mac access:**

```bash
cd ios && pod install
flutter build ios --debug
```

**Without Mac — GitHub Actions:**

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

**Without Mac — Codemagic:**

1. Connect your repo
2. Select Flutter + Xcode version
3. Choose Debug/Release
4. Build — pod install runs automatically

## What gets configured

| File                                   | Change                                                                           |
| -------------------------------------- | -------------------------------------------------------------------------------- |
| `ios/Runner/Runner.entitlements`       | Created with Push Notifications entitlement                                      |
| `ios/Runner/Info.plist`                | UIBackgroundModes, NSLocationWhenInUseUsageDescription                           |
| `ios/Runner/AppDelegate.swift`         | Firebase imports, configure(), FCM delegate, Google Maps                         |
| `ios/Runner.xcodeproj/project.pbxproj` | GoogleService-Info.plist registered, entitlements linked, deployment target 15.0 |
