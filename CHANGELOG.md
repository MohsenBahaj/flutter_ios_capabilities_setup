# Changelog

## 0.1.0

- Initial release
- Firebase & Push Notifications setup
- Background Modes configuration
- Google Maps setup
- Works on Windows, macOS, and Linux without Xcode

## 0.1.1

## - Fixed README: corrected change_app_package_name usage instructions

# عدّل CHANGELOG.md

## 0.1.2

## - Shortened package description

## - Added dartdoc comments to public API

## - Added example documentation

## 0.1.3

- Enhanced example with full setup walkthrough
- Added CI/CD examples for GitHub Actions and Codemagic

## 0.1.4

- Fixed typo: removed extra space in issues URL displayed in terminal output

## 0.2.0

- feat: Bundle ID mismatch detection — warns before Firebase setup if GoogleService-Info.plist Bundle ID doesn't match project Bundle ID, with fix instructions
- refactor: Regex fallback anchors for project.pbxproj — tool now works even if Flutter changes default UUIDs in future versions
- fix: improved error messages across all modifiers with GitHub issues link for easier bug reporting
