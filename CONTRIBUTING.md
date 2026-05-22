# Contributing to flutter_ios_capabilities_setup

Thank you for contributing! This tool helps Flutter developers configure iOS capabilities without Xcode — your contributions make it better for everyone.

---

## Before you start

Please **open an issue before starting work** on a new feature or major change. This avoids duplicate work and ensures alignment with the project direction.

---

## How to contribute

```bash
# 1. Fork the repository on GitHub

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/flutter_ios_capabilities_setup.git
cd flutter_ios_capabilities_setup

# 3. Create a branch
git checkout -b feature/your-feature-name

# 4. Make your changes

# 5. Run analysis — must pass with zero errors
dart analyze

# 6. Test (see Testing Requirements below)

# 7. Submit a Pull Request with proof of testing
```

---

## Testing Requirements (mandatory)

**All PRs must include proof of successful testing. PRs without proof will not be merged.**

### 1. Test on a clean Flutter project

```bash
flutter create test_project
cd test_project
dart pub global activate flutter_ios_capabilities_setup
flutter_ios_capabilities_setup
```

### 2. Build the iOS app successfully

```bash
flutter build ios --debug --no-codesign
```

Or build via Codemagic / GitHub Actions.

### 3. Attach to your PR

Your Pull Request **must include all of the following:**

**✅ Proof 1 — Tool output screenshot**
Show the terminal output of the tool running your new capability:

```
✅ [Your capability] configured successfully
```

**✅ Proof 2 — Successful build log or screenshot**

```
✓ Built build/ios/iphoneos/Runner.app
```

A Codemagic build link or GitHub Actions log is preferred.

**✅ Proof 3 — Idempotency test**
Run the tool a second time and confirm nothing is duplicated:

```
⚠️  [Your capability] already configured, skipped
```

**✅ Proof 4 — dart analyze output**

```
Analyzing flutter_ios_capabilities_setup...
No issues found!
```

---

## Adding a new capability

Follow this structure:

**Step 1 — Add to prompts** (`lib/cli/prompts.dart`):

```dart
'Your New Capability',
```

**Step 2 — Add validator if needed** (`lib/validators/`):

- Check for required files
- Validate file content
- Print clear error messages if validation fails

**Step 3 — Add modifier** (`lib/modifiers/`):

- Must be idempotent (check before every change)
- Print `✅` for new changes
- Print `⚠️` for skipped (already exists)
- Print `❌` for errors

**Step 4 — Register in main** (`bin/flutter_ios_capabilities_setup.dart`)

---

## Code rules

| Rule             | Details                                                                   |
| ---------------- | ------------------------------------------------------------------------- |
| Never remove     | Never delete existing code from user files                                |
| Always check     | Check before every modification (idempotency)                             |
| Verify anchors   | Always verify anchor strings in `project.pbxproj` before writing          |
| String insertion | Use `lastIndexOf` pattern for `Info.plist` — never rewrite the whole file |
| Indentation      | 4 spaces for Swift code insertions                                        |
| Analysis         | `dart analyze` must show zero errors                                      |

---

## Roadmap

Capabilities we'd love to add (open an issue to claim one):

```
□ Sign in with Apple
□ HealthKit
□ CoreData / CloudKit
□ In-App Purchases (StoreKit)
□ Camera & Microphone permissions
□ Siri / App Intents
□ Widget Extension
□ Notification Service Extension
□ App Groups
□ Associated Domains (Universal Links)
```

---

## Questions?

Open a [Discussion](https://github.com/MohsenBahaj/flutter_ios_capabilities_setup/discussions) for general questions.

Open an [Issue](https://github.com/MohsenBahaj/flutter_ios_capabilities_setup/issues) for bugs or feature requests.
