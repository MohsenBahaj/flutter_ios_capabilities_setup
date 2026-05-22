# flutter_ios_capabilities_setup Example

## Basic usage

```bash
# 1. Navigate to your Flutter project root
cd your_flutter_project

# 2. Add GoogleService-Info.plist to ios/Runner/

# 3. Run the tool
flutter_ios_capabilities_setup

# 4. Select capabilities and follow prompts
```

## What gets configured

After running the tool, these files are updated automatically:

- `ios/Runner/Runner.entitlements`
- `ios/Runner/Info.plist`
- `ios/Runner/AppDelegate.swift`
- `ios/Runner.xcodeproj/project.pbxproj`
